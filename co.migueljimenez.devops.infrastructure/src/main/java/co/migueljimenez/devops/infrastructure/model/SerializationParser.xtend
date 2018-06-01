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

import java.io.ByteArrayOutputStream
import java.io.StringReader
import java.nio.charset.StandardCharsets
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.URIConverter
import org.eclipse.emf.ecore.resource.impl.ResourceSetImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceFactoryImpl
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl

/**
 * Parser to serialize and deserialize Ecore objects.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
class SerializationParser {

	/**
	 * Default constructor.
	 */
	new() {
		EcorePackage.eINSTANCE.eClass()
		ModelPackage.eINSTANCE.eClass()
	}

	/**
	 * Serializes an {@link EObject} to a String.
	 * Adapted from https://stackoverflow.com/a/43974978/738968
	 */
	def String asXml(EObject... eObjects) {
		val resourceSet = new ResourceSetImpl
		resourceSet.getResourceFactoryRegistry()
			.getExtensionToFactoryMap()
			.put("xmi", new XMIResourceFactoryImpl())
		// Since we are creating a String, not actually persisting to a file,
		// we will use a "dummy" URI to make sure it uses the correct extension
		val resource = resourceSet.createResource(
			URI.createURI("resource.xmi")
		)
		eObjects.forEach[e|resource.getContents().add(e)]
		val stream = new ByteArrayOutputStream
		resource.save(stream, newHashMap)
		new String(stream.toByteArray, StandardCharsets.UTF_8)
	}

	/**
	 * Loads an {@link EObject} from the given XML representation.
	 */
	def EList<EObject> asEObjects(String xml) {
		val resource = new XMIResourceImpl()
		val stream = new URIConverter.ReadableInputStream(new StringReader(xml))
		resource.load(stream, newHashMap)
		resource.contents
	}
}
