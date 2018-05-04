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
package co.migueljimenez.terraform.hcl.model

import org.junit.Assert
import org.junit.Test

/**
 * Tests {@link TextualHclModel}
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class TextualHclModelTest {

	val f = ModelFactory.eINSTANCE

	@Test
	def void asText() {
		val variable = f.createInput
		variable.name = "image"
		variable.^default = this.text("Ubuntu 14.04")

		val output = f.createOutput
		val expr = f.createTextExpression
		expr.expression = this.ref("openstack_compute_floatingip_v2", "terraform", "address")
		output.name = "address"
		output.value = expr

		val resource = f.createResource
		resource.resourceType = "resource"
		resource.type = "openstack_networking_router_interface_v2"
		resource.name = "terraform"
		resource.attributes = f.<Value>createDictionary
		resource.attributes.elements.put("router_id", this.text("ABC"))
		resource.attributes.elements.put("subnet_id", this.text("DEF"))
		resource.dependsOn.add(this.ref("openstack_networking_router_interface_v2", "terraform"))

		val specification = f.createSpecification
		specification.resources.add(variable)
		specification.resources.add(resource)
		specification.resources.add(output)
		
		val text = new TextualHclModel(specification).asText
		val expected = '''var "image" {
	default = "Ubuntu 14.04"
}
resource "openstack_networking_router_interface_v2" "terraform" {
	router_id = "ABC"
	subnet_id = "DEF"
}
output "address" {
	sensitive = false
	value = ${openstack_compute_floatingip_v2.terraform.address}
}
'''
		Assert.assertEquals(text, expected)
	}

	def private ref(String... elements) {
		val reference = f.createResourceReference
		reference.fullyQualifiedName.addAll(elements)
		return reference
	}

	def private text(String contents) {
		val text = f.createText
		text.value = contents
		return text
	}
	
}