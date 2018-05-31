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

import co.migueljimenez.devops.transformation.Hcl2Infrastructure
import co.migueljimenez.devops.transformation.Hcl2Text
import co.migueljimenez.devops.transformation.Infrastructure2Hcl
import co.migueljimenez.devops.transformation.Text2Hcl
import com.rigiresearch.lcastane.framework.MART
import com.rigiresearch.lcastane.framework.ObservableArtefact
import com.rigiresearch.lcastane.framework.ObservableSpecification
import java.util.Observable
import java.util.Observer
import com.rigiresearch.lcastane.framework.validation.ValidationException
import com.rigiresearch.lcastane.framework.Rule

/**
 * Represents a virtual infrastructure MART.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
class InfrastructureMart
	implements MART<TerraformTemplate, Infrastructure>, Observer {

	/**
	 * The specification associated with this model.
	 */
	val ObservableSpecification<TerraformTemplate> specification

	/**
	 * This MARTS's artefact.
	 */
	val ObservableArtefact<Infrastructure> artefact

	/**
	 * The semantic validations associated with this MART.
	 */
	val Rule<Infrastructure>[] validations

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
     * Default constructor.
     * @param template The template associated with this model
     */
	new(TerraformTemplate template, Rule<Infrastructure>... validations) {
		this.validations = validations
		this.infrastructureParser = new Hcl2Infrastructure
		this.hclParser = new Infrastructure2Hcl
		this.textParser = new Hcl2Text
		this.specification = new ObservableSpecification(template)
		this.specification.addObserver(this)
		this.artefact = new ObservableArtefact(new Infrastructure)
		this.artefact.addObserver(this)
		// Trigger a synthetic update to synchronize the models
		this.update(specification, template)
	}

	override artefact() {
		this.artefact.origin
	}

	override specification() {
		this.specification.origin
	}

	override validate() throws ValidationException {
		this.validations.forEach [ v |
			if (!v.apply(this.artefact.origin))
				throw new ValidationException(this.artefact.origin, v)
		]
	}

	override update(Observable observable, Object argument) {
		// Update the observed object directly to avoid an infinite loop
		switch (argument) {
			ObservableArtefact<Infrastructure>: {
				this.specification.origin.update(
					this.textParser.source(
						this.hclParser.specification(argument.origin.model)
					)
				)
			}
			ObservableSpecification<TerraformTemplate>: {
				// TODO Implement a diff mechanism to update the model
				this.artefact.origin.model = this.infrastructureParser.model(
					new Text2Hcl(argument.contents).model
				)
			}
		}
	}
}
