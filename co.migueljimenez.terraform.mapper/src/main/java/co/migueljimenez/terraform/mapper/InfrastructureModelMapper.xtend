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
package co.migueljimenez.terraform.mapper

import co.migueljimenez.terraform.hcl.model.HclModelElements
import co.migueljimenez.terraform.hcl.model.Resource
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.infrastructure.model.Flavor
import co.migueljimenez.terraform.infrastructure.model.Image
import co.migueljimenez.terraform.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.terraform.infrastructure.model.Instance
import co.migueljimenez.terraform.infrastructure.model.Quantity
import co.migueljimenez.terraform.infrastructure.model.UnknownResource
import co.migueljimenez.terraform.infrastructure.model.VirtualInfrastructure
import org.eclipse.emf.ecore.EObject
import co.migueljimenez.terraform.hcl.model.Value
import co.migueljimenez.terraform.hcl.model.KeyValuePair

/**
 * Maps from {@link Specification} to {@link VirtualInfrastructure} and vice
 * versa.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-04
 * @version $Id$
 * @since 0.0.1
 */
class InfrastructureModelMapper {

	/**
	 * Elements creator for the HCL model.
	 */
	val HclModelElements h

	/**
	 * Elements creator for the Virtual Infrastructure model.
	 */
	val InfrastructureModelElements i

	/**
	 * Default constructor.
	 */
	new() {
		this.h = new HclModelElements
		this.i = new InfrastructureModelElements
	}

	/**
	 * Maps the elements from an infrastructure model to HCL.
	 * @param model the infrastructure model
	 * @return the code representation of the model in HCL
	 */
	def Specification specification(VirtualInfrastructure model) {
		val resources = #[]
		resources.addAll(model.flavors.map[f|f.resource])
		resources.addAll(model.images.map[i|i.resource])
		resources.addAll(model.instances.map[i|i.resource])
		resources.addAll(model.resources.map[r|r.resource])
		return this.h.specification(resources)
	}

	def private Resource resource(EObject object) {
		switch (object) {
			Flavor: {
				h.resource(
					"resource",
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
				)
			}
			Image: {
				h.resource(
					"data",
					"openstack_images_image_v2",
					object.name,
					h.dictionary(
						null,
						#[
							h.entry("name", h.text(object.name)),
							h.entry("container_format", h.text(object.containerFormat.literal)),
							h.entry("disk_format", h.text(object.diskFormat.literal)),
							h.entry("local_file_path", h.text(object.localFilePath)),
							h.entry("image_source_url", h.text(object.imageSourceUrl)),
							h.entry("min_disk_gb", h.number(object.minDisk.asGbString)),
							h.entry("min_ram_mb", h.number(object.minRam.asMbString))
						]
					)
				)
			}
			Instance: {
				h.resource(
					"resource",
					"openstack_compute_instance_v2",
					object.name,
					h.dictionary(
						null,
						#[
							h.entry("image_id", h.text(object.image.id)),
							h.entry("flavor_id", h.text(object.flavor.id))
							// TODO complete entries
						]
					)
				)
			}
			UnknownResource<String, Object>: {
				val KeyValuePair<String, Value>[] attributes = newArrayList
				// TODO I'm assuming all attributes are bound to text literals
				object.attributes.elements.forEach[p|
					attributes.add(h.entry(p.key, h.text(p.value.toString)))
				]
				h.resource(
					object.resourceType,
					object.type,
					object.name,
					h.dictionary(
						null,
						attributes
					)
				)
			}
		}
	}

	/**
	 * @return the quantity in Megabytes as a String
	 */
	def private asMbString(Quantity quantity) {
		quantity.unit.asMegabyte.longValue.toString
	}

	/**
	 * @return the quantity in Gigabytes as a String
	 */
	def private asGbString(Quantity quantity) {
		quantity.unit.asGigabyte.longValue.toString
	}

	/**
	 * Maps the elements from a Terraform (HCL) specification to the
	 * infrastructure model.
	 * @param specification the specification
	 */
	def VirtualInfrastructure model(Specification specification) {
		throw new UnsupportedOperationException();
	}	
}
