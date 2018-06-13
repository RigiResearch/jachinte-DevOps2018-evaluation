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
package co.migueljimenez.devops.mart.infrastructure.operations

import co.migueljimenez.devops.infrastructure.model.Credential
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.emf.ecore.EObject

/**
 * Adds a new resource to the {@link Infrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class AddResource extends AbstractOperation {

	/**
	 * A parser to serialize Ecore objects.
	 */
	val SerializationParser serializationParser

	/**
	 * Default constructor.
	 */
	new() {
		super(InfrastructureModelOp.ADD_CREDENTIAL)
		this.serializationParser = new SerializationParser
	}

	override protected applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException {
		val xml = arguments.get(0) as String
		val objects = this.serializationParser.asEObjects(xml)
		// FIXME assume there's only one object while I fix the ConcurrentModificationException
		val o = objects.get(0)
		switch (o) {
			Credential: // arguments: credential, specification file
				infrastructure.model.add(o, arguments.get(1) as File)
			default:
				infrastructure.model.add(o)
		}
	}

	/**
	 * Add a {@link Credential} to the given project.
	 */
	def private add(VirtualInfrastructure project, Credential eObject,
		File specificationFile) {
		val file = new File(specificationFile.parentFile, '''.keys/«eObject.name».pub''')
		file.parentFile.mkdir // create the ".keys" directory in case it doesn't exist
		Files.write(Paths.get(file.toURI), eObject.publicKey.bytes)
		eObject.publicKey = '''${file("«file.parentFile.name»/«file.name»")}'''
		eObject.project = project
	}

	/**
	 * Add the resource to the given project.
	 */
	def private add(VirtualInfrastructure project, EObject eObject) {
		throw new UnsupportedOperationException('''Unsupported resource «eObject»''')
	}
}
