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
package com.rigiresearch.lcastane.primor

import java.io.InputStreamReader

/**
 * Main class.
 * @author Miguel Jimenez (miguel@uvic.ca) - Port to Xtend and improvements
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-06-13
 * @version $Id$
 * @since 0.0.1
 */
class Application {

	/**
	 * The RMI server.
	 */
	val Server server

	/**
	 * Default constructor.
	 * @param manager The service manager instance to publish
	 */
	new(ManagerService manager) {
		this.server = new Server(manager)
		this.configure
		this.server.bindServices
	}

	/**
	 * Configures a shutdown hook to unbind the published RMI services.
	 */
	def private configure() {
		Runtime.runtime.addShutdownHook(new Thread()[
			this.server.unbindServices
		])
	}

	def static void main(String[] args) {
		new Application(new Manager)
		println("Press enter to stop...")
		new InputStreamReader(System.in).read
	}
}
