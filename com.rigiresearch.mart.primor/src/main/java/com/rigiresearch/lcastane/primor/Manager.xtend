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

import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.framework.MART
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.rmi.RemoteException
import java.util.Map
import org.slf4j.LoggerFactory

/**
 * A {@link ManagerService} implementation.
 * @author Miguel Jimenez (miguel@uvic.ca) - Port to Xtend
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class Manager implements ManagerService {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(Manager)

	/**
	 * The registered models.
	 */
	val Map<String, MART<?, ?>> models

	/**
	 * Default constructor.
	 */
	new() {
		this.models = newHashMap
	}

	override register(String modelIdentifier, MART<?, ?> model)
		throws RemoteException {
		this.models.put(modelIdentifier, model)
		this.logger.info('''Model registered with id "«modelIdentifier»"''')
	}

	override execute(String modelIdentifier, Command command)
		throws RemoteException, ValidationException, ModelNotFoundException {
		this.ensureModelExists(modelIdentifier)
		this.models.get(modelIdentifier).artefact.apply(command)
		val s = if(command.arguments.length == 1) "" else "s"
		this.logger.info(
			'''Command «command.operationType» («command.arguments.length» argument«s») was applied to model "«modelIdentifier»"'''
		)
	}

	override artefact(String modelIdentifier)
		throws RemoteException, ModelNotFoundException {
		this.ensureModelExists(modelIdentifier)
		this.models.get(modelIdentifier).artefact
	}

	override specification(String modelIdentifier)
		throws RemoteException, ModelNotFoundException {
		this.ensureModelExists(modelIdentifier)
		this.models.get(modelIdentifier).specification
	}

	override modelRegistered(String modelIdentifier) throws RemoteException {
		this.models.containsKey(modelIdentifier)
	}

	def private ensureModelExists(String modelIdentifier)
		throws ModelNotFoundException {
		if (!this.models.containsKey(modelIdentifier))
			throw new ModelNotFoundException('''Model «modelIdentifier» not found''')
	}
}
