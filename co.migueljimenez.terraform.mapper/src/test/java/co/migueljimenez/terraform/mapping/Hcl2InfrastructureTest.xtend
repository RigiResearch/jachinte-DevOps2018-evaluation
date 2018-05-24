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
package co.migueljimenez.terraform.mapping

import org.junit.Test
import org.junit.Assert

/**
 * Tests {@link Hcl2Infrastructure}
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class Hcl2InfrastructureTest {

	/**
	 * The translator instance being tested.
	 */
	val Hcl2Infrastructure translator

	/**
	 * An inverse translator to test round-trip translation.
	 */
	val Infrastructure2Hcl inverseTranslator

	new() {
		this.translator = new Hcl2Infrastructure
		this.inverseTranslator = new Infrastructure2Hcl
	}

	@Test
	def void input() {
		val source = '''
		variable "image" {
			default = "Ubuntu 14.04"
		}'''
		val specification = new Text2Hcl(source).model
		val model = this.translator.model(specification)
		#[
			model.credentials,
			model.flavors,
			model.images,
			model.instances,
			model.networks,
			model.securityGroups,
			model.volumes
		].forEach[l|Assert.assertTrue(l.size == 0)]
		Assert.assertTrue(model.resources.size == 1)
		Assert.assertEquals("variable", model.resources.get(0).resourceType)
		Assert.assertEquals("image", model.resources.get(0).name)
		// Round-trip test
		val text = new Hcl2Text().source(this.inverseTranslator.specification(model))
		Assert.assertEquals(source, text)
	}

	@Test
	def void credential() {
		val source = '''
		resource "openstack_compute_keypair_v2" "terraform" {
			name = "terraform"
			public_key = "${file("~/.ssh/id_rsa.terraform.pub")}"
		}'''
		val specification = new Text2Hcl(source).model
		val model = this.translator.model(specification)
		#[
			model.flavors,
			model.images,
			model.instances,
			model.networks,
			model.resources,
			model.securityGroups,
			model.volumes
		].forEach[l|Assert.assertTrue(l.size == 0)]
		Assert.assertTrue(model.credentials.size == 1)
		// Round-trip test
		val text = new Hcl2Text().source(this.inverseTranslator.specification(model))
		Assert.assertEquals(source, text)
	}

	@Test
	def void flavor() {
		val source = '''
		resource "openstack_compute_flavor_v2" "small" {
			name = "small"
			ram = 8096
			vcpus = 2
			disk = 20
		}'''
		val specification = new Text2Hcl(source).model
		val model = this.translator.model(specification)
		#[
			model.credentials,
			model.images,
			model.instances,
			model.networks,
			model.resources,
			model.securityGroups,
			model.volumes
		].forEach[l|Assert.assertTrue(l.size == 0)]
		Assert.assertTrue(model.flavors.size == 1)
		// Round-trip test
		val text = new Hcl2Text().source(this.inverseTranslator.specification(model))
		Assert.assertEquals(source, text)
	}

	@Test
	def void image() {
		val source = '''
		resource "openstack_images_image_v2" "rancher-os" {
			name = "rancher-os"
			container_format = "bare"
			disk_format = "ari"
			image_source_url = "https://image"
			min_disk_gb = 1
			min_ram_mb = 1024
		}'''
		val specification = new Text2Hcl(source).model
		val model = this.translator.model(specification)
		#[
			model.credentials,
			model.flavors,
			model.instances,
			model.networks,
			model.resources,
			model.securityGroups,
			model.volumes
		].forEach[l|Assert.assertTrue(l.size == 0)]
		Assert.assertTrue(model.images.size == 1)
		// Round-trip test
		val text = new Hcl2Text().source(this.inverseTranslator.specification(model))
		Assert.assertEquals(source, text)
	}

	@Test
	def void volume() {
		val source = '''
		resource "openstack_images_image_v2" "rancher-os" {
			name = "rancher-os"
			container_format = "bare"
			disk_format = "ari"
			image_source_url = "https://image"
			min_disk_gb = 1
			min_ram_mb = 1024
		}
		resource "openstack_blockstorage_volume_v2" "volume_1" {
			name = "volume_1"
			description = "first test volume"
			image_id = "${openstack_images_image_v2.rancher-os.id}"
			size = 5
		}'''
		val specification = new Text2Hcl(source).model
		val model = this.translator.model(specification)
		#[
			model.credentials,
			model.flavors,
			model.instances,
			model.networks,
			model.resources,
			model.securityGroups
		].forEach[l|Assert.assertTrue(l.size == 0)]
//		Assert.assertTrue(model.images.size == 1)
//		Assert.assertTrue(model.volumes.size == 1)
		// Round-trip test
//		val text = new Hcl2Text().source(this.inverseTranslator.specification(model))
//		Assert.assertEquals(source, text)
	}
}