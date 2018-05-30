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
package co.migueljimenez.devops.mart.infrastructure.operations

import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import com.rigiresearch.lcastane.framework.Rule
import com.rigiresearch.lcastane.framework.validation.ValidationException

/**
 * Adds a new resource to the {@link Infrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class AddResource extends AbstractOperation {

	/**
	 * Default constructor.
	 * @param rules The validation rules that should be applied before/after
     *  this operation
	 */
	new(Rule<Infrastructure>... rules) {
		super(rules, InfrastructureModelOp.ADD_RESOURCE)
	}

	override protected applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException {
		val operand = arguments.get(0)
		// TODO support all the resource types
		switch (operand) {
			Credential: {
				infrastructure.model.credentials.add(operand)
			}
			default: println('''Unsupported resource type "«operand»"''')
		}
	}
}
