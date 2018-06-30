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
package com.rigiresearch.lcastane.primor

import com.rigiresearch.lcastane.framework.Command
import com.rigiresearch.lcastane.framework.EcoreMART
import com.rigiresearch.lcastane.framework.MART
import com.rigiresearch.lcastane.framework.impl.FileSpecification
import com.rigiresearch.lcastane.framework.validation.ValidationException
import java.io.File
import java.io.StringReader
import java.nio.file.Files
import java.nio.file.Paths
import java.rmi.RemoteException
import java.util.Comparator
import java.util.Map
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.eclipse.emf.ecore.EcorePackage
import org.eclipse.emf.ecore.resource.URIConverter
import org.eclipse.emf.ecore.xmi.impl.XMIResourceImpl
import org.eclipse.jgit.api.Git
import org.eclipse.jgit.transport.CredentialsProvider
import org.eclipse.jgit.transport.URIish
import org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider
import org.slf4j.LoggerFactory
import org.eclipse.jgit.transport.CredentialItem
import org.eclipse.jgit.errors.UnsupportedCredentialItem

/**
 * A {@link ManagerService} implementation.
 * @author Miguel Jimenez (miguel@uvic.ca) - Port to Xtend
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2018-05-30
 * @version $Id$
 * @since 0.0.1
 */
class Manager implements ManagerService {

	static class MyCredentialsProvider extends UsernamePasswordCredentialsProvider {
		/**
		 * The Github token.
		 */
		val String token

		new(String token) {
			super(token, "".toCharArray)
			this.token = token
		}

		override get(URIish uri, CredentialItem... items) throws UnsupportedCredentialItem {
			for (item : items) {
				switch (item) {
					CredentialItem.YesNoType: {
						item.value = true
						return true
					}
					CredentialItem.Username: {
						item.value = this.token
					}
					CredentialItem.Password: {
						item.value = "".toCharArray
					}
					CredentialItem.StringType: {
						if (item.getPromptText().equals("Password: "))
							item.setValue("")
					}
				}
			}
			return false
		}

		override isInteractive() {
			false
		}

		override supports(CredentialItem... items) {
			for (item : items) {
				val b = switch (item) {
					CredentialItem.YesNoType: true
					CredentialItem.Username: true
					CredentialItem.Password: true
					default: false
				}
				if (!b)
					return false
			}
			return true
		}
	}

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(Manager)

	/**
	 * The registered models.
	 */
	val Map<String, MART<?, ?>> models

	/**
	 * The local repositories associated with MARTs.
	 */
	val Map<String, File> clonedRepositories

	/**
	 * The Github credentials provider.
	 */
	val CredentialsProvider credentialsProvider

	/**
	 * Default constructor.
	 */
	new() {
		this.models = newHashMap
		this.clonedRepositories = newHashMap
		val config = new Configurations().properties("github.properties");
		this.credentialsProvider = new MyCredentialsProvider(
			config.getString("authentication-token")
		)
		Runtime.runtime.addShutdownHook(new Thread()[
			this.clonedRepositories.keySet.forEach [ id |
				Files.walk(Paths.get(this.clonedRepositories.get(id).canonicalPath))
				    .sorted(Comparator.reverseOrder)
				    .map(p|p.toFile)
				    .forEach[f|f.delete]
				this.logger.info('''Local repository for model "«id»" has been deleted''')
			]
		])
	}

	override register(String modelIdentifier, MART<?, ?> model)
		throws RemoteException {
		this.register(modelIdentifier, model, null)
	}

	override register(String modelIdentifier, MART<?, ?> model, URIish repository)
		throws RemoteException {
		if (repository !== null)
			this.cloneRepository(modelIdentifier, repository)
		val spec = model.specification
		switch (spec) {
			FileSpecification: {
				spec.file(
					new File(
						this.clonedRepositories.get(modelIdentifier),
						spec.file.toString
					)
				)
			}
		}
		val instance = switch (model) {
			EcoreMART<?, ?>: this.instantiate(model)
			default: model
		}
		this.models.put(modelIdentifier, instance)
		this.logger.info('''Model "«modelIdentifier»" was registered''')
	}

	def private cloneRepository(String modelIdentifier, URIish remote) {
		val repository = Git.cloneRepository
			.setURI(remote.toString)
			.setDirectory(Files.createTempDirectory("").toFile)
			.setCredentialsProvider(this.credentialsProvider)
			.call
			.repository
		this.logger.info('''Repository "«remote»" has been cloned''')
		this.clonedRepositories.put(modelIdentifier, repository.directory.parentFile)
		repository.close
	}

	def private instantiate(EcoreMART<?, ?> model) {
		// Register the Ecore package
		EcorePackage.eINSTANCE.eClass()
		Class.forName(model.packageImplClassName).getMethod("init").invoke(null)
		// Load the resource and instantiate the corresponding classes
		val resource = new XMIResourceImpl()
		val stream = new URIConverter.ReadableInputStream(new StringReader(model.serializedArtefact))
		resource.load(stream, newHashMap)
		val rootClass = Class.forName(model.modelClassName)
		val artefactClass = Class.forName(model.decoratorClassName)
		val martClass = Class.forName(model.martClassName)
		val root = rootClass.cast(resource.contents.get(0))
		val artefact = artefactClass.getDeclaredConstructor(rootClass).newInstance(root)
		val mart = martClass.getDeclaredConstructor(model.specification.class, artefactClass)
			.newInstance(model.specification, artefact) as MART<?, ?>
		return mart
	}

	override model(String modelIdentifier)
		throws RemoteException, ModelNotFoundException {
		this.ensureModelExists(modelIdentifier)
		this.models.get(modelIdentifier).export()
	}

	override execute(String modelIdentifier, Command command)
		throws RemoteException, ValidationException, ModelNotFoundException {
		this.ensureModelExists(modelIdentifier)
		this.models.get(modelIdentifier).artefact.apply(command)
		this.logger.info(
			'''
			Command «command.operationType» was applied to model "«modelIdentifier»"'''
		)
	}

	override modelRegistered(String modelIdentifier) throws RemoteException {
		this.models.containsKey(modelIdentifier)
	}

	def private ensureModelExists(String modelIdentifier)
		throws ModelNotFoundException {
		if (!this.models.containsKey(modelIdentifier))
			throw new ModelNotFoundException('''Model «modelIdentifier» not found''')
	}
}
