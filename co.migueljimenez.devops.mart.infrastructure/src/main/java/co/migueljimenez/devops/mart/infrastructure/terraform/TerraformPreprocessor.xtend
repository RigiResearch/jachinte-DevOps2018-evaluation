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
package co.migueljimenez.devops.mart.infrastructure.terraform

import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.mart.infrastructure.operations.SpecificationPreprocessor
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.emf.ecore.EObject

/**
 * Terraform-specific behavior to pre-process elements from the Infrastructure
 * model.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-22
 * @version $Id$
 * @since 0.0.1
 */
class TerraformPreprocessor implements SpecificationPreprocessor {

	override preprocess(EObject element, File specificationFile) {
		switch (element) {
			Credential:
				this.preprocess(element, specificationFile)
			default:
				throw new UnsupportedOperationException('''Unsupported resource «element»''')
		}
	}

	def protected preprocess(Credential element, File specificationFile) {
		val file = new File(specificationFile.parentFile, '''.keys/«element.name».pem''')
		file.parentFile.mkdir // create the ".keys" directory in case it doesn't exist
		Files.write(Paths.get(file.toURI), element.publicKey.bytes)
		element.publicKey = '''${file("«file.parentFile.name»/«file.name»")}'''
		// Defer the resource import until the specification is updated
		TerraformSpecification.deferCommand(
			specificationFile,
			'''terraform import openstack_compute_keypair_v2.«element.name» «element.name»'''
		)
	}
}
