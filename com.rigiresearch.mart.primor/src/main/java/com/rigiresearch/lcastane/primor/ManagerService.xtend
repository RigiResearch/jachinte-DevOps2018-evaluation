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

import com.rigiresearch.lcastane.framework.Artefact
import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.framework.MART
import com.rigiresearch.lcastane.framework.Specification
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.rmi.Remote
import java.rmi.RemoteException

/**
 * A model manager.
 * @author Miguel Jimenez (miguel@uvic.ca) - Port to Xtend and improvements
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-07-11
 * @version $Id$
 * @since 0.0.1
 */
interface ManagerService extends Remote {

	/**
	 * Registers a new model to be managed.
	 * @param modelIdentifier The model's identifier
	 * @param model The model to register
	 */
	def void register(String modelIdentifier, MART<?, ?> model)
		throws RemoteException

	/**
	 * Registers a new model to be managed.
	 * <b>Note:</b> This is a temporary workaround. It will be removed when a
	 * solution is found to register Ecore-based artefacts.
	 * @param modelIdentifier The model's identifier
	 * @param specification The model's specification
	 */
	def void register(String modelIdentifier, Specification specification)
		throws RemoteException

	/**
	 * Executes the given command on the specified model.
	 * @param modelIdentifier The model's identifier
	 * @param command The command to execute
	 * @param description A descriptive message associated with the command
	 * @throws ValidationException If the sentence is not compliant with the
	 *  corresponding operation
	 * @throws ModelNotFoundException If the model is not found
	 * @throws RemoteException If there is a communication error
	 */
	def void execute(String modelIdentifier, Command command, String description)
		throws RemoteException, ValidationException, ModelNotFoundException

	/**
	 * Returns the specified model's artefact.
	 * @param identifier The model's identifier
	 * @return An {@link Artefact}
	 * @throws ModelNotFoundException If the model is not found
	 * @throws RemoteException If there is a communication error
	 */
	def Artefact artefact(String modelIdentifier)
		throws RemoteException, ModelNotFoundException

	/**
	 * Returns the specification associated with the specified model.
	 * @param modelIdentifier The model's identifier
	 * @return A {@link Notation}
	 * @throws ModelNotFoundException If the model is not found
	 * @throws RemoteException If there is a communication error
	 */
    def Specification specification(String modelIdentifier)
        throws RemoteException, ModelNotFoundException

	/**
     * Whether the specified model is registered.
     * @param modelIdentifier The model's identifier
     * @throws RemoteException If there is a communication error
     */
    def boolean modelRegistered(String modelIdentifier) throws RemoteException
}
