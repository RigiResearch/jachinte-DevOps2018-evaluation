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

import co.migueljimenez.devops.listener.openstack.OpenStackEvent
import co.migueljimenez.devops.listener.openstack.OpenStackListener
import org.openstack4j.api.OSClient.OSClientV3
import org.openstack4j.model.common.Identifier
import org.openstack4j.openstack.OSFactory
import org.apache.commons.configuration2.builder.fluent.Configurations
import java.io.File

/**
 * The main execution entry.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
class Application {

	/**
	 * The OpenStack client.
	 */
	val OSClientV3 client

	/**
	 * The event listeners.
	 */
	val EventListener[] listeners

	/**
	 * Default constructor.
	 */
	new(EventListener... listeners) {
		this.listeners = listeners
		val configuration = Configurations.newInstance.properties(
			new File("openstack.properties")
		)
		this.client = OSFactory.builderV3()
			.endpoint(configuration.getString("endpoint"))
			.credentials(
				configuration.getString("username"),
				configuration.getString("password"),
				Identifier.byId(configuration.getString("domainId"))
			)
			.authenticate()
	}

	/**
	 * Causes all listeners to start listening for events.
	 */
	def start() {
		this.listeners.forEach [ l |
			l.listen [ e |
				switch (e) {
					OpenStackEvent: e.handle
					default:
						println('''Unknown event: «e»''')
				}
			]
		]
	}

	/**
	 * Causes all listeners to stop listening for events.
	 */
	def stop() {
		this.listeners.forEach[l|l.stop]
	}

	/**
	 * Handles an OpenStack event.
	 */
	def protected handle(OpenStackEvent e) {
		switch (e.eventType) {
			case "keypair.create.end": {
				val name = e.payload.get("key_name").asText
				val keypair = this.client.compute.keypairs.get(name)
				println(
					'''
					name: «keypair.name»
					public_key: «keypair.publicKey»
					'''
				)
			}
			default:
				println('''Unknown OpenStack event: «e»''')
		}
	}

	def static void main(String[] args) {
		new Application(
			new OpenStackListener("nova", "notifications.info")
		).start()
	}
}
