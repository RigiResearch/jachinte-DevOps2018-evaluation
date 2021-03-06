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

import co.migueljimenez.devops.infrastructure.model.ContainerFormat
import co.migueljimenez.devops.infrastructure.model.DiskFormat
import co.migueljimenez.devops.infrastructure.model.Flavor
import co.migueljimenez.devops.infrastructure.model.Image
import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.Instance
import co.migueljimenez.devops.infrastructure.model.ModelFactory
import co.migueljimenez.devops.infrastructure.model.UnknownResource
import co.migueljimenez.devops.infrastructure.model.Volume
import de.xn__ho_hia.storage_unit.StorageUnits
import org.junit.Assert
import org.junit.Test
import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure

/**
 * Tests {@link Infrastructure2Hcl}
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-18
 * @version $Id$
 * @since 0.0.1
 */
class Infrastructure2HclTest {

	/**
	 * Helper to instantiate the infrastructure model.
	 */
	val InfrastructureModelElements i

	/**
	 * The translator instance being tested.
	 */
	val Infrastructure2Hcl translator

	/**
	 * The HCL-to-text translator.
	 */
	val Hcl2Text textTranslator

	/**
	 * Dummy project.
	 */
	val VirtualInfrastructure project

	/**
	 * Dummy flavor for testing purposes.
	 */
	val Flavor flavor

	/**
	 * Dummy image for testing purposes.
	 */
	val Image image

	/**
	 * Dummy volume for testing purposes.
	 */
	val Volume volume

	/**
	 * Dummy instance for testing purposes.
	 */
	val Instance instance

	/**
	 * Dummy resource for testing purposes.
	 */
	val UnknownResource<String, Object> provider

	new() {
		this.i = new InfrastructureModelElements
		this.translator = new Infrastructure2Hcl
		this.textTranslator = new Hcl2Text
		this.project = this.i.infrastructure
		this.flavor = this.i.flavor(
			"flavor-id",
			"small",
			1,
			StorageUnits.gigabyte(4),
			StorageUnits.megabyte(512),
			this.project
		)
		this.image = this.i.image(
			"image-id",
			"rancher-os",
			ContainerFormat.BARE,
			DiskFormat.ARI,
			"https://image",
			StorageUnits.gigabyte(1),
			StorageUnits.megabyte(1024),
			this.project
		)
		this.volume = this.i.volume(
			"volue-id",
			"myvolume",
			null,
			this.image,
			StorageUnits.gigabyte(5),
			this.project
		)
		this.instance = this.i.instance(
			"instance-id",
			"basic",
			this.i.credential(
				"access",
				"public-key",
				this.project
			),
			this.flavor,
			#[this.volume],
			#[],
			#[],
			this.project
		)
		this.provider = this.i.unknownResource(
			"provider",
			null,
			"openstack",
			#[
				this.i.entry("user_name", "admin"),
				this.i.entry("tenant_name", "admin"),
				this.i.entry("password", "pwd"),
				this.i.entry("auth_url", "http://myauthurl:5000/v2.0"),
				this.i.entry("region", "RegionOne")
			],
			this.project
		)
	}

	@Test
	def void image() {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.images.add(this.image)
		val specification = this.translator.specification(infrastructure)
		val text = this.textTranslator.source(specification)
		Assert.assertEquals('''
		resource "openstack_images_image_v2" "rancher-os" {
			name = "rancher-os"
			container_format = "bare"
			disk_format = "ari"
			image_source_url = "https://image"
			min_disk_gb = 1
			min_ram_mb = 1024
		}'''.toString, text)
	}

	@Test
	def void flavor() {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.flavors.add(this.flavor)
		val specification = this.translator.specification(infrastructure)
		val text = this.textTranslator.source(specification)
		Assert.assertEquals('''
		resource "openstack_compute_flavor_v2" "small" {
			name = "small"
			ram = 512
			vcpus = 1
			disk = 4
		}'''.toString, text)
	}

	@Test
	def void instance() {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.instances.add(this.instance)
		val specification = this.translator.specification(infrastructure)
		val text = this.textTranslator.source(specification)
		Assert.assertEquals('''
		resource "openstack_compute_instance_v2" "basic" {
			name = "basic"
			flavor_id = "${openstack_compute_flavor_v2.small.id}"
			key_pair = "${openstack_compute_keypair_v2.access.name}"
		}
		resource "openstack_compute_volume_attach_v2" "basic_myvolume" {
			compute_id = "${openstack_compute_instance_v2.basic.id}"
			volume_id = "${openstack_blockstorage_volume_v2.myvolume.id}"
		}'''.toString, text)
	}

	@Test
	def void unknownResource() {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.resources.add(this.provider)
		val specification = this.translator.specification(infrastructure)
		val text = this.textTranslator.source(specification)
		Assert.assertEquals('''
		provider "openstack" {
			user_name = "admin"
			tenant_name = "admin"
			password = "pwd"
			auth_url = "http://myauthurl:5000/v2.0"
			region = "RegionOne"
		}'''.toString, text)
	}	
}
