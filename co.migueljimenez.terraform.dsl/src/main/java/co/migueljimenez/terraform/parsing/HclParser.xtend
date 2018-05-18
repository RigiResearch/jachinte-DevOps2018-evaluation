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
package co.migueljimenez.terraform.parsing

import co.migueljimenez.terraform.TerraformStandaloneSetup
import com.google.inject.Injector
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.validation.IResourceValidator
import java.io.ByteArrayInputStream
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.diagnostics.Severity
import co.migueljimenez.terraform.terraform.Template

/**
 * Parses HCL-compliant code into the grammar model.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
class HclParser {

	static var Injector INJECTOR = new TerraformStandaloneSetup().createInjectorAndDoEMFRegistration
	static var XtextResourceSet RESOURCE_SET = HclParser.initialize
	static var IResourceValidator VALIDATOR = HclParser.INJECTOR.getInstance(IResourceValidator)

	/**
	 * Initializes the Xtext result set.
	 */
	def static initialize() {
		val resourceSet = HclParser.INJECTOR.getInstance(XtextResourceSet)
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		return resourceSet
	}

	/**
	 * Parses a Terraform specification and returns the AST using the grammar
	 * elements.
	 */
	def parse(String specification) {
		val resource = this.temporalResource
		resource.load(new ByteArrayInputStream(specification.bytes), newHashMap)
		val issues = HclParser.VALIDATOR.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl)
		val errors = issues.filter[i|i.severity.equals(Severity.ERROR)]
		if (!errors.empty) {
			issues.forEach[i|System.err.println(i)]
			throw new Exception("The specification couldn't be parsed")
		}
		return resource.contents.get(0) as Template
	}

	/**
	 * Creates a temporal Xtext resource.
	 */
	def private temporalResource() {
		val uri = URI.createURI('''temp-«Math.abs(Math.random())».tf''')
		var resource = HclParser.RESOURCE_SET.resources
			.findFirst[r|r.URI.toFileString.equals(uri.toFileString)]
		if (resource === null)
			resource = HclParser.RESOURCE_SET.createResource(uri)
		resource.unload
		return resource
	}
}
