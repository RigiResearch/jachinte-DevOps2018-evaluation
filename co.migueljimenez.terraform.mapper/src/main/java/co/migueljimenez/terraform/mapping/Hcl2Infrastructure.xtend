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

import co.migueljimenez.terraform.dtos.FkFunctionCall
import co.migueljimenez.terraform.dtos.FkReference
import co.migueljimenez.terraform.dtos.FkTextExpression
import co.migueljimenez.terraform.hcl.model.Bool
import co.migueljimenez.terraform.hcl.model.Dictionary
import co.migueljimenez.terraform.hcl.model.FunctionCall
import co.migueljimenez.terraform.hcl.model.Input
import co.migueljimenez.terraform.hcl.model.List
import co.migueljimenez.terraform.hcl.model.Number
import co.migueljimenez.terraform.hcl.model.Output
import co.migueljimenez.terraform.hcl.model.Resource
import co.migueljimenez.terraform.hcl.model.ResourceReference
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.hcl.model.Text
import co.migueljimenez.terraform.hcl.model.TextExpression
import co.migueljimenez.terraform.hcl.model.Value
import co.migueljimenez.terraform.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.terraform.infrastructure.model.VirtualInfrastructure
import java.math.BigInteger

import static de.xn__ho_hia.storage_unit.StorageUnits.gigabyte
import static de.xn__ho_hia.storage_unit.StorageUnits.megabyte
import co.migueljimenez.terraform.dtos.FkDictionary
import co.migueljimenez.terraform.dtos.FkResourceReference

/**
 * Maps the elements from a {@link Specification} to
 * a {@link VirtualInfrastructure} instance.
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
	 * @param specification the specification
	 */
	def VirtualInfrastructure model(Specification specification) {
		val credentials = newArrayList
		val flavors = newArrayList
		val images = newArrayList
		val instances = newArrayList
		val networks = newArrayList
		val securityGroups = newArrayList
		val volumes = newArrayList
		val otherResources = newArrayList
		specification.resources.forEach [ resource |
			switch (resource) {
				Input:
					otherResources.addAll(resource.vResources)
				Output:
					otherResources.addAll(resource.vResources)
				Resource:
					switch (resource.type) {
						case "openstack_compute_keypair_v2": {
							credentials.add(
								this.i.credentials(
									null,
									resource.name,
									resource.attr("public_key").toString
								)
							)
						}
						case "openstack_compute_flavor_v2": {
							this.i.flavor(
								null,
								resource.name,
								Integer.valueOf(resource.attr("vcpus").toString),
								gigabyte(BigInteger.valueOf(Long.valueOf(resource.attr("disk").toString))),
								megabyte(BigInteger.valueOf(Long.valueOf(resource.attr("disk").toString)))
							)
						}
						case "openstack_blockstorage_volume_v2": {
							
						}
						case "openstack_compute_secgroup_v2": {
							
						}
						case "openstack_images_image_v2": {
							
						}
						case "openstack_compute_instance_v2": {
							
						}
						case "openstack_compute_volume_attach_v2": {
							
						}
						default:
							otherResources.addAll(resource.vResources)
					}
			}
		]
		this.i.infrastructure(
			credentials,
			flavors,
			images,
			instances,
			networks,
			securityGroups,
			volumes,
			otherResources
		)
	}

	/**
	 * Gets the specified attribute from the resource.
	 */
	def protected attr(Resource resource, String attributeName) {
		resource.attributes.elements.findFirst [ p |
			p.key.equals(attributeName)
		].value.unwrap
	}

	/**
	 * Translates an {@link Input} to a set of {@link VirtualInfrastructure}
	 * resources.
	 */
	def protected vResources(Input resource) {
		#[this.i.<String, Object>unknownResource(
			"variable",
			null,
			resource.name,
			#[
				this.i.entry("default", resource.^default.unwrap),
				this.i.entry("description", resource.description)
			]
		)]
	}

	/**
	 * Translates an {@link Output} to a set of {@link VirtualInfrastructure}
	 * resources.
	 */
	def protected vResources(Output resource) {
		#[this.i.<String, Object>unknownResource(
			"output",
			null,
			resource.name,
			#[
				this.i.entry("description", resource.description),
				this.i.entry("sensitive", resource.sensitive),
				this.i.entry("value", resource.value.unwrap)
			]
		)]
	}

	/**
	 * Translates a generic {@link Resource} to a set of
	 * {@link VirtualInfrastructure} resources.
	 */
	def protected vResources(Resource resource) {
		#[this.i.<String, Object>unknownResource(
			"resource",
			null,
			resource.name,
			resource.attributes.elements.map[ p |
				this.i.entry(p.key, p.value.unwrap)
			]
		)]
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
		newArrayList(value.elements.map[e|e.unwrap])
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

}