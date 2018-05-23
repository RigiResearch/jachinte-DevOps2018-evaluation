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

import co.migueljimenez.terraform.hcl.model.HclModelElements
import co.migueljimenez.terraform.hcl.model.Reference
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.hcl.model.Value
import co.migueljimenez.terraform.parsing.HclParser
import co.migueljimenez.terraform.terraform.BooleanLiteral
import co.migueljimenez.terraform.terraform.Dictionary
import co.migueljimenez.terraform.terraform.FunctionCall
import co.migueljimenez.terraform.terraform.ListLiteral
import co.migueljimenez.terraform.terraform.NumberLiteral
import co.migueljimenez.terraform.terraform.ResourceReference
import co.migueljimenez.terraform.terraform.TextExpression
import co.migueljimenez.terraform.terraform.TextLiteral
import org.eclipse.emf.ecore.EObject
import co.migueljimenez.terraform.terraform.Template

/**
 * Instantiates an HCL model from a Terraform template.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class Text2Hcl {

	/**
	 * The source code.
	 */
	val String source

	/**
	 * The AST.
	 */
	val Template template

	/**
	 * Elements creator for the HCL model.
	 */
	val HclModelElements e

	/**
	 * Default constructor.
	 * @param specification The source code
	 */
	new(String source) {
		this.source = source
		this.template = new HclParser().parse(this.source)
		this.e = new HclModelElements
	}

	/**
	 * Parses a Terraform specification and returns the corresponding model
	 * instance.
	 */
	def Specification model() {
		val resources = newArrayList
		this.template.declarations.forEach[d|
			switch (d.resource) {
				case "variable": {
					var attr = d.value.elements.findFirst[kv|kv.key.equals("default")]
					resources.add(
						this.e.input(d.name.value, attr.value.modelValue)
					)
				}
				case "output": {
					var attr = d.value.elements.findFirst[kv|kv.key.equals("value")]
					resources.add(
						this.e.output(d.name.value, attr.value.modelValue)
					)
				}
				default: {
					resources.add(
						this.e.resource(
							d.resource,
							d.type.value,
							d.name.value,
							d.value.modelValue as co.migueljimenez.terraform.hcl.model.Dictionary<Value>
						)
					)
				}
			}
		]
		return e.specification(resources)
	}

	/**
	 * @return The AST.
	 */
	def template() {
		return this.template
	}

	/**
	 * @return The source code.
	 */
	def source() {
		return this.source
	}

	/**
	 * Maps values from the language to the model.
	 */
	def private Value modelValue(EObject dslObject) {
		switch (dslObject) {
			NumberLiteral: {
				this.e.number('''«IF dslObject.negative»-«ENDIF»«dslObject.value.toString»''')
			}
			BooleanLiteral: {
				this.e.bool(dslObject.value)
			}
			TextLiteral: {
				this.e.text(dslObject.value)
			}
			TextExpression: {
				this.e.expression(dslObject.expression.modelValue as Reference)
			}
			ResourceReference: {
				this.e.resourceRef(dslObject.references)
			}
			FunctionCall: {
				this.e.functionCall(
					dslObject.function,
					dslObject.parameters.map[p|p.modelValue]
				)
			}
			ListLiteral: {
				this.e.list(dslObject.elements.map[el|el.modelValue])
			}
			Dictionary: {
				this.e.dictionary(
					if (dslObject.name !== null) dslObject.name.value else null,
					dslObject.elements.map[p|e.entry(p.key, p.value.modelValue)]
				)
			}
		}
	}
}
