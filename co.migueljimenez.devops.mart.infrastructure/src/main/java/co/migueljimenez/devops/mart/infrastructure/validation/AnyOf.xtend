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
package co.migueljimenez.devops.mart.infrastructure.validation

import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import com.rigiresearch.lcastane.framework.Rule

/**
 * Composed rule that evaluates to {@code true} if at least one of the
 * composing rules evaluates to {@code true}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class AnyOf implements Rule<Infrastructure> {

	/**
	 * The alternative rules.
	 */
	val Rule<Infrastructure>[] rules

	/**
	 * Default constructor.
	 * @param type This rule's type
	 * @param rules The composing rules
	 */
	new(Rule<Infrastructure>... rules) {
		super()
		this.rules = rules
	}

	override apply(Infrastructure artefact, Object... arguments) {
		this.rules.map[r|r.apply(artefact, arguments)].findFirst[b|b]
	}

	override errorMessage() '''None of the alternative rules was successful'''

	override name() '''«AnyOf.simpleName»(«this.rules.map[r|r.name].join(", ")»)'''
}
