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
package co.migueljimenez.devops.listener

import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.listener.openstack.OpenStackEvent
import co.migueljimenez.devops.listener.openstack.OpenStackListener
import co.migueljimenez.devops.mart.infrastructure.operations.InfrastructureModelOp
import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.primor.ManagerService
import com.rigiresearch.lcastane.primor.RemoteService
import java.rmi.registry.LocateRegistry
import java.rmi.registry.Registry
import org.apache.commons.configuration2.Configuration
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.openstack4j.api.OSClient.OSClientV3
import org.openstack4j.model.common.Identifier
import org.openstack4j.model.identity.v3.Token
import org.openstack4j.openstack.OSFactory
import org.slf4j.LoggerFactory

/**
 * The main execution entry.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
class Application {

	/**
     * The logger.
     */
	val logger = LoggerFactory.getLogger(Application)

	/**
	 * The OpenStack client.
	 */
	val OSClientV3 client

	/**
	 * The event listeners.
	 */
	val EventListener[] listeners

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
	new(EventListener... listeners) {
		this.listeners = listeners
		val osConf = new Configurations().properties("openstack.properties")
		this.primorConfig = new Configurations().properties("primor.properties")
		this.client = OSFactory.builderV3()
			.endpoint(osConf.getString("endpoint"))
			.credentials(
				osConf.getString("username"),
				osConf.getString("password"),
				Identifier.byId(osConf.getString("domainId"))
			)
			.authenticate()
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
	 * Causes all listeners to start listening for events.
	 */
	def start() {
		this.logger.info("Starting listeners")
		this.listeners.forEach [ l |
			l.listen [ e |
				switch (e) {
					OpenStackEvent: e.handle(this.client.token)
					default: println('''Unknown event: «e»''')
				}
			]
		]
	}

	/**
	 * Causes all listeners to stop listening for events.
	 */
	def stop() {
		this.logger.info("Stopping listeners")
		this.listeners.forEach[l|l.stop]
	}

	/**
	 * Handles an OpenStack event.
	 */
	def protected handle(OpenStackEvent e, Token token) {
		val client = OSFactory.clientFromToken(token)
		switch (e.eventType) {
			case "keypair.create.end": {
				val name = e.payload.get("key_name").asText
				val keypair = client.compute.keypairs.get(name)
				this.models.execute(
					"el-modelo",
					new Command(
						InfrastructureModelOp.ADD_RESOURCE,
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
			default:
				println('''Unknown OpenStack event: «e»''')
		}
	}

	/**
	 * Instantiates an OpenStack Listener.
	 * 
	 * TODO Translate each event into a MART command and send it to the MART
	 * infrastructure's remote service.
	 */
	def static void main(String[] args) {
		new Application(
			new OpenStackListener("nova", "notifications.info")
		).start()
	}
}
