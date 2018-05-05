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
package co.migueljimenez.terraform.mapper

import co.migueljimenez.terraform.TerraformStandaloneSetup
import co.migueljimenez.terraform.hcl.model.HclModelElements
import co.migueljimenez.terraform.hcl.model.Reference
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.hcl.model.TextualHclModel
import co.migueljimenez.terraform.hcl.model.Value
import co.migueljimenez.terraform.terraform.BooleanLiteral
import co.migueljimenez.terraform.terraform.Dictionary
import co.migueljimenez.terraform.terraform.FunctionCall
import co.migueljimenez.terraform.terraform.ListLiteral
import co.migueljimenez.terraform.terraform.NumberLiteral
import co.migueljimenez.terraform.terraform.ResourceReference
import co.migueljimenez.terraform.terraform.Template
import co.migueljimenez.terraform.terraform.TextExpression
import co.migueljimenez.terraform.terraform.TextLiteral
import com.google.inject.Injector
import java.io.ByteArrayInputStream
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.IResourceValidator

/**
 * Maps elements from the Terraform grammar to the HCL model and vice versa.
 * TODO rename this class
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class HclMapping {

	static var Injector INJECTOR = new TerraformStandaloneSetup().createInjectorAndDoEMFRegistration
	static var XtextResourceSet RESOURCE_SET = HclMapping.initialize
	static var IResourceValidator VALIDATOR = HclMapping.INJECTOR.getInstance(IResourceValidator)

	/**
	 * Initializes the Xtext result set.
	 */
	def static initialize() {
		val resourceSet = HclMapping.INJECTOR.getInstance(XtextResourceSet)
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		return resourceSet
	}

	/**
	 * Returns the textual representation of the given model element.
	 */
	def asText(Specification specification) {
		new TextualHclModel(specification).asText
	}

	/**
	 * Parses a Terraform specification and returns the corresponding model
	 * instance.
	 */
	def Specification model(String specification) {
		val resources = newArrayList
		val template = this.parse(specification)
		val e = new HclModelElements
		template.declarations.forEach[d|
			switch (d.resource) {
				case "variable": {
					var attr = d.value.elements.findFirst[kv|kv.key.equals("default")]
					resources.add(
						e.input(d.name.value, attr.value.modelValue(e))
					)
				}
				case "output": {
					var attr = d.value.elements.findFirst[kv|kv.key.equals("value")]
					resources.add(
						e.output(d.name.value, this.modelValue(attr.value, e))
					)
				}
				default: {
					resources.add(
						e.resource(
							d.resource,
							d.type.value,
							d.name.value,
							d.value.modelValue(e) as co.migueljimenez.terraform.hcl.model.Dictionary<Value>
						)
					)
				}
			}
		]
		return e.specification(resources)
	}

	/**
	 * Maps values from the language to the model.
	 * TODO improve this implementation: allow to register a procedure to transform each element
	 */
	def private Value modelValue(EObject dslObject, HclModelElements e) {
		switch (dslObject) {
			NumberLiteral: {
				e.number('''«IF dslObject.negative»-«ENDIF»«dslObject.value.toString»''')
			}
			BooleanLiteral: {
				e.bool(dslObject.value)
			}
			TextLiteral: {
				e.text(dslObject.value)
			}
			TextExpression: {
				e.expression(dslObject.expression.modelValue(e) as Reference)
			}
			ResourceReference: {
				e.resourceRef(dslObject.references)
			}
			FunctionCall: {
				e.functionCall(
					dslObject.function,
					dslObject.parameters.map[p|p.modelValue(e)]
				)
			}
			ListLiteral: {
				e.list(dslObject.elements.map[el|el.modelValue(e)])
			}
			Dictionary: {
				e.dictionary(
					if (dslObject.name !== null) dslObject.name.value else null,
					dslObject.elements.map[p|e.entry(p.key, p.value.modelValue(e))]
				)
			}
		}
	}

	/**
	 * Parses a Terraform specification and returns the AST using the grammar
	 * elements.
	 */
	def parse(String specification) {
		val uri = URI.createURI('''temp-«Math.abs(Math.random())».tf''')
		var resource = HclMapping.RESOURCE_SET.resources
			.findFirst[r|r.URI.toFileString.equals(uri.toFileString)]
		if (resource === null)
			resource = HclMapping.RESOURCE_SET.createResource(uri)
		resource.unload
		resource.load(new ByteArrayInputStream(specification.bytes), newHashMap)
		val issues = HclMapping.VALIDATOR.validate(resource, CheckMode.ALL, CancelIndicator.NullImpl)
		val errors = issues.filter[i|i.severity.equals(Severity.ERROR)]
		if (!errors.empty) {
			issues.forEach[i|System.err.println(i)]
			throw new Exception("The specification couldn't be parsed")
		}
		return resource.contents.get(0) as Template
	}
}
