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

import co.migueljimenez.devops.listener.openstack.OpenStackHandler
import co.migueljimenez.devops.listener.openstack.OpenStackListener
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
	 * The event listeners.
	 */
	val EventListener[] listeners

	/**
	 * The event handlers.
	 */
	val EventHandler[] handlers

	/**
	 * Default constructor.
	 */
	new(EventListener[] listeners, EventHandler[] handlers) {
		this.listeners = listeners
		this.handlers = handlers
	}

	/**
	 * Causes all listeners to start listening for events.
	 */
	def start() {
		this.logger.info("Starting listeners")
		this.listeners.forEach [ l |
			l.listen [ e |
				this.handlers
					.filter[h|h.handledType.isAssignableFrom(e.class)]
					.forEach[h|h.handle(e)]
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

	def static void main(String[] args) {
		new Application(
			#[new OpenStackListener("nova", "notifications.info")],
			#[new OpenStackHandler]
		).start()
	}
}
