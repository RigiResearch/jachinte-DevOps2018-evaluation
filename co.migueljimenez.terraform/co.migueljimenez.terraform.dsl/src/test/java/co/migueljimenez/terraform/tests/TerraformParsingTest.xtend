/*
 * generated by Xtext 2.14.0.RC1
 */
package co.migueljimenez.terraform.tests

import co.migueljimenez.terraform.terraform.Template
import co.migueljimenez.terraform.terraform.TerraformPackage
import co.migueljimenez.terraform.validation.TerraformValidator
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.Assert
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(TerraformInjectorProvider)
class TerraformParsingTest {

	@Inject
	ParseHelper<Template> parseHelper

	@Inject extension ValidationTestHelper

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

	@Test
	def void simpleDeclarations() {
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
			}
			''')
		Assert.assertNotNull(template)
		template.assertNoIssues
	}

	@Test
	def void variableReference() {
		val template = parseHelper.parse('''
			variable "external_gateway" {}
			resource "openstack_networking_router_v2" "terraform" {
				name                = "terraform"
				admin_state_up      = "true"
				external_network_id = "${var.external_gateway}"
			}
			''')
		Assert.assertNotNull(template)
		template.assertNoIssues
	}

	@Test
	def void unknownResource() {
		val template = parseHelper.parse('''
			unknown "openstack_networking_router_v2" "terraform" {
				name                = "terraform"
				admin_state_up      = "true"
			}
			''')
		Assert.assertNotNull(template)
		template.assertError(
			TerraformPackage.Literals.DECLARATION,
			TerraformValidator.INVALID_DECLARATION
		)
	}

	@Test
	def void unknownVariable() {
		val template = parseHelper.parse('''
			resource "openstack_networking_router_v2" "terraform" {
				name                = "terraform"
				admin_state_up      = "true"
				external_network_id = "${var.external_gateway}"
			}
			''')
		Assert.assertNotNull(template)
		template.assertError(
			TerraformPackage.Literals.RESOURCE_REFERENCE,
			TerraformValidator.UNKNOWN_RESOURCE_REFERENCE
		)
	}
}
