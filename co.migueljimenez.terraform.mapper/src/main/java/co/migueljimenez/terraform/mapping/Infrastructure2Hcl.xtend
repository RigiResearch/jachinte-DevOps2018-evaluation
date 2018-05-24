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

import co.migueljimenez.terraform.dtos.FkDictionary
import co.migueljimenez.terraform.dtos.FkFunctionCall
import co.migueljimenez.terraform.dtos.FkResourceReference
import co.migueljimenez.terraform.dtos.FkTextExpression
import co.migueljimenez.terraform.hcl.model.HclModelElements
import co.migueljimenez.terraform.hcl.model.KeyValuePair
import co.migueljimenez.terraform.hcl.model.Reference
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
import co.migueljimenez.terraform.infrastructure.model.Subnet
import co.migueljimenez.terraform.infrastructure.model.Network

/**
 * Translates a {@link VirtualInfrastructure} to a {@link Specification}.
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
	 * Translates the elements from an infrastructure model to HCL.
	 * @param model the infrastructure model
	 * @return the code representation of the model in HCL
	 */
	def Specification specification(VirtualInfrastructure model) {
		// Order is dependency-wise
		val resources = #[
			model.credentials,
			model.flavors,
			model.volumes,
			model.networks,
			model.subnets,
			model.images,
			model.securityGroups,
			model.instances,
			model.resources
		].flatten
		this.h.specification(resources.map[r|r.resources].flatten)
	}

	/**
	 * Translates an object from {@link VirtualInfrastructure} to a list of
	 * {@link Specification} resources.
	 */
	def protected List<Resource> resources(EObject object) {
		switch (object) {
			Credential: object.resources
			Flavor: object.resources
			Image: object.resources
			Instance: object.resources
			Network: object.resources
			Subnet: object.resources
			SecurityGroup: object.resources
			Volume: object.resources
			UnknownResource<String, Object>: object.resources
		}
	}

	/**
	 * Translates a {@link Credential} to an OpenStack Compute KeyPair.
	 */
	def protected List<Resource> resources(Credential object) {
		#[h.resource(
			"resource",
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
	 * Translates a {@link Flavor} to an OpenStack Compute Flavor.
	 */
	def protected List<Resource> resources(Flavor object) {
		#[h.resource(
			"resource",
			"openstack_compute_flavor_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("name", h.text(object.name)),
					h.entry("ram", h.number(object.ram.asMbString)),
					h.entry("vcpus", h.number('''«object.vcpus»''')),
					h.entry("disk", h.number(object.disk.asGbString))
				]
			)
		)]
	}

	/**
	 * Translates a {@link Volume} to an OpenStack BlockStorage Volume.
	 */
	def protected List<Resource> resources(Volume object) {
		#[h.resource(
			"resource",
			"openstack_blockstorage_volume_v2",
			object.name,
			h.dictionary(
				null,
				h.entry("name", h.text(object.name)),
				h.entry("description", h.text(object.description)),
				h.entry("image_id", h.text(object.image.id)),
				h.entry("size", h.text(object.size.asGbString))
			)
		)]
	}

	/**
	 * Translates a {@link SecurityGroup} to an OpenStack Compute Security Group.
	 */
	def protected List<Resource> resources(SecurityGroup object) {
		val List<KeyValuePair<String, Value>> entries = newArrayList(
			object.rules.map[ rule |
				h.<String, Value>entry(
					"rule",
					h.<Value>dictionary(
						null,
						h.entry("from_port", h.number('''«rule.from»''')),
						h.entry("to_port", h.number('''«rule.to»''')),
						h.entry("ip_protocol", h.text(rule.protocol)),
						h.entry("cidr", h.text(rule.cidr))
					)
				)
			]
		)
		entries.add(h.entry("name", h.text(object.name)))
		entries.add(h.entry("description", h.text(object.description)))
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
	 * Translates an {@link Image} to an OpenStack Image.
	 */
	def protected List<Resource> resources(Image object) {
		#[h.resource(
			"resource",
			"openstack_images_image_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("name", h.text(object.name)),
					h.entry("description", h.text(object.description)),
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
	 * Translates an {@link Instance} to an OpenStack Compute Instance and its
	 * corresponding volumes.
	 */
	def protected List<Resource> resources(Instance object) {
		val List<KeyValuePair<String, Value>> entries = newArrayList(
			h.<String, Value>entry("name", h.text(object.name)),
			h.<String, Value>entry(
				"flavor_id",
				h.expression(
					h.resourceRef(
						"openstack_compute_flavor_v2",
						object.flavor.name,
						"id"
					)
				)
			),
			h.<String, Value>entry(
				"key_pair",
				h.expression(
					h.resourceRef(
						"openstack_compute_keypair_v2",
						object.credential.name,
						"name"
					)
				)
			)
		)
		val securityGroups = h.<String, Value>entry(
			"security_groups",
			h.list(
				object.securityGroups.map [ group |
					h.expression(
						h.resourceRef(
							"openstack_compute_secgroup_v2",
							group.name,
							"name"
						)
					)
				]
			)
		)
		val networks = object.networks.map [ network |
			h.<String, Value>entry(
				"network",
				h.dictionary(
					null,
					h.entry(
						"name",
						h.expression(
							h.resourceRef(
								"openstack_networking_network_v2",
								network.name,
								"name"
							)
						)
					)
				)
			)
		]
		entries.addAll(securityGroups)
		entries.addAll(networks)
		val resources = newArrayList
		resources.add(
			h.resource(
				"resource",
				"openstack_compute_instance_v2",
				object.name,
				h.dictionary(null, entries)
			)
		)
		resources.addAll(
			object.volumes.map [volume |
				h.resource(
					"resource",
					"openstack_compute_volume_attach_v2",
					'''«object.name»_«volume.name»''',
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
									h.resourceRef("openstack_blockstorage_volume_v2", volume.name, "id")
								)
							)
						]
					)
				)
			]
		)
		resources
	}

	/**
	 * Translates a {@link Network} to an OpenStack Compute Network.
	 */
	def protected List<Resource> resources(Network object) {
		#[h.resource(
			"resource",
			"openstack_networking_network_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("name", h.text(object.name))
				]
			)
		)]
	}

	/**
	 * Translates a {@link Subnet} to an OpenStack Compute Subnet.
	 */
	def protected List<Resource> resources(Subnet object) {
		#[h.resource(
			"resource",
			"openstack_networking_subnet_v2",
			object.name,
			h.dictionary(
				null,
				#[
					h.entry("name", h.text(object.name)),
					h.entry(
						"network_id",
						h.expression(
							h.resourceRef(
								"openstack_networking_network_v2",
								object.network.name,
								"id"
							)
						)
					),
					h.entry("cidr", h.text(object.cidr)),
					h.entry("ip_version", h.number(object.ipVersion.toString))
				]
			)
		)]
	}

	/**
	 * Translates an {@link UnknownResource} to a generic resource.
	 */
	def protected List<Resource> resources(UnknownResource<String, Object> object) {
		val attributes = object.attributes.elements
			.filter[p|p.value !== null]
			.map[p|h.entry(p.key, p.value.wrap)]
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
	 * Wraps the given object in the corresponding HCL model value.
	 */
	def protected Value wrap(Object value) {
		switch (value) {
			String:
				h.text(value.toString)
			Number:
				h.number(value.toString)
			Boolean:
				h.bool(value)
			List<?>:
				h.list(value.map[e|e.wrap])
			FkDictionary<String, ?>:
				h.dictionary(
					value.name,
					value.keySet.map[k|h.entry(k, value.get(k).wrap)]
				)
			FkResourceReference:
				value.wrapReference
			FkFunctionCall:
				value.wrapReference
			FkTextExpression:
				h.expression(value.expression.wrapReference)
			default:
				throw new UnsupportedOperationException(
					'''Unsupported type «value.class»'''
				)
		}
	}

	/**
	 * Wraps a reference object into its corresponding HCL value.
	 */
	def private Reference wrapReference(Object value) {
		switch (value) {
			FkResourceReference:
				h.resourceRef(value.segments)
			FkFunctionCall:
				h.functionCall(value.name, value.arguments.map[a|a.wrap])
		}
	}

	/**
	 * @return the quantity in Megabytes as a String
	 */
	def private asMbString(StorageUnit<?> quantity) {
		val format = new DecimalFormat("0")
		format.format(quantity.asMegabyte.inMegabyte)
	}

	/**
	 * @return the quantity in Gigabytes as a String
	 */
	def private asGbString(StorageUnit<?> quantity) {
		val format = new DecimalFormat("0")
		format.format(quantity.asGigabyte.inGigabyte)
	}
}
