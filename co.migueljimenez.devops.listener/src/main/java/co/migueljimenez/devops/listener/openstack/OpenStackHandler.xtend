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
		this.client = this.openStackClient
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
	def private openStackClient() {
		val osConf = new Configurations().properties("openstack.properties")
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
		(event as OpenStackEvent).handle(this.client.token)
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
				'''OpenStack event was not further handled because the model "«modelId»" hasn't been registered yet'''
			)
			return
		}
		val client = OSFactory.clientFromToken(token)
		val Map<String, Object> context = #{
			"author" -> event.user,
			"email" -> '''«event.user»@OpenStack'''
		}
		switch (event.eventType) {
			case "keypair.create.end":
				this.newKeypair(client, modelId, context, event)
			case "keypair.import.end":
				this.newKeypair(client, modelId, context, event)
			case "keypair.delete.end": {
				this.models.execute(
					modelId,
					new Command(
						InfrastructureModelOp.REMOVE_CREDENTIAL,
						context,
						event.payload.get("key_name").asText
					)
				)
			}
			default:
				println('''Unknown OpenStack event: «event.eventType»''')
		}
	}

	def private void newKeypair(OSClientV3 client, String modelId,
		Map<String, Object> context, OpenStackEvent event) {
		val name = event.payload.get("key_name").asText
		val keypair = client.compute.keypairs.get(name)
		this.models.execute(
			modelId,
			new Command(
				InfrastructureModelOp.ADD_CREDENTIAL,
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
}
