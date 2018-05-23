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
package co.migueljimenez.terraform.mapper

import co.migueljimenez.terraform.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.terraform.hcl.model.Input
import co.migueljimenez.terraform.hcl.model.Output
import co.migueljimenez.terraform.hcl.model.Resource
import co.migueljimenez.terraform.hcl.model.Value

/**
 * Maps the elements from {@link Specification} to
 * {@link VirtualInfrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-22
 * @version $Id$
 * @since 0.0.1
 */
class Specification2Infrastructure {

	/**
	 * Elements creator for the Virtual Infrastructure model.
	 */
	val InfrastructureModelElements i

	/**
	 * Default constructor.
	 */
	new() {
		this.i = new InfrastructureModelElements
	}

	/**
	 * Maps the elements from a Terraform (HCL) specification to the
	 * infrastructure model.
	 * @param specification the specification
	 */
	def VirtualInfrastructure model(Specification specification) {
		// To consider: volume attachments are special resources because
		// they affect how the model is instantiated
		val flavors = newArrayList
		val images = newArrayList
		val instances = newArrayList
		val networks = newArrayList
		val volumes = newArrayList
		val otherResources = newArrayList
		specification.resources.map [ resource |
			switch (resource) {
				Input: {
					otherResources.add(
						this.i.unknownResource(
							"variable",
							null,
							resource.name,
							#[
								this.i.entry("default", resource.^default.unwrap)
							]
						)
					)
				}
				Output: {
					resource.name
				}
				Resource: {
					resource.name
				}
			}
		]
		this.i.infrastructure(
			flavors, images, instances, networks, volumes, otherResources
		)
	}

	def protected Object unwrap(Value value) {
		
	}

}