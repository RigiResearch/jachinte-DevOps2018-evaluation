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

import org.eclipse.emf.ecore.EObject
import java.io.File

/**
 * Notation-specific behavior to pre-process elements of the Infrastructure
 * model before adding them to the model.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-22
 * @version $Id$
 * @since 0.0.1
 */
interface SpecificationPreprocessor {

	/**
	 * Process the model element before adding it to the model.
	 * @param element The new model element
	 * @param specificationFile The specification file associated with the
	 *  model element
	 */
	def void preprocess(EObject element, File specificationFile);

	/**
	 * Null implementation of this interface.
	 * @author Miguel Jimenez (miguel@uvic.ca)
	 * @date 2018-06-22
	 * @version $Id$
	 * @since 0.0.1
	 */
	static class NullImpl implements SpecificationPreprocessor {
		override preprocess(EObject element, File specificationFile) {
			// Do nothing
		}
	}
}
