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
class TerraformValidationTest {

	@Inject
	ParseHelper<Template> parseHelper

	@Inject extension ValidationTestHelper

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
		template.assertNoErrors
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
		template.assertNoErrors
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

	@Test
	def void implicitAttributeReference() {
		val template = parseHelper.parse('''
			resource "openstack_networking_router_v2" "terraform" {
				name                = "terraform"
				admin_state_up      = "true"
			}
			resource "openstack_networking_router_interface_v2" "terraform" {
			  router_id = "${openstack_networking_router_v2.terraform.id}"
			}
			''')
		Assert.assertNotNull(template)
		template.assertWarning(
			TerraformPackage.Literals.RESOURCE_REFERENCE,
			TerraformValidator.IMPLICIT_ATTRIBUTE_REFERENCE
		)
	}

	@Test
	def void knownFunction() {
		val template = parseHelper.parse('''
			resource "openstack_compute_keypair_v2" "terraform" {
				name       = "terraform"
				public_key = "${file("f.pub")}"
			}
			''')
		Assert.assertNotNull(template)
		template.assertNoErrors
	}

	@Test
	def void unknownFunction() {
		val template = parseHelper.parse('''
			resource "openstack_compute_keypair_v2" "terraform" {
				name       = "terraform"
				public_key = "${unknown("f.pub")}"
			}
			''')
		Assert.assertNotNull(template)
		template.assertError(
			TerraformPackage.Literals.FUNCTION_CALL,
			TerraformValidator.UNKNOWN_FUNCTION
		)
	}
	
}