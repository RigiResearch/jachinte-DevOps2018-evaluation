/*
 * Copyright 2018 University of Victoria
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to
 * deal in the Software without restriction, including without limitation the
 * rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 * IN THE SOFTWARE.
 */
package co.migueljimenez.devops.listener.openstack

import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.listener.EventHandler
import co.migueljimenez.devops.mart.infrastructure.operations.InfrastructureModelOp
import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.primor.ManagerService
import com.rigiresearch.lcastane.primor.RemoteService
import java.rmi.registry.LocateRegistry
import java.rmi.registry.Registry
import java.util.Map
import org.apache.commons.configuration2.Configuration
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.openstack4j.api.OSClient.OSClientV3
import org.openstack4j.model.common.Identifier
import org.openstack4j.model.identity.v3.Token
import org.openstack4j.openstack.OSFactory
import org.slf4j.LoggerFactory
import co.migueljimenez.devops.infrastructure.model.ContainerFormat
import co.migueljimenez.devops.infrastructure.model.DiskFormat
import de.xn__ho_hia.storage_unit.StorageUnits
import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.infrastructure.model.Image
import org.apache.commons.configuration2.PropertiesConfiguration
import org.openstack4j.model.network.SecurityGroup

/**
 * An OpenStack event handler that executes {@link Command}s on PrIMoR.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
class OpenStackHandler implements EventHandler {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(OpenStackHandler)

	/**
	 * The OpenStack client.
	 */
	val OSClientV3 client

	/**
	 * Events from this user are ignored.
	 */
	val String ignoredUser

	/**
	 * Properties configuration for PrIMoR.
	 */
	val Configuration primorConfig

	/**
	 * The (remote) RMI registry.
	 */
	val Registry registry

	/**
	 * The PrIMoR's model manager.
	 */
	val ManagerService models

	/**
	 * A helper to instantiate elements from the Infrastructure model.
	 */
	val InfrastructureModelElements i

	/**
	 * A parser to serialize Ecore objects.
	 */
	val SerializationParser serializationParser

	/**
	 * Default constructor.
	 */
	new() {
		this.primorConfig = new Configurations().properties("primor.properties")
		val osConf = new Configurations().properties("openstack.properties")
		this.ignoredUser = osConf.getString("ignored-user")
		this.client = this.openStackClient(osConf)
		this.registry = LocateRegistry.getRegistry(
			this.primorConfig.getString("manager-host"),
			this.primorConfig.getInt("manager-port")
		)
		this.models =
			this.registry.lookup(RemoteService.MANAGER.toString) as ManagerService
		this.i = new InfrastructureModelElements
		this.serializationParser = new SerializationParser
	}

	/**
	 * Authentication based on the
	 * <a href="http://www.openstack4j.com/learn/getting-started/#authenticate">OpenStack4j</a>
	 * documentation
	 */
	def private openStackClient(PropertiesConfiguration osConf) {
		val method = osConf.getString("authentication-method")
		var client = OSFactory.builderV3()
			.endpoint(osConf.getString("OS_AUTH_URL"))
		switch (method) {
			case "UNSCOPED": {
				client = client.credentials(
					osConf.getString("OS_USERNAME"),
					osConf.getString("OS_PASSWORD"),
					Identifier.byId(osConf.getString("OS_PROJECT_DOMAIN_ID"))
				)
			}
			case "PROJECT-SCOPED": {
				client = client.credentials(
					osConf.getString("OS_USERNAME"),
					osConf.getString("OS_PASSWORD"),
					Identifier.byName(osConf.getString("OS_USER_DOMAIN_NAME"))
				)
				.scopeToProject(
                  	Identifier.byId(osConf.getString("OS_PROJECT_ID"))
				)
			}
			case "DOMAIN-SCOPED": {
				client = client.credentials(
					osConf.getString("OS_USER_ID"),
					osConf.getString("OS_PASSWORD")
				)
				.scopeToDomain(
                   	Identifier.byName(osConf.getString("OS_USER_DOMAIN_NAME"))
				)
			}
			default:
				throw new IllegalArgumentException('''Unknown value "«method»"''')
		}
		return client.authenticate
	}

	override handle(Object event) {
		val e = event as OpenStackEvent
		if (!e.user.isNullOrEmpty && e.user.equals(this.ignoredUser)) {
			this.logger.info('''Event "«e.eventType»" was ignored because its author («this.ignoredUser») is being ignored''')
			return;
		}
		// FIXME Dig into this Glance issue
		if (e.user.isNullOrEmpty)
			e.user = "unknown"
		this.handle(e, this.client.token)
	}

	override handledType() {
		OpenStackEvent
	}

	/**
	 * Handles an OpenStack event.
	 */
	def protected void handle(OpenStackEvent event, Token token) {
		val modelId = this.primorConfig.getString("model-id")
		if (!this.models.modelRegistered(modelId)) {
			this.logger.info(
				'''The event was not further handled because the model "«modelId»" hasn't been registered yet'''
			)
			return
		}
		val client = OSFactory.clientFromToken(token)
		val Map<String, Object> context = #{
			"author" -> event.user,
			"email" -> '''«event.user»@OpenStack'''
		}
		switch (event.eventType) {
			// Nova
			case "keypair.create.end":
				this.newKeypair(client, modelId, context, event)
			case "keypair.import.end":
				this.newKeypair(client, modelId, context, event)
			case "keypair.delete.end":
				this.deleteKeypair(modelId, context, event)
			// Neutron
			case "security_group.create.end":
				this.newSecurityGroup(client, modelId, context, event)
			case "security_group.delete.end":
				this.deleteSecurityGroup(modelId, context, event)
			// Glance
			case "image.create":
				this.newImage(client, modelId, context, event)
			case "image.delete":
				this.deleteImage(modelId, context, event)
			default:
				println('''Unknown OpenStack event: «event.eventType»''')
		}
	}

	/**
	 * Requests deleting an existing keypair from the infrastructure model.
	 */
	def private void deleteKeypair(String modelId, Map<String, Object> context,
		OpenStackEvent event) {
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.REMOVE_RESOURCE,
				context,
				event.payload.get("key_name").asText,
				Credential.canonicalName
			)
		)
	}

	/**
	 * Requests adding a new keypair to the infrastructure model.
	 */
	def private void newKeypair(OSClientV3 client, String modelId,
		Map<String, Object> context, OpenStackEvent event) {
		val name = event.payload.get("key_name").asText
		val keypair = client.compute.keypairs.get(name)
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.ADD_RESOURCE,
				context,
				this.serializationParser.asXml(
					this.i.credential(
						name,
						keypair.publicKey,
						this.i.infrastructure
					)
				)
			)
		)
	}

	/**
	 * Requests adding a new security group to the infrastructure model.
	 */
	def private void newSecurityGroup(OSClientV3 client, String modelId,
		Map<String, Object> context, OpenStackEvent event) {
		val name = event.payload.path("security_group").get("name").asText
		val groups = client.networking.securitygroup.list(#{"name" -> name})
		var SecurityGroup group = null
		if (groups.size == 1) {
			group = groups.get(0)
		} else {
			this.logger.error('''Could not find security group "«name»"''')
			return
		}
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.ADD_RESOURCE,
				context,
				this.serializationParser.asXml(
					this.i.securityGroup(
						group.id,
						name,
						event.payload.path("security_group").get("description").asText,
						this.i.infrastructure
					)
				)
			)
		)
	}

	/**
	 * Requests deleting an existing image from the infrastructure model.
	 */
	def private void deleteSecurityGroup(String modelId, Map<String, Object> context,
		OpenStackEvent event) {
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.REMOVE_RESOURCE,
				context,
				event.payload.get("security_group_id").asText,
				co.migueljimenez.devops.infrastructure.model.SecurityGroup.canonicalName
			)
		)
	}

	/**
	 * Requests deleting an existing image from the infrastructure model.
	 */
	def private void deleteImage(String modelId, Map<String, Object> context,
		OpenStackEvent event) {
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.REMOVE_RESOURCE,
				context,
				event.payload.get("name").asText,
				Image.canonicalName
			)
		)
	}

	/**
	 * Requests adding a new image to the infrastructure model.
	 */
	def private void newImage(OSClientV3 client, String modelId,
		Map<String, Object> context, OpenStackEvent event) {
		val image = client.images.get(event.payload.get("id").asText)
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.ADD_RESOURCE,
				context,
				this.serializationParser.asXml(
					this.i.image(
						event.payload.get("id").asText,
						event.payload.get("name").asText,
						ContainerFormat.valueOf(event.payload.get("container_format").asText.toUpperCase),
						DiskFormat.valueOf(event.payload.get("disk_format").asText.toUpperCase),
						// TODO use the location from the event
						image.location,
						StorageUnits.gigabyte(Long.valueOf(event.payload.get("min_disk").asText)),
						StorageUnits.megabyte(Long.valueOf(event.payload.get("min_ram").asText)),
						this.i.infrastructure
					)
				)
			)
		)
	}
}
