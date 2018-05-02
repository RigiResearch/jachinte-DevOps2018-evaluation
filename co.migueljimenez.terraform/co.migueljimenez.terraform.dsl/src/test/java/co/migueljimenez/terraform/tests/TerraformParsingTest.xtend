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
package co.migueljimenez.terraform.tests

import co.migueljimenez.terraform.terraform.Template
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

 /**
 * Tests the model parser.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-02
 * @version $Id$
 * @since 0.0.1
 */
@RunWith(XtextRunner)
@InjectWith(TerraformInjectorProvider)
class TerraformParsingTest {

	@Inject
	ParseHelper<Template> parseHelper

	@Test
	def void loadModel() {
		val template = parseHelper.parse('''
			variable "external_gateway" {}
			resource "aws_db_instance" "timeout_example" {
				allocated_storage = 10
				engine            = "mysql"
				engine_version    = "5.6.17"
				instance_class    = "db.t1.micro"
				name              = "mydb"
				timeouts {
					create = "60m"
					delete = "2h"
				}
			}
			resource "openstack_networking_router_v2" "terraform" {
				name             = "terraform"
				admin_state_up   = "true"
				external_network_id = "${var.external_gateway}"
			}
			output "router_id" {
				value = "${openstack_networking_router_v2.terraform.id}"
			}
			''')
		Assert.assertNotNull(template)
		val errors = template.eResource.errors
		Assert.assertTrue('''Unexpected errors: «errors.join(", ")»''', errors.isEmpty)
	}
}
