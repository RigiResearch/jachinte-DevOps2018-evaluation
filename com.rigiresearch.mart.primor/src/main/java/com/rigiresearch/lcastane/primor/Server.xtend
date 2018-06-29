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

import java.io.IOException
import java.rmi.AccessException
import java.rmi.AlreadyBoundException
import java.rmi.NotBoundException
import java.rmi.Remote
import java.rmi.RemoteException
import java.rmi.registry.LocateRegistry
import java.rmi.registry.Registry
import java.rmi.server.UnicastRemoteObject
import org.apache.commons.configuration2.Configuration
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.slf4j.LoggerFactory

/**
 * A RMI server to publish a {@link ManagerService}.
 * @author Miguel Jimenez (miguel@uvic.ca) - Port to Xtend and improvements
 * @Lorena Castaneda - Initial contribution and API
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class Server {

	/**
     * The logger.
     */
	val logger = LoggerFactory.getLogger(Server)

	/**
	 * The RMI registry.
	 */
	val Registry registry

	/**
	 * The manager service instance to publish.
	 */
	val ManagerService manager

	/**
	 * The exported manager.
	 */
	var Remote exportedManager

	/**
	 * The RMI properties configuration.
	 */
	val Configuration configuration

	/**
	 * Default constructor.
	 * @param manager The manager service instance to publish
	 */
	new(ManagerService manager) {
		this.manager = manager
		this.configuration = new Configurations().properties("primor.properties")
		val port = this.configuration.getInt("manager-port")
		// Use the same port to avoid any extra configuration
		this.exportedManager = UnicastRemoteObject.exportObject(this.manager, port)
		this.registry = LocateRegistry.createRegistry(port)
	}

	/**
	 * Binds PrIMoR services through their remote interfaces.
	 * @throws IOException If something goes wrong while binding the services
	 * @throws AlreadyBoundException If an instance of primor is already running
	 */
	def void bindServices() throws IOException, AlreadyBoundException {
		// Bind the remote object's stub in the registry
		this.registry.bind(RemoteService.MANAGER.toString(), this.exportedManager)
		this.logger.info("PrIMoR services have been started")
	}

	/**
	 * Unbinds PrIMoR's remote services.
	 * @throws NotBoundException In case the services have been already unbound
	 * @throws RemoteException See {@link Registry#unbind(String)}
	 * @throws AccessException See {@link Registry#unbind(String)}
	 */
	def void unbindServices()
		throws AccessException, RemoteException, NotBoundException {
		this.registry.unbind(RemoteService.MANAGER.toString())
		UnicastRemoteObject.unexportObject(this.manager, true)
		this.logger.info("PrIMoR services have been stopped")
	}
}
