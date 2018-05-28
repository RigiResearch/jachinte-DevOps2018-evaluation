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

import co.migueljimenez.devops.hcl.model.Bool
import co.migueljimenez.devops.hcl.model.Dictionary
import co.migueljimenez.devops.hcl.model.FunctionCall
import co.migueljimenez.devops.hcl.model.Input
import co.migueljimenez.devops.hcl.model.List
import co.migueljimenez.devops.hcl.model.Number
import co.migueljimenez.devops.hcl.model.Output
import co.migueljimenez.devops.hcl.model.Resource
import co.migueljimenez.devops.hcl.model.ResourceReference
import co.migueljimenez.devops.hcl.model.Specification
import co.migueljimenez.devops.hcl.model.Text
import co.migueljimenez.devops.hcl.model.TextExpression
import co.migueljimenez.devops.hcl.model.Value
import co.migueljimenez.devops.infrastructure.model.ContainerFormat
import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.infrastructure.model.DiskFormat
import co.migueljimenez.devops.infrastructure.model.Flavor
import co.migueljimenez.devops.infrastructure.model.Image
import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.Instance
import co.migueljimenez.devops.infrastructure.model.ModelFactory
import co.migueljimenez.devops.infrastructure.model.Network
import co.migueljimenez.devops.infrastructure.model.SecurityGroup
import co.migueljimenez.devops.infrastructure.model.Subnet
import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.infrastructure.model.Volume
import co.migueljimenez.devops.transformation.dtos.FkDictionary
import co.migueljimenez.devops.transformation.dtos.FkFunctionCall
import co.migueljimenez.devops.transformation.dtos.FkReference
import co.migueljimenez.devops.transformation.dtos.FkResourceReference
import co.migueljimenez.devops.transformation.dtos.FkTextExpression
import com.google.common.base.Function
import java.math.BigInteger

import static de.xn__ho_hia.storage_unit.StorageUnits.gigabyte
import static de.xn__ho_hia.storage_unit.StorageUnits.megabyte

/**
 * Translates a {@link Specification} to a {@link VirtualInfrastructure}
 * instance.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-22
 * @version $Id$
 * @since 0.0.1
 */
class Hcl2Infrastructure {

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
	 * Maps the elements from the HCL model (i.e., {@link Specification}) to
	 * the infrastructure model (i.e., {@link VirtualInfrastructure}).
	 */
	def VirtualInfrastructure model(Specification specification) {
		val model = ModelFactory.eINSTANCE.createVirtualInfrastructure
		val removed = newArrayList
		specification.resources.forEach [ resource |
			if (!removed.contains(resource)) {
				switch (resource) {
					Input:
						model.resources.add(resource.createGenericResource)
					Output:
						model.resources.add(resource.createGenericResource)
					Resource:
						this.processResource(resource, specification, model, removed)
				}
			}
		]
		model
	}

	/**
	 * Instantiates and stores the given resource.
	 */
	def private void processResource(Resource resource, Specification specification,
		VirtualInfrastructure model, java.util.List<Resource> removedResources) {
		switch (resource.type) {
			case "openstack_compute_keypair_v2":
				model.credentials.add(resource.createCredential)
			case "openstack_compute_flavor_v2":
				model.flavors.add(resource.createFlavor)
			case "openstack_images_image_v2":
				model.images.add(resource.createImage)
			case "openstack_blockstorage_volume_v2":
				model.volumes.add(this.processVolume(resource, specification, model, removedResources))
			case "openstack_compute_secgroup_v2":
				model.securityGroups.add(resource.createSecurityGroup)
			case "openstack_networking_network_v2":
				model.networks.add(resource.createNetwork)
			case "openstack_networking_subnet_v2": {
				val network = specification.resources.getOrCreate(
					resource.attr("network_id"),
					model.networks,
					removedResources,
					[r|r.createNetwork],
					[r|r.name]
				)
				model.subnets.add(resource.createSubnet(network))
			}
			case "openstack_compute_instance_v2":
				model.instances.add(this.processInstance(resource, specification, model, removedResources))
			case "openstack_compute_volume_attach_v2": {
				val instance = specification.resources.getOrCreate(
					resource.attr("compute_id"),
					model.instances,
					removedResources,
					[r|this.processInstance(r, specification, model, removedResources)],
					[r|r.name]
				)
				val volume = specification.resources.getOrCreate(
					resource.attr("volume_id"),
					model.volumes,
					removedResources,
					[r|this.processVolume(r, specification, model, removedResources)],
					[r|r.name]
				)
				instance.volumes.add(volume)
			}
			default:
				model.resources.addAll(resource.createGenericResource)
		}
	}

