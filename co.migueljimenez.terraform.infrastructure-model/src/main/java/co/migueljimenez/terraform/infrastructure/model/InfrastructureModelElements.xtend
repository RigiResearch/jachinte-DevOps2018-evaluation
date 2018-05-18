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
package co.migueljimenez.terraform.infrastructure.model

import java.util.List
import de.xn__ho_hia.storage_unit.StorageUnit

/**
 * Facilitates creating elements from the Infrastructure model.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
class InfrastructureModelElements {

	def infrastructure(List<Flavor> flavors, List<Image> images,
		List<Instance> instances, List<UnknownResource<String, Object>> otherResources) {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.flavors.addAll(flavors)
		infrastructure.images.addAll(images)
		infrastructure.instances.addAll(instances)
		infrastructure.resources.addAll(otherResources)
		return infrastructure
	}

	def flavor(String id, String name, int vcpus, Quantity disk, Quantity ram) {
		val flavor = ModelFactory.eINSTANCE.createFlavor
		flavor.id = id
		flavor.name = name
		flavor.vcpus = vcpus
		flavor.disk = disk
		flavor.ram = ram
		return flavor
	}

	def image(String id, String name, Quantity minDisk, Quantity minRam) {
		val image = ModelFactory.eINSTANCE.createImage
		image.id = id
		image.name = name
		image.minDisk = minDisk
		image.minRam = minRam
		return image
	}

	def server(String id, String name, String ip, Flavor flavor, Image image) {
		val server = ModelFactory.eINSTANCE.createInstance
		server.id = id
		server.name = name
		server.flavor = flavor
		server.image = image
		return server
	}
	
	def <K, V> unknownResource(List<KeyValuePair<K, V>> data) {
		val dictionary = ModelFactory.eINSTANCE.createDictionary
		val resource = ModelFactory.eINSTANCE.createUnknownResource
		dictionary.elements.addAll(data)
		resource.attributes = dictionary
		return resource
	}

	def quantity(Number value, StorageUnit<?> unit) {
		val quantity = ModelFactory.eINSTANCE.createQuantity
		quantity.value = value
		quantity.unit = unit
		return quantity
	}
}
