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
package co.migueljimenez.devops.infrastructure.model

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

	def infrastructure() {
		return ModelFactory.eINSTANCE.createVirtualInfrastructure
	}

	def flavor(String name, int vcpus, StorageUnit<?> disk, StorageUnit<?> ram,
		VirtualInfrastructure project) {
		val flavor = ModelFactory.eINSTANCE.createFlavor
		flavor.name = name
		flavor.vcpus = vcpus
		flavor.disk = disk
		flavor.ram = ram
		flavor.project = project
		return flavor
	}

	def image(String name, ContainerFormat containerFormat, DiskFormat diskFormat,
			String imageSourceUrl, StorageUnit<?> minDisk, StorageUnit<?> minRam,
			VirtualInfrastructure project) {
		val image = ModelFactory.eINSTANCE.createImage
		image.name = name
		image.containerFormat = containerFormat
		image.diskFormat = diskFormat
		image.imageSourceUrl = imageSourceUrl
		image.minDisk = minDisk
		image.minRam = minRam
		image.project = project
		return image
	}

	def credential(String name, String publicKey, VirtualInfrastructure project) {
		val credential = ModelFactory.eINSTANCE.createCredential
		credential.name = name
		credential.publicKey = publicKey
		credential.project = project
		return credential
	}

	def volume(String name,  String description, Image image,
		StorageUnit<?> size, VirtualInfrastructure project) {
		val volume = ModelFactory.eINSTANCE.createVolume
		volume.name = name
		volume.description = description
		volume.image = image
		volume.size = size
		volume.project = project
		return volume
	}

	def network(String name, VirtualInfrastructure project) {
		val network = ModelFactory.eINSTANCE.createNetwork
		network.name = name
		network.project = project
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

	def securityRule(int portFrom, int portTo, String cidr, String protocol,
		SecurityGroup parent) {
		val rule = ModelFactory.eINSTANCE.createSecurityRule
		rule.from = portFrom
		rule.to = portTo
		rule.cidr = cidr
		rule.protocol = protocol
		rule.parent = parent
		return rule
	}

	def securityGroup(String name, String description,
		VirtualInfrastructure project) {
		val group = ModelFactory.eINSTANCE.createSecurityGroup
		group.name = name
		group.description = description
		group.project = project
		return group
	}

	def instance(String name, Credential credential, Flavor flavor,
		List<Volume> volumes, List<Network> networks,
			List<SecurityGroup> securityGroups, VirtualInfrastructure project) {
		val server = ModelFactory.eINSTANCE.createInstance
		server.name = name
		server.credential = credential
		server.flavor = flavor
		server.volumes.addAll(volumes)
		server.networks.addAll(networks)
		server.securityGroups.addAll(securityGroups)
		server.project = project
		return server
	}
	
	def <K, V> unknownResource(String resourceType, String type, String name,
		List<KeyValuePair<K, V>> data, VirtualInfrastructure project) {
		val dictionary = ModelFactory.eINSTANCE.createDictionary
		val resource = ModelFactory.eINSTANCE.createUnknownResource
		dictionary.elements.addAll(data)
		resource.resourceType = resourceType
		resource.type = type
		resource.name = name
		resource.attributes = dictionary
		resource.project = project
		return resource
	}

	def <K, V> KeyValuePair<K, V> entry(K key, V value) {
		val pair = ModelFactory.eINSTANCE.createKeyValuePair
		pair.key = key
		pair.value = value
		return pair
	}
}
