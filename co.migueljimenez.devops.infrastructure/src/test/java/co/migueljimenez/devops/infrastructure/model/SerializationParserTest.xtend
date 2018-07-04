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

import org.junit.Test
import org.junit.Assert
import de.xn__ho_hia.storage_unit.StorageUnits
import org.eclipse.emf.ecore.util.EcoreUtil

/**
 * Tests {@link SerializationParser}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
class SerializationParserTest {

	/**
	 * The parser instance being tested.
	 */
	val SerializationParser parser

	/**
	 * A helper to instantiate elements from the Infrastructure model.
	 */
	val InfrastructureModelElements i

	/**
	 * Default constructor.
	 */
	new() {
		this.parser = new SerializationParser
		this.i = new InfrastructureModelElements
	}

	@Test
	def void simpleEObject() {
		val expected = '''
		<?xml version="1.0" encoding="ASCII"?>
		<infrastructure:Credential xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:infrastructure="https://migueljimenez.co/devops/infrastructure" name="keypair" publicKey="..."/>
		'''
		val project = this.i.infrastructure
		val xml = this.parser.asXml(
			this.i.credential("keypair", "...", project)
		)
		Assert.assertEquals(expected, xml)
	}

	@Test
	def void complexEObject1() {
		val expected = '''
		<?xml version="1.0" encoding="ASCII"?>
		<xmi:XMI xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:infrastructure="https://migueljimenez.co/devops/infrastructure">
		  <infrastructure:Volume id="volume-id" name="volume-1" description="a volume" size="ACED00057372002364652E786E5F5F686F5F6869612E73746F726167655F756E69742E4769676162797465693563B83303EC9A0200007872002664652E786E5F5F686F5F6869612E73746F726167655F756E69742E53746F72616765556E69749A120F84736EC41B0200014C000562797465737400164C6A6176612F6D6174682F426967496E74656765723B787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870737200146A6176612E6D6174682E426967496E74656765728CFC9F1FA93BFB1D030006490008626974436F756E744900096269744C656E67746849001366697273744E6F6E7A65726F427974654E756D49000C6C6F776573745365744269744900067369676E756D5B00096D61676E69747564657400025B427871007E0003FFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFE00000001757200025B42ACF317F8060854E00200007870000000047735940078" image="image-id"/>
		  <infrastructure:Image id="image-id" name="centos" containerFormat="bare" imageSourceUrl="..." minDisk="ACED00057372002364652E786E5F5F686F5F6869612E73746F726167655F756E69742E4769626962797465F0AB23C6695FC2CA0200007872002664652E786E5F5F686F5F6869612E73746F726167655F756E69742E53746F72616765556E69749A120F84736EC41B0200014C000562797465737400164C6A6176612F6D6174682F426967496E74656765723B787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870737200146A6176612E6D6174682E426967496E74656765728CFC9F1FA93BFB1D030006490008626974436F756E744900096269744C656E67746849001366697273744E6F6E7A65726F427974654E756D49000C6C6F776573745365744269744900067369676E756D5B00096D61676E69747564657400025B427871007E0003FFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFE00000001757200025B42ACF317F8060854E00200007870000000044000000078" minRam="ACED00057372002364652E786E5F5F686F5F6869612E73746F726167655F756E69742E4D6567616279746551E7D7C851D663AF0200007872002664652E786E5F5F686F5F6869612E73746F726167655F756E69742E53746F72616765556E69749A120F84736EC41B0200014C000562797465737400164C6A6176612F6D6174682F426967496E74656765723B787200106A6176612E6C616E672E4E756D62657286AC951D0B94E08B0200007870737200146A6176612E6D6174682E426967496E74656765728CFC9F1FA93BFB1D030006490008626974436F756E744900096269744C656E67746849001366697273744E6F6E7A65726F427974654E756D49000C6C6F776573745365744269744900067369676E756D5B00096D61676E69747564657400025B427871007E0003FFFFFFFFFFFFFFFFFFFFFFFEFFFFFFFE00000001757200025B42ACF317F8060854E00200007870000000041E84800078"/>
		</xmi:XMI>
		'''
		val project = this.i.infrastructure
		val image = this.i.image(
			"image-id",
			"centos",
			ContainerFormat.BARE,
			DiskFormat.AMI,
			"...",
			StorageUnits.gibibyte(1L),
			StorageUnits.megabyte(512L),
			project
		)
		val xml = this.parser.asXml(
			this.i.volume(
				"volume-id",
				"volume-1",
				"a volume",
				image,
				StorageUnits.gigabyte(2L),
				project
			),
			image
		)
		Assert.assertEquals(expected, xml)
	}

	@Test
	def void complexEObject2() {
		val expected = '''
		<?xml version="1.0" encoding="ASCII"?>
		<infrastructure:Network xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:infrastructure="https://migueljimenez.co/devops/infrastructure" id="network-id" name="network-1">
		  <subnets name="subnet-1" cidr="10.10.10.0/24" ipVersion="4"/>
		</infrastructure:Network>
		'''
		val project = this.i.infrastructure
		val network = this.i.network("network-id", "network-1", project)
		this.i.subnet("subnet-1", "10.10.10.0/24", 4, network)
		val xml = this.parser.asXml(network)
		Assert.assertEquals(expected, xml)
	}

	@Test
	def void loadSimpleModel() {
		val project = this.i.infrastructure
		val credential = this.i.credential("keypair", "...", project)
		val xml = this.parser.asXml(credential)
		val contents = this.parser.asEObjects(xml)
		Assert.assertTrue(
			EcoreUtil.equals(#[credential], contents)
		)
	}

	@Test
	def void loadComplexModel1() {
		val project = this.i.infrastructure
		val network = this.i.network("network-id", "network-1", project)
		this.i.subnet("subnet-1", "10.10.10.0/24", 4, network)
		val xml = this.parser.asXml(network)
		val contents = this.parser.asEObjects(xml)
		Assert.assertTrue(
			EcoreUtil.equals(#[network], contents)
		)
	}

	@Test
	def void loadComplexModel2() {
		val project = this.i.infrastructure
		val image = this.i.image(
			"image-id",
			"centos",
			ContainerFormat.BARE,
			DiskFormat.AMI,
			"...",
			StorageUnits.gibibyte(1L),
			StorageUnits.megabyte(512L),
			project
		)
		val volume = this.i.volume(
			"volume-id",
			"volume-1",
			"a volume",
			image,
			StorageUnits.gigabyte(2L),
			project
		)
		val xml = this.parser.asXml(image, volume)
		val contents = this.parser.asEObjects(xml)
		Assert.assertTrue(
			EcoreUtil.equals(#[image, volume], contents)
		)
	}

	@Test
	def void loadComplexModel3() {
		val project = this.i.infrastructure
		val image = this.i.image(
			"image-id",
			"centos",
			ContainerFormat.BARE,
			DiskFormat.AMI,
			"...",
			StorageUnits.gibibyte(1L),
			StorageUnits.megabyte(512L),
			project
		)
		this.i.volume(
			"volume-id",
			"volume-1",
			"a volume",
			image,
			StorageUnits.gigabyte(2L),
			project
		)
		val xml = this.parser.asXml(project)
		val contents = this.parser.asEObjects(xml)
		Assert.assertTrue(
			EcoreUtil.equals(#[project], contents)
		)
	}
}
