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
package co.migueljimenez.terraform.mapping

import co.migueljimenez.terraform.hcl.model.Bool
import co.migueljimenez.terraform.hcl.model.Dictionary
import co.migueljimenez.terraform.hcl.model.FunctionCall
import co.migueljimenez.terraform.hcl.model.Input
import co.migueljimenez.terraform.hcl.model.List
import co.migueljimenez.terraform.hcl.model.ModelPackage
import co.migueljimenez.terraform.hcl.model.Number
import co.migueljimenez.terraform.hcl.model.Output
import co.migueljimenez.terraform.hcl.model.Resource
import co.migueljimenez.terraform.hcl.model.ResourceReference
import co.migueljimenez.terraform.hcl.model.Specification
import co.migueljimenez.terraform.hcl.model.Text
import co.migueljimenez.terraform.hcl.model.TextExpression
import co.migueljimenez.terraform.hcl.model.Value
import java.util.PriorityQueue
import java.util.Queue
import org.eclipse.emf.ecore.EObject

/**
 * Translates an HCL model instance (a {@link Specification}) to a Terraform
 * template.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class Hcl2Text {

	/**
	 * The decorated model instance.
	 */
	val Specification origin

	/**
	 * Default constructor.
	 * @param origin The decorated model instance.
	 */
	new(Specification model) {
		this.origin = model
	}

	/**
	 * Returns a text representation of the decorated model instance.
	 */
	def asText() {
		return this.origin.asText(new PriorityQueue)
	}

	/**
	 * Translates an {@link EObject} from the HCL model to a {@link String}.
	 * TODO sort/format the specification before printing it
	 */
	def protected String asText(EObject object, Queue<String> context) {
		context.add(object.eClass.class.canonicalName)
		val text = switch (object) {
			Bool: object.asText(context)
			Dictionary<Value>: object.asText(context)
			FunctionCall: object.asText(context)
			Input: object.asText(context)
			Output: object.asText(context)
			List: object.asText(context)
			Number: object.asText(context)
			ResourceReference: object.asText(context)
			Specification: object.asText(context)
			Text: object.asText(context)
			TextExpression: object.asText(context)
			// It's at the end to prevent inputs and outputs from being
			// processed as simple resources
			Resource: {
				val type = if (object.type !== null) '''"«object.type»" '''
				'''«object.resourceType» «type»"«object.name»" «object.attributes.asText(context)»'''
			}
		}
		context.remove
		return text
	}

	/**
	 * Translates a {@link Bool} from the HCL model to a {@link String}.
	 */
	def protected String asText(Bool object, Queue<String> context) {
		object.value.toString
	}

	/**
	 * Translates a {@link Dictionary} from the HCL model to a {@link String}.
	 */
	def protected String asText(Dictionary<Value> object, Queue<String> context) {
		val className = ModelPackage.eINSTANCE.dictionary.class.canonicalName
		'''
		«IF object.name !== null»
			"«object.name»" «ENDIF»{
			«FOR p : object.elements»
				«p.key» «IF !(p.value instanceof Dictionary<?> && context.peek.equals(className))»= «ENDIF»«p.value.asText(context)»
			«ENDFOR»
		}'''
	}

	/**
	 * Translates a {@link FunctionCall} from the HCL model to a {@link String}.
	 */
	def protected String asText(FunctionCall object, Queue<String> context) {
		'''«object.name»(«FOR e : object.arguments SEPARATOR ', '»«e.asText(context)»«ENDFOR»)'''
	}

	/**
	 * Translates an {@link Input} from the HCL model to a {@link String}.
	 */
	def protected String asText(Input object, Queue<String> context) {
		// Ignore extra attributes
		'''
		variable "«object.name»" {
			default = «object.^default.asText(context)»
			«IF object.description !== null»
				description = «object.description»
			«ENDIF»
			«IF object.type !== null»
				type = «object.type»
			«ENDIF»
		}'''
	}

	/**
	 * Translates an {@link Output} from the HCL model to a {@link String}.
	 */
	def protected String asText(Output object, Queue<String> context) {
		// Ignore extra attributes
		'''
		output "«object.name»" {
			«IF object.description !== null»
				description = «object.description»
			«ENDIF»
			sensitive = «object.sensitive»
			value = «object.value.asText(context)»
		}'''
	}

	/**
	 * Translates a {@link List} from the HCL model to a {@link String}.
	 */
	def protected String asText(List object, Queue<String> context) {
		'''[«FOR v : object.elements SEPARATOR ", "»«v.asText(context)»«ENDFOR»]'''
	}

	/**
	 * Translates a {@link Number} from the HCL model to a {@link String}.
	 */
	def protected String asText(Number object, Queue<String> context) {
		'''«object.value»'''
	}

	/**
	 * Translates a {@link ResourceReference} from the HCL model to a {@link String}.
	 */
	def protected String asText(ResourceReference object, Queue<String> context) {
		val className = ModelPackage.eINSTANCE.functionCall.class.canonicalName
		val qm = if (context.peek.equals(className)) "" else '"'
		'''«qm»«FOR e : object.fullyQualifiedName SEPARATOR '.'»«e»«ENDFOR»«qm»'''
	}

	/**
	 * Translates a {@link Specification} from the HCL model to a {@link String}.
	 */
	def protected String asText(Specification object, Queue<String> context) {
		'''«FOR r : object.resources SEPARATOR "\n"»«r.asText(context)»«ENDFOR»'''
	}

	/**
	 * Translates a {@link Text} from the HCL model to a {@link String}.
	 */
	def protected String asText(Text object, Queue<String> context) {
		'''"«object.value.toString»"'''
	}

	/**
	 * Translates a {@link TextExpression} from the HCL model to a {@link String}.
	 */
	def protected String asText(TextExpression object, Queue<String> context) {
		'''"${«object.expression.asText(context)»}"'''
	}
}
