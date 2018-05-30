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
package co.migueljimenez.devops.mart.infrastructure.rules

import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import com.rigiresearch.lcastane.framework.Rule
import java.util.Arrays

/**
 * Checks whether the operands passed to an operation are of the expected type.
 * This rule applies to any {@link Node}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class TypesValidation implements Rule<Infrastructure> {

	/**
	 * Expected operand types.
	 */
	val Class<?>[] operandTypes

	/**
	 * Default constructor.
	 * @param operandTypes The expected operand types
	 */
	new(Class<?>... operandTypes) {
		super()
		this.operandTypes = operandTypes
	}

	/**
	 * Error message in case of failure.
	 */
	var String message = new String()

	override apply(Infrastructure artefact, Object... arguments) {
		this.message = String.format(
			"Given arguments (%s) differ from expected (%s)",
			Arrays.toString(arguments),
			Arrays.toString(this.operandTypes)
		)
        return Arrays.equals(
			this.operandTypes,
			arguments.map[operand|operand.getClass()].toArray
        )
	}

	override errorMessage() '''«this.message»'''

	override name() '''«TypesValidation.simpleName»'''

	override type() {
		Rule.Type.PRE
	}
}
