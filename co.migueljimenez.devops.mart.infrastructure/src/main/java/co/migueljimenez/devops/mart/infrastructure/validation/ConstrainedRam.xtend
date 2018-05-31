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
import de.xn__ho_hia.storage_unit.StorageUnit

/**
 * Checks that no VM instance is given more than the allowed RAM.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
class ConstrainedRam implements Rule<Infrastructure> {

	/**
	 * The maximum allowed RAM.
	 */
	val StorageUnit<?> maxRam

	/**
	 * An error message in case of failure.
	 */
	var String errorMessage

	/**
	 * Default constructor.
	 */
	new(StorageUnit<?> maxRam) {
		this.maxRam = maxRam
		this.errorMessage = new String()
	}

	override apply(Infrastructure artefact, Object... arguments) {
		artefact.model.instances
			.map[i|i.flavor.ram.compareTo(this.maxRam) <= 0]
			.reduce[b1, b2| b1 && b2]
	}

	override errorMessage() '''«this.errorMessage»'''

	override name() '''«ConstrainedRam.simpleName»'''
}