	/**
	 * Given a resource, instantiates and stores the corresponding Volume element.
	 */
	def processVolume(Resource resource, Specification specification,
		VirtualInfrastructure model, java.util.List<Resource> removedResources) {
		val image = specification.resources.getOrCreate(
			resource.attr("image_id"),
			model.images,
			removedResources,
			[r|r.createImage],
			[r|r.name]
		)
		resource.createVolume(image)
	}

	/**
	 * Given a resource, instantiates and stores the corresponding Instance element.
	 */
	def processInstance(Resource resource, Specification specification,
		VirtualInfrastructure model, java.util.List<Resource> removedResources) {
		val credential = specification.resources.getOrCreate(
			resource.attr("key_pair"),
			model.credentials,
			removedResources,
			[r|r.createCredential],
			[r|r.name]
		)
		val flavor = specification.resources.getOrCreate(
			resource.attr("flavor_id"),
			model.flavors,
			removedResources,
			[r|r.createFlavor],
			[r|r.name]
		)
		val _networks = resource.attrs("network").map [ value |
			switch (value) {
				FkDictionary<String, Object>: {
					specification.resources.getOrCreate(
						value.get("name"),
						model.networks,
						removedResources,
						[r|r.createNetwork],
						[r|r.name]
					)
				}
			}
		]
		val groupsAttr = resource.attr("security_groups")
		val groups = if(groupsAttr !== null) groupsAttr as java.util.List<Object> else #[]
		val _securityGroups = groups.map [ reference |
			specification.resources.getOrCreate(
				reference,
				model.securityGroups,
				removedResources,
				[r|r.createSecurityGroup],
				[r|r.name]
			)
		]
		resource.createInstance(
			credential,
			flavor,
			_networks.toList,
			_securityGroups
		)
	}

	/**
	 * Gets the specified attribute list from the resource.
	 */
	def protected attrs(Resource resource, String attributeName) {
		resource.attributes.elements
			.filter[p|p.key.equals(attributeName)]
			.map[p|p.value.unwrap]
	}

	/**
	 * Gets the specified attribute from the resource.
	 */
	def protected attr(Resource resource, String attributeName) {
		resource.attrs(attributeName).findFirst[a|true]
	}

	/**
	 * Searches a referenced resource (value) in a given list of resources.
	 */
	def protected findByRef(java.util.List<Resource> resources, Object reference) {
		switch (reference) {
			FkTextExpression: {
				val expression = reference.expression
				switch (expression) {
					FkResourceReference: {
						val type = expression.segments.get(0)
						val name = expression.segments.get(1)
						resources.findFirst[r|r.type.equals(type) && r.name.equals(name)]
					}
					default:
						throw new UnsupportedOperationException(
							'''Unexpected function call "«reference»"'''
						)
				}
			}
			default:
				throw new UnsupportedOperationException(
					'''Invalid value "«reference»". Only resource references are allowed'''
				)
		}
	}

	/**
	 * Finds a referenced resource or creates a new instance if it hasn't been processed yet.
	 */
	def protected <T> getOrCreate(java.util.List<Resource> specResources,
		Object reference, java.util.List<T> virtualresources,
			java.util.List<Resource> removedResources,
				Function<Resource, T> factory, Function<T, Object> name) {
		val resource = specResources.findByRef(reference)
		var virtualResource = virtualresources.findFirst[i|name.apply(i).equals(resource.name)]
		if (virtualResource === null) {
			virtualResource = factory.apply(resource)
			virtualresources.add(virtualResource)
			removedResources.add(resource)
		}
		virtualResource
	}

	/**
	 * Creates a {@link Credential} from the given resource.
	 */
	def protected createCredential(Resource resource) {
		this.i.credentials(resource.name, resource.attr("public_key").toString)
	}

	/**
	 * Creates a {@link Flavor} from the given resource.
	 */
	def protected createFlavor(Resource resource) {
		this.i.flavor(
			resource.name,
			Integer.valueOf(resource.attr("vcpus").toString),
			gigabyte(resource.attr("disk").asBigInteger),
			megabyte(resource.attr("ram").asBigInteger)
		)
	}

	/**
	 * Creates an {@link Image} from the given resource.
	 */
	def protected createImage(Resource resource) {
		this.i.image(
			resource.name,
			ContainerFormat.get(resource.attr("container_format").toString),
			DiskFormat.get(resource.attr("disk_format").toString),
			resource.attr("image_source_url").toString,
			gigabyte(resource.attr("min_disk_gb").asBigInteger),
			megabyte(resource.attr("min_ram_mb").asBigInteger)
		)
	}

	/**
	 * Creates a {@link Volume} from the given resource.
	 */
	def protected createVolume(Resource resource, Image image) {
		this.i.volume(
			resource.name,
			resource.attr("description")?.toString,
			image,
			gigabyte(resource.attr("size").asBigInteger)
		)
	}

