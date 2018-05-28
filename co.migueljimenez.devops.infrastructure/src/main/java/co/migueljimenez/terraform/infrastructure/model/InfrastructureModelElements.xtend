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

	def infrastructure(List<Credential> credentials, List<Flavor> flavors,
		List<Image> images, List<Instance> instances, List<Network> networks,
			List<Subnet> subnets, List<SecurityGroup> securityGroups,
				List<Volume> volumes, List<UnknownResource<String, Object>> otherResources) {
		val infrastructure = ModelFactory.eINSTANCE.createVirtualInfrastructure
		infrastructure.credentials.addAll(credentials)
		infrastructure.flavors.addAll(flavors)
		infrastructure.images.addAll(images)
		infrastructure.instances.addAll(instances)
		infrastructure.networks.addAll(networks)
		infrastructure.subnets.addAll(subnets)
		infrastructure.securityGroups.addAll(securityGroups)
		infrastructure.volumes.addAll(volumes)
		infrastructure.resources.addAll(otherResources)
		return infrastructure
	}

	def flavor(String name, int vcpus, StorageUnit<?> disk, StorageUnit<?> ram) {
		val flavor = ModelFactory.eINSTANCE.createFlavor
		flavor.name = name
		flavor.vcpus = vcpus
		flavor.disk = disk
		flavor.ram = ram
		return flavor
	}

	def image(String name, ContainerFormat containerFormat, DiskFormat diskFormat,
			String imageSourceUrl, StorageUnit<?> minDisk, StorageUnit<?> minRam) {
		val image = ModelFactory.eINSTANCE.createImage
		image.name = name
		image.containerFormat = containerFormat
		image.diskFormat = diskFormat
		image.imageSourceUrl = imageSourceUrl
		image.minDisk = minDisk
		image.minRam = minRam
		return image
	}

	def credentials(String name, String publicKey) {
		val credentials = ModelFactory.eINSTANCE.createCredential
		credentials.name = name
		credentials.publicKey = publicKey
		return credentials
	}

	def volume(String name,  String description, Image image, StorageUnit<?> size) {
		val volume = ModelFactory.eINSTANCE.createVolume
		volume.name = name
		volume.description = description
		volume.image = image
		volume.size = size
		return volume
	}

	def network(String name) {
		val network = ModelFactory.eINSTANCE.createNetwork
		network.name = name
		return network
	}

	def subnet(String name, String cidr, int ipVersion, Network network) {
		val subnet = ModelFactory.eINSTANCE.createSubnet
		subnet.name = name
		subnet.cidr = cidr
		subnet.ipVersion = ipVersion
		subnet.network = network
		return subnet
	}

	def securityRule(int portFrom, int portTo, String cidr, String protocol) {
		val rule = ModelFactory.eINSTANCE.createSecurityRule
		rule.from = portFrom
		rule.to = portTo
		rule.cidr = cidr
		rule.protocol = protocol
		return rule
	}

	def securityGroup(String name, String description, List<SecurityRule> rules) {
		val group = ModelFactory.eINSTANCE.createSecurityGroup
		group.name = name
		group.description = description
		group.rules.addAll(rules)
		return group
	}

	def instance(String name, Credential credential, Flavor flavor,
		List<Volume> volumes, List<Network> networks,
			List<SecurityGroup> securityGroups) {
		val server = ModelFactory.eINSTANCE.createInstance
		server.name = name
		server.credential = credential
		server.flavor = flavor
		server.volumes.addAll(volumes)
		server.networks.addAll(networks)
		server.securityGroups.addAll(securityGroups)
		return server
	}
	
	def <K, V> unknownResource(String resourceType, String type, String name,
		List<KeyValuePair<K, V>> data) {
		val dictionary = ModelFactory.eINSTANCE.createDictionary
		val resource = ModelFactory.eINSTANCE.createUnknownResource
		dictionary.elements.addAll(data)
		resource.resourceType = resourceType
		resource.type = type
		resource.name = name
		resource.attributes = dictionary
		return resource
	}

	def <K, V> KeyValuePair<K, V> entry(K key, V value) {
		val pair = ModelFactory.eINSTANCE.createKeyValuePair
		pair.key = key
		pair.value = value
		return pair
	}
}