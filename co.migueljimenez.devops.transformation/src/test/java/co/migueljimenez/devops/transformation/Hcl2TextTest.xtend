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
package co.migueljimenez.devops.transformation

import co.migueljimenez.devops.hcl.model.HclModelElements
import co.migueljimenez.devops.hcl.model.Value
import org.junit.Assert
import org.junit.Test

/**
 * Tests {@link Hcl2Text}
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class Hcl2TextTest {

	@Test
	def void asText() {
		val e = new HclModelElements
		val variable = e.input("image", e.text("Ubuntu 14.04"))
		val resource = e.resource(
			"resource",
			"openstack_networking_router_interface_v2",
			"terraform",
			e.<Value>dictionary(null, #[
				e.entry("router_id", e.text("ABC")),
				e.entry("subnet_id", e.text("DEF")),
				e.entry("depends_on",
					e.list(#[
						e.text("openstack_networking_router_interface_v2.terraform")
					])
				),
				e.entry("public_key", e.expression(
					e.functionCall("file", e.text("~/.ssh/id_rsa.terraform.pub"))
				)),
				e.entry("provisioner", e.dictionary(
					"remote-exec",
					e.entry("inline", e.list(#[
						e.text("sudo apt-get -y update"),
						e.text("sudo apt-get -y install nginx")
					]))
				))
			])
		)
		val output = e.output(
			"address",
			e.expression(
				e.resourceRef(
					"openstack_compute_floatingip_v2",
					"terraform",
					"address"
				)	
			)
		)
		val specification = e.specification(variable, resource, output)
		val text = new Hcl2Text().source(specification)
		val expected = '''
		variable "image" {
			default = "Ubuntu 14.04"
		}
		resource "openstack_networking_router_interface_v2" "terraform" {
			router_id = "ABC"
			subnet_id = "DEF"
			depends_on = ["openstack_networking_router_interface_v2.terraform"]
			public_key = "${file("~/.ssh/id_rsa.terraform.pub")}"
			provisioner "remote-exec" {
				inline = ["sudo apt-get -y update", "sudo apt-get -y install nginx"]
			}
		}
		output "address" {
			sensitive = false
			value = "${openstack_compute_floatingip_v2.terraform.address}"
		}'''
		Assert.assertEquals(expected, text)
	}

}