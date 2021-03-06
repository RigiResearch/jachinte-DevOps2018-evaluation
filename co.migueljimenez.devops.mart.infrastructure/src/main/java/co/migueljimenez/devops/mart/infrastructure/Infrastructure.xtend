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
package co.migueljimenez.devops.mart.infrastructure

import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.mart.infrastructure.operations.AddResource
import co.migueljimenez.devops.mart.infrastructure.operations.InfrastructureModelOp
import co.migueljimenez.devops.mart.infrastructure.operations.rules.TypesValidation
import com.rigiresearch.lcastane.framework.Artefact
import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.framework.Operation
import com.rigiresearch.lcastane.framework.Operation.OperationType
import com.rigiresearch.lcastane.framework.Rule
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.util.Map
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import co.migueljimenez.devops.mart.infrastructure.terraform.TerraformPreprocessor
import com.rigiresearch.lcastane.framework.MART
import co.migueljimenez.devops.mart.infrastructure.operations.RemoveResource

/**
 * Represents an inventory of infrastructure resources.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
@ToString
class Infrastructure implements Artefact {

	/**
	 * The decorated model.
	 */
	@Accessors
	var VirtualInfrastructure model

	/**
     * The supported operations on this infrastructure.
     */
    val Map<OperationType, Operation<Infrastructure>> operations

	/**
	 * A Serialization parser.
	 */
	val SerializationParser serializationParser

	/**
	 * This artefact's parent.
	 */
	@Accessors
	var MART<?, ?> parent

	/**
	 * Default constructor.
	 * @param model An instance of the Infrastructure (Ecore) model
	 */
	new(VirtualInfrastructure model) {
		this.model = model
		this.operations = <OperationType, Operation<Infrastructure>>newHashMap
		this.operations.put(
			InfrastructureModelOp.ADD_RESOURCE,
			new AddResource(new TerraformPreprocessor)
				.addRule(
					Rule.Type.PRE,
					// Ecore objects serialized as XMI
					new TypesValidation(String)
				)
		)
		this.operations.put(
			InfrastructureModelOp.REMOVE_RESOURCE,
			new RemoveResource()
				.addRule(
					Rule.Type.PRE,
					// The element's name, the element's type
					new TypesValidation(String, String)
				)
		)
		this.serializationParser = new SerializationParser
	}

	/**
	 * Secondary constructor.
	 */
	new() {
		this(new InfrastructureModelElements().infrastructure)
	}

	/**
	 * Serialize the Ecore model decorated by this artefact.
	 */
	def String serialize() {
		this.serializationParser.asXml(this.model)
	}

	override apply(Command command) throws ValidationException {
		this.operations
            .get(command.operationType)
            .apply(this, command.arguments)
	}

	override name() '''«Infrastructure.simpleName»'''
	
	override setMart(MART<?, ?> parent) {
		this.parent = parent
	}
}
