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
import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.infrastructure.model.Image
import org.eclipse.emf.ecore.EObject
import co.migueljimenez.devops.infrastructure.model.SecurityGroup
import org.slf4j.LoggerFactory

/**
 * Removes an existing resource from the {@link Infrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-07-01
 * @version $Id$
 * @since 0.0.1
 */
class RemoveResource extends AbstractOperation {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(RemoveResource)

	/**
	 * Default constructor.
	 */
	new() {
		super(InfrastructureModelOp.REMOVE_RESOURCE)
	}

	override protected applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException {
		// Arguments: the element's name, the element's type
		val name = arguments.get(0) as String
		val type = arguments.get(1) as String
		var EObject eObject = null
		val commands = newArrayList
		// FIXME move this terraform-specific code somewhere else
		switch (type) {
			case Credential.canonicalName: {
				// Credentials may be associated with instances, however, OpenStack
				// won't remove the credential if such link exists.
				eObject = infrastructure.model.credentials.findFirst[c|name.equals(c.name)]
				commands.add('''terraform state rm openstack_compute_keypair_v2.«name»''')
				commands.add('''rm -f .keys/«name».pem''')
			}
			case Image.canonicalName: {
				eObject = infrastructure.model.images.findFirst[i|name.equals(i.name)]
				commands.add('''terraform state rm openstack_images_image_v2.«name»''')
			}
			case SecurityGroup.canonicalName: {
				// We have to use the id to find the group, as the name is not available anymore
				// i.e., name is actually the id
				eObject = infrastructure.model.securityGroups.findFirst[s|name.equals(s.id)]
				commands.add('''terraform state rm openstack_compute_secgroup_v2.«(eObject as SecurityGroup).name»''')
			}
			default:
				throw new UnsupportedOperationException('''Resource not supported «type»''')
		}
		if (eObject !== null) {
			EcoreUtil.remove(eObject)
			val spec = this.getFileSpec(infrastructure.parent.specification)
			if (spec !== null) {
				commands.forEach [ c |
					val file = (spec as FileSpecification).file
					TerraformSpecification.deferCommand(file, c)
				]
			}
		} else {
			this.logger.error('''Resource «name» could not be deleted because it was not found''')
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
