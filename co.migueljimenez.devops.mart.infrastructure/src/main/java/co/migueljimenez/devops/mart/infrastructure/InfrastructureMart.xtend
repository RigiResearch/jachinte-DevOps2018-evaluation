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
package co.migueljimenez.devops.mart.infrastructure

import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.infrastructure.model.impl.ModelPackageImpl
import co.migueljimenez.devops.transformation.Hcl2Infrastructure
import co.migueljimenez.devops.transformation.Hcl2Text
import co.migueljimenez.devops.transformation.Infrastructure2Hcl
import co.migueljimenez.devops.transformation.Text2Hcl
import com.rigiresearch.lcastane.framework.EcoreMART
import com.rigiresearch.lcastane.framework.Rule
import com.rigiresearch.lcastane.framework.impl.AbstractMART
import com.rigiresearch.lcastane.framework.impl.FileSpecification
import com.rigiresearch.lcastane.framework.impl.GithubSpecification
import org.slf4j.LoggerFactory

/**
 * Represents a virtual infrastructure MART.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
class InfrastructureMart extends AbstractMART<GithubSpecification, Infrastructure> {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(InfrastructureMart)

	/**
	 * HCL to infrastructure parser.
	 */
	val Hcl2Infrastructure infrastructureParser

	/**
	 * Infrastructure to HCL parser.
	 */
	val Infrastructure2Hcl hclParser

	/**
	 * HCL to text parser.
	 */
	val Hcl2Text textParser

	/**
     * Primary constructor.
     * The infrastructure and the associated template are supposed to be in sync already.
     * @param template The template associated with this model
     * @param infrastructure The artefact associated with this model
     * @param validations The semantic validations associated with this model
     */
	new(FileSpecification template, Infrastructure infrastructure,
		Rule<Infrastructure>... validations) {
		super(new GithubSpecification(template), infrastructure, validations)
		this.infrastructureParser = new Hcl2Infrastructure
		this.hclParser = new Infrastructure2Hcl
		this.textParser = new Hcl2Text
		this.configureSync()
	}

	/**
     * Secondary constructor.
     * @param template The template associated with this model
     * @param validations The semantic validations associated with this model
     */
	new(FileSpecification template, Rule<Infrastructure>... validations) {
		this(template, new Infrastructure, validations)
		this.logger.info(
			"Triggering synthetic update to synchronize the artefact and the specification"
		)
		this.update(this.specification, newHashMap)
	}

	/**
     * Secondary constructor constructor.
     * The infrastructure and the associated template are supposed to be in sync already.
     * @param template The template associated with this model
     * @param infrastructure The artefact associated with this model
     */
	new(FileSpecification template, Infrastructure infrastructure) {
		this(template, infrastructure, #[])
		this.logger.info(
			"Triggering synthetic update to synchronize the local specification file"
		)
		this.update(this.artefact, newHashMap)
	}

	override export() {
		new EcoreMART.Default(
			this.specification.origin.origin,
			this.artefact.origin.serialize,
			ModelPackageImpl.canonicalName,
			VirtualInfrastructure.canonicalName,
			Infrastructure.canonicalName,
			InfrastructureMart.canonicalName
		)
	}

	/**
	 * Sets the procedures to update both artefact and specification in case
	 * any of them changes.
	 */
	def private void configureSync() {
		// Use the non-observable elements to avoid infinite update loop
		super.updateSpecification = [ context |
			this.specification.origin.update(
				this.textParser.source(
					this.hclParser.specification(this.artefact.origin.model)
				),
				context
			)
		]
		super.updateArtefact = [ context |
			this.artefact.origin.model = this.infrastructureParser.model(
				new Text2Hcl(this.specification.contents).model
			)
		]
	}
}
