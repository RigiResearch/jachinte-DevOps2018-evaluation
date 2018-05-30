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

import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import co.migueljimenez.devops.mart.infrastructure.InfrastructureMart
import com.rigiresearch.lcastane.framework.Operation
import com.rigiresearch.lcastane.framework.Rule
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.util.List
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

/**
 * An abstract operation in the context of a {@link InfrastructureMart}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
@FinalFieldsConstructor
abstract class AbstractOperation implements Operation<Infrastructure> {

	/**
     * This operation's validation rules.
     */
    val List<Rule<Infrastructure>> rules

	/**
	 * This operation's type.
	 */
	val OperationType operationType

	override apply(Infrastructure artefact, Object... operands)
		throws ValidationException {
		runRules(Rule.Type.PRE, artefact, operands)
        this.applyOp(artefact, operands)
        runRules(Rule.Type.POST, artefact, operands)
	}

	override type() {
		this.operationType
	}

	/**
	 * Executes the operation.
	 * @param infrastructure The artefact
	 * @param arguments This operation's arguments
	 * @throws ValidationException If there is at least one failing rule
	 */
	def protected abstract void applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException

	/**
	 * Executes the specified set of rules.
	 * @param type The type of rules to execute
	 * @param artefact The artefact
	 * @param arguments This operation's arguments
     * @throws ValidationException If there is at least one failing rule
	 */
	def private void runRules(Rule.Type type, Infrastructure artefact,
		Object... arguments) throws ValidationException {
		val filtered = this.rules
			.filter[rule|rule.type.equals(type)]
			.filter[rule|!rule.apply(artefact, arguments)]
            if (!filtered.empty)
                throw new ValidationException(artefact, this, filtered.get(0))
    }
}