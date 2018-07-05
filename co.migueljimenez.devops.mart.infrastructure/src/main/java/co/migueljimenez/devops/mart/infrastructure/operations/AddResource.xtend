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
import co.migueljimenez.devops.infrastructure.model.Image
import co.migueljimenez.devops.infrastructure.model.SecurityGroup
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import com.rigiresearch.lcastane.framework.Specification
import com.rigiresearch.lcastane.framework.impl.FileSpecification
import com.rigiresearch.lcastane.framework.impl.GithubSpecification
import com.rigiresearch.lcastane.framework.impl.ObservableSpecification
import com.rigiresearch.lcastane.framework.validation.ValidationException
import org.eclipse.emf.ecore.EObject
import org.slf4j.LoggerFactory

/**
 * Adds a new resource to the {@link Infrastructure}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class AddResource extends AbstractOperation {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(AddResource)

	/**
	 * A parser to serialize Ecore objects.
	 */
	val SerializationParser serializationParser

	/**
	 * Notation-specific preprocessor.
	 */
	val SpecificationPreprocessor preprocessor

	/**
	 * Default constructor.
	 */
	new(SpecificationPreprocessor preprocessor) {
		super(InfrastructureModelOp.ADD_RESOURCE)
		this.serializationParser = new SerializationParser
		this.preprocessor = preprocessor
	}

	/**
	 * Secondary constructor.
	 */
	new() {
		this(new SpecificationPreprocessor.NullImpl)
	}

	override protected applyOp(Infrastructure infrastructure,
		Object... arguments) throws ValidationException {
		// arguments: Ecore model XML
		val xml = arguments.get(0) as String
		val objects = this.serializationParser.asEObjects(xml)
		// FIXME assume there's only one object while I fix the ConcurrentModificationException
		val o = objects.get(0)
		switch (o) {
			Credential:
				infrastructure.add(o)
			SecurityGroup:
				infrastructure.add(o)
			Image:
				infrastructure.add(o)
			default:
				infrastructure.add(o)
		}
	}

	/**
	 * Add a {@link Credential} to the given project.
	 */
	def private add(Infrastructure infrastructure, Credential eObject) {
		if (infrastructure.model.credentials.exists[c|c.name.equals(eObject.name)]) {
			this.logger.info('''Credential "«eObject.name»" not added because it already exists''')
			return
		}
		val spec = this.getFileSpec(infrastructure.parent.specification)
		if (spec !== null)
			this.preprocessor.preprocess(eObject, (spec as FileSpecification).file)
		eObject.project = infrastructure.model
	}

	/**
	 * Adds a {@link SecurityGroup} to the given project.
	 */
	def private add(Infrastructure infrastructure, SecurityGroup eObject) {
		if (infrastructure.model.securityGroups.exists[s|eObject.name.equals(s.name)]) {
			this.logger.info('''Security Group "«eObject.name»" not added because it already exists''')
			return
		}
		val spec = this.getFileSpec(infrastructure.parent.specification)
		if (spec !== null)
			this.preprocessor.preprocess(eObject, (spec as FileSpecification).file)
		eObject.project = infrastructure.model
	}

	/**
	 * Adds an {@link Image} to the given project.
	 */
	def private add(Infrastructure infrastructure, Image eObject) {
		if (infrastructure.model.images.exists[i|eObject.name.equals(i.name)]) {
			this.logger.info('''Image "«eObject.name»" not added because it already exists''')
			return
		}
		val spec = this.getFileSpec(infrastructure.parent.specification)
		if (spec !== null)
			this.preprocessor.preprocess(eObject, (spec as FileSpecification).file)
		eObject.project = infrastructure.model
	}

	def private Specification getFileSpec(Specification spec) {
		switch (spec) {
			ObservableSpecification<?>: {
				getFileSpec(spec.origin)
			}
			GithubSpecification: {				
				spec.origin
			}
			FileSpecification: {
				spec
			}
		}
	}

	/**
	 * Add the resource to the given project.
	 */
	def private add(Infrastructure infrastructure, EObject eObject) {
		throw new UnsupportedOperationException('''Unsupported resource «eObject»''')
	}
}