	/**
	 * Creates an {@link SecurityGroup} from the given resource.
	 */
	def protected createSecurityGroup(Resource resource) {
		val rules = resource.attrs("rule").map [ d |
			switch (d) {
				FkDictionary<String, Object>: {
					this.i.securityRule(
						Integer.valueOf(d.get("from_port").toString),
						Integer.valueOf(d.get("to_port").toString),
						d.get("cidr").toString,
						d.get("ip_protocol").toString
					)
				}
			}
		]
		this.i.securityGroup(
			resource.name,
			resource.attr("description")?.toString,
			rules.toList
		)
	}

	/**
	 * Creates a {@link Network} from the given resource.
	 */
	def protected createNetwork(Resource resource) {
		this.i.network(resource.name)
	}

	/**
	 * Creates a {@link Subnet} from the given resource.
	 */
	def protected createSubnet(Resource resource, Network network) {
		this.i.subnet(
			resource.name,
			resource.attr("cidr").toString,
			Integer.valueOf(resource.attr("ip_version").toString),
			network
		)
	}

	/**
	 * Creates an {@link Instance} from the given resource.
	 */
	def protected createInstance(Resource resource, Credential credential,
		Flavor flavor, java.util.List<Network> networks,
			java.util.List<SecurityGroup> securityGroups) {
		// This list is initially empty and is populated while processing
		// attachments
		val volumes = #[]
		this.i.instance(
			resource.name,
			credential,
			flavor,
			volumes,
			networks,
			securityGroups
		)
	}

	/**
	 * Translates an {@link Input} to a {@link VirtualInfrastructure} resource.
	 */
	def protected createGenericResource(Input resource) {
		this.i.<String, Object>unknownResource(
			"variable",
			null,
			resource.name,
			#[
				this.i.entry("default", resource.^default.unwrap),
				this.i.entry("description", resource.description)
			]
		)
	}

	/**
	 * Translates an {@link Output} to a set of {@link VirtualInfrastructure}
	 * resources.
	 */
	def protected createGenericResource(Output resource) {
		this.i.<String, Object>unknownResource(
			"output",
			null,
			resource.name,
			#[
				this.i.entry("description", resource.description),
				this.i.entry("sensitive", resource.sensitive),
				this.i.entry("value", resource.value.unwrap)
			]
		)
	}

	/**
	 * Translates a specification {@link Resource} to a
	 * {@link VirtualInfrastructure} resource.
	 */
	def protected createGenericResource(Resource resource) {
		this.i.<String, Object>unknownResource(
			"resource",
			null,
			resource.name,
			resource.attributes.elements.map[ p |
				this.i.entry(p.key, p.value.unwrap)
			]
		)
	}

	/**
	 * Translates a {@link Value} from the HCL model to a regular object.
	 */
	def protected Object unwrap(Value value) {
		switch (value) {
			Bool: value.unwrap
			Dictionary<Value>: value.unwrap
			FunctionCall: value.unwrap
			List: value.unwrap
			Number: value.unwrap
			ResourceReference: value.unwrap
			Text: value.unwrap
			TextExpression: value.unwrap
		}
	}

	/**
	 * Translates a {@link Bool} from the HCL model to a regular object.
	 */
	def protected unwrap(Bool value) {
		value.value
	}

	/**
	 * Translates a {@link Dictionary} from the HCL model to a regular object.
	 */
	def protected unwrap(Dictionary<Value> value) {
		new FkDictionary<String, Object>(value.name)
			.putAll(value.elements.map[p|p.key -> p.value.unwrap])
	}

	/**
	 * Translates a {@link FunctionCall} from the HCL model to a regular
	 * object.
	 */
	def protected unwrap(FunctionCall value) {
		new FkFunctionCall(value.name, value.arguments.map[a|a.unwrap])
	}

	/**
	 * Translates a {@link List} from the HCL model to a regular object.
	 */
	def protected unwrap(List value) {
		newArrayList(value.elements.map[e|e.unwrap].toArray)
	}

	/**
	 * Translates a {@link Number} from the HCL model to a regular object.
	 */
	def protected unwrap(Number value) {
		value.value
	}

	/**
	 * Translates a {@link ResourceReference} from the HCL model to a regular
	 * object.
	 */
	def protected unwrap(ResourceReference value) {
		new FkResourceReference(value.fullyQualifiedName)
	}

	/**
	 * Translates a {@link Text} from the HCL model to a regular object.
	 */
	def protected unwrap(Text value) {
		value.value
	}

	/**
	 * Translates a {@link TextExpression} from the HCL model to a regular
	 * object.
	 */
	def protected unwrap(TextExpression value) {
		new FkTextExpression(FkReference.from(value.expression.unwrap))
	}

	/**
	 * Instantiates a {@link BigInteger} from a given value.
	 */
	def private asBigInteger(Object value) {
		BigInteger.valueOf(Long.valueOf(value.toString))
	}
}
