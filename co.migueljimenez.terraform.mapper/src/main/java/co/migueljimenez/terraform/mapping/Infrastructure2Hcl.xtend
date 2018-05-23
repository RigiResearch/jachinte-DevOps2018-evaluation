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

import co.migueljimenez.terraform.hcl.model.HclModelElements
import co.migueljimenez.terraform.hcl.model.KeyValuePair
import co.migueljimenez.terraform.hcl.model.Resource
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.hcl.model.Value
import co.migueljimenez.terraform.infrastructure.model.Credential
import co.migueljimenez.terraform.infrastructure.model.Flavor
import co.migueljimenez.terraform.infrastructure.model.Image
import co.migueljimenez.terraform.infrastructure.model.Instance
import co.migueljimenez.terraform.infrastructure.model.SecurityGroup
import co.migueljimenez.terraform.infrastructure.model.UnknownResource
import co.migueljimenez.terraform.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.terraform.infrastructure.model.Volume
import de.xn__ho_hia.storage_unit.StorageUnit
import java.text.DecimalFormat
import java.util.List
import org.eclipse.emf.ecore.EObject

/**
 * Maps the elements from {@link VirtualInfrastructure} to
 * {@link Specification}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-04
 * @version $Id$
 * @since 0.0.1
 */
class Infrastructure2Hcl {

	/**
	 * Elements creator for the HCL model.
	 */
	val HclModelElements h

	/**
	 * Default constructor.
	 */
	new() {
		this.h = new HclModelElements
	}

