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
import java.util.Map

/**
 * An abstract operation in the context of a {@link InfrastructureMart}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
abstract class AbstractOperation implements Operation<Infrastructure> {

	/**
     * This operation's validation rules.
     */
    val Map<Rule.Type, List<Rule<Infrastructure>>> rules

	/**
	 * This operation's type.
	 */
	val OperationType operationType

	new(OperationType operationType) {
		this.operationType = operationType
		this.rules = newHashMap
	}

	/**
	 * Adds a new rule to {@code this} operation.
	 */
	def addRule(Rule.Type type, Rule<Infrastructure> rule) {
		if (this.rules.containsKey(type))
			this.rules.put(type, newArrayList)
		this.rules.get(type).add(rule)
		return this
	}

	override apply(Infrastructure artefact, Object... operands)
		throws ValidationException {
		runRules(this.rules.get(Rule.Type.PRE), artefact, operands)
        this.applyOp(artefact, operands)
        runRules(this.rules.get(Rule.Type.POST), artefact, operands)
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
	 * @param rules The list of rules to run
	 * @param artefact The artefact
	 * @param arguments This operation's arguments
     * @throws ValidationException If there is at least one failing rule
	 */
	def private void runRules(List<Rule<Infrastructure>> rules,
		Infrastructure artefact, Object... arguments)
			throws ValidationException {
		if (rules === null || rules.empty)
			return;
		val filtered = rules.filter[rule|!rule.apply(artefact, arguments)]
            if (!filtered.empty)
                throw new ValidationException(artefact, this, filtered.get(0))
    }
}
