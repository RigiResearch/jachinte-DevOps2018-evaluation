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
import com.rigiresearch.lcastane.framework.validation.ValidationException
import org.eclipse.emf.ecore.util.EcoreUtil
import com.rigiresearch.lcastane.framework.Specification
import com.rigiresearch.lcastane.framework.impl.ObservableSpecification
import com.rigiresearch.lcastane.framework.impl.GithubSpecification
import com.rigiresearch.lcastane.framework.impl.FileSpecification
import co.migueljimenez.devops.mart.infrastructure.terraform.TerraformSpecification

/**
 * Removes an existing resource from the {@link Infrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-07-01
 * @version $Id$
 * @since 0.0.1
 */
class RemoveResource extends AbstractOperation {

	/**
	 * Default constructor.
	 */
	new() {
		super(InfrastructureModelOp.REMOVE_CREDENTIAL)
	}

	override protected applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException {
		// Arguments: the credential's name
		val name = arguments.get(0) as String
		val credential = infrastructure.model.credentials.findFirst[c|c.name.equals(name)]
		if (credential !== null) {
			// Credentials may be associated with instances, however, OpenStack
			// won't remove the credential if such link exists.
			EcoreUtil.remove(credential)
			val spec = this.getFileSpec(infrastructure.parent.specification)
			if (spec !== null) {
				// FIXME move this terraform-specific code somewhere else
				// Defer the resource removal until the specification is updated
				TerraformSpecification.deferCommand(
					(spec as FileSpecification).file,
					'''terraform state rm openstack_compute_keypair_v2.«name»'''
				)
				TerraformSpecification.deferCommand(
					(spec as FileSpecification).file,
					'''rm -f .keys/«name».pem'''
				)	
			}
		}
	}

	def private Specification getFileSpec(Specification spec) {
		switch (spec) {
			ObservableSpecification<?>: {
				getFileSpec(spec.origin)
			}
			GithubSpecification: {				
				spec.origin
			}
			FileSpecification: {
				spec
			}
		}
	}
}