	/**
	 * Maps the elements from an infrastructure model to HCL.
	 * @param model the infrastructure model
	 * @return the code representation of the model in HCL
	 */
	def Specification specification(VirtualInfrastructure model) {
		val resources = #[
			model.credentials,
			model.flavors,
			model.volumes,
			model.images,
			model.securityGroups,
			model.instances,
			model.resources
		].flatten
		this.h.specification(resources.map[r|r.resources].flatten)
	}

	/**
	 * Maps an object from {@link VirtualInfrastructure} to a list of
	 * {@link Specification} resources.
	 */
	def private List<Resource> resources(EObject object) {
		switch (object) {
			Credential: object.resources
			Flavor: object.resources
			Image: object.resources
			Instance: object.resources
			SecurityGroup: object.resources
			Volume: object.resources
			UnknownResource<String, Object>: object.resources
		}
	}

	/**
	 * Maps a {@link Credential} to an OpenStack Compute KeyPair.
	 */
	def private List<Resource> resources(Credential object) {
		#[h.resource(
			"data",
			"openstack_compute_keypair_v2",
			object.name,
			h.dictionary(
				null,
				h.entry("name", h.text(object.name)),
				h.entry("public_key", h.text(object.publicKey))
			)
		)]
	}

	/**
	 * Maps a {@link Flavor} to an OpenStack Compute Flavor.
	 */
	def private List<Resource> resources(Flavor object) {
		#[h.resource(
			"data",
			"openstack_compute_flavor_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("ram", h.number(object.ram.asMbString)),
					h.entry("vcpus", h.number('''«object.vcpus»''')),
					h.entry("disk", h.number(object.disk.asGbString))
				]
			)
		)]
	}

	/**
	 * Maps a {@link Volume} to an OpenStack BlockStorage Volume.
	 */
	def private List<Resource> resources(Volume object) {
		#[h.resource(
			"resource",
			"openstack_blockstorage_volume_v2",
			object.name,
			h.dictionary(
				null,
				h.entry("name", h.text(object.name)),
				h.entry("image_id", h.text(object.image.id)),
				h.entry("size", h.text(object.size.asGbString))
			)
		)]
	}

	/**
	 * Maps a {@link SecurityGroup} to an OpenStack Compute Security Group.
	 */
	def private List<Resource> resources(SecurityGroup object) {
		val List<KeyValuePair<String, Value>> entries = object.rules.map[ rule |
			h.<String, Value>entry(
				"rule",
				h.<Value>dictionary(
					"rule",
					h.entry("from_port", h.number('''«rule.from»''')),
					h.entry("to_port", h.number('''«rule.to»''')),
					h.entry("ip_protocol", h.number(rule.protocol)),
					h.entry("cidr", h.text(rule.cidr))
				)
			)
		]
		entries.add(h.entry("name", h.text(object.name)))
		#[h.resource(
			"resource",
			"openstack_compute_secgroup_v2",
			object.name,
			h.dictionary(
				null,
				entries
			)
		)]
	}

	/**
	 * Maps an {@link Image} to an OpenStack Image.
	 */
	def private List<Resource> resources(Image object) {
		#[h.resource(
			"data",
			"openstack_images_image_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("name", h.text(object.name)),
					h.entry("container_format", h.text(object.containerFormat.literal)),
					h.entry("disk_format", h.text(object.diskFormat.literal)),
					h.entry("image_source_url", h.text(object.imageSourceUrl)),
					h.entry("min_disk_gb", h.number(object.minDisk.asGbString)),
					h.entry("min_ram_mb", h.number(object.minRam.asMbString))
				]
			)
		)]
	}

	/**
	 * Maps an {@link Instance} to an OpenStack Compute Instance and its
	 * corresponding volume.
	 */
	def private List<Resource> resources(Instance object) {
		val List<KeyValuePair<String, Value>> entries = newArrayList(
			h.<String, Value>entry("name", h.text(object.name)),
			h.<String, Value>entry("flavor_id", h.text(object.flavor.id)),
			h.<String, Value>entry("key_pair", h.text(object.credential.name))
		)
		val securityGroups = h.<String, Value>entry(
			"security_groups",
			h.list(
				object.securityGroups.map [ group |
					h.expression(
						h.resourceRef(
							"openstack_compute_secgroup_v2",
							group.name,
							group.name
						)
					)
				]
			)
		)
		val networks = object.networks.map[ network |
			h.<String, Value>entry(
				"network",
				h.dictionary(
					"network",
					h.entry("name", h.text(network.name))
				)
			)
		]
		entries.addAll(securityGroups)
		entries.addAll(networks)
		#[
			h.resource(
				"resource",
				"openstack_compute_instance_v2",
				object.name,
				h.dictionary(null, entries)
			),
			h.resource(
				"resource",
				"openstack_compute_volume_attach_v2",
				'''«object.name»_«object.volume.name»''',
				h.dictionary(
					null,
					#[
						h.entry(
							"compute_id",
							h.expression(
								h.resourceRef("openstack_compute_instance_v2", object.name, "id")
							)
						),
						h.entry(
							"volume_id",
							h.expression(
								h.resourceRef("openstack_blockstorage_volume_v2", object.volume.name, "id")
							)
						)
					]
				)
			)
		]
	}

	/**
	 * Maps an {@link UnknownResource} to a generic resource.
	 */
	def private List<Resource> resources(UnknownResource<String, Object> object) {
		val attributes = newArrayList
		attributes.addAll(
			object.attributes.elements.map[ p |
				val value = p.value
				h.entry(
					p.key,
					switch (value) {
						String: h.text(value.toString)
						Number: h.number(value.toString)
						Boolean: h.bool(value)
						// TODO support complex types: lists and dictionaries
					}
				)
			]
		)
		#[h.resource(
			object.resourceType,
			object.type,
			object.name,
			h.dictionary(
				null,
				attributes
			)
		)]
	}

	/**
	 * @return the quantity in Megabytes as a String
	 */
	def private asMbString(StorageUnit<?> quantity) {
		val format = new DecimalFormat("0.00")
		format.format(quantity.asMegabyte.inMegabyte)
	}

	/**
	 * @return the quantity in Gigabytes as a String
	 */
	def private asGbString(StorageUnit<?> quantity) {
		val format = new DecimalFormat("0.00")
		format.format(quantity.asGigabyte.inGigabyte)
	}
}