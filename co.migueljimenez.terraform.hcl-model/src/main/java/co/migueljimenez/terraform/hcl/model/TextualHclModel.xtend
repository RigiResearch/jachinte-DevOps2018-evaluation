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
package co.migueljimenez.terraform.hcl.model

import java.util.PriorityQueue
import java.util.Queue
import org.eclipse.emf.ecore.EObject

/**
 * Decorates a HCL model instance.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-03
 * @version $Id$
 * @since 0.0.1
 */
class TextualHclModel {

	/**
	 * The decorated model instance.
	 */
	val Specification origin

	/**
	 * Default constructor.
	 * @param origin The decorated model instance.
	 */
	new(Specification origin) {
		this.origin = origin
	}

	def asText() {
		return this.origin.asText(new PriorityQueue)
	}

	// TODO sort/format the specification before printing it
	// TODO improve implementation by registering a procedure to transform each element
	def private String asText(EObject object, Queue<String> context) {
		context.add(object.eClass.class.canonicalName)
		val text = switch (object) {
			Specification: {
				'''«FOR r : object.resources SEPARATOR "\n"»«r.asText(context)»«ENDFOR»'''
			}
			Input: {
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
			Output: {
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
			Resource: {
				val type = if (object.type !== null) '''"«object.type»" '''
				'''«object.resourceType» «type»"«object.name»" «object.attributes.asText(context)»'''
			}
			TextExpression: {
				'''"${«object.expression.asText(context)»}"'''
			}
			ResourceReference: {
				val className = ModelPackage.eINSTANCE.functionCall.class.canonicalName
				val qm = if (context.peek.equals(className)) "" else '"'
				'''«qm»«FOR e : object.fullyQualifiedName SEPARATOR '.'»«e»«ENDFOR»«qm»'''
			}
			FunctionCall: {
				'''
				«object.name»(
				«FOR e : object.arguments SEPARATOR ', '»
					«e.asText(context)»
				«ENDFOR»
				)'''
			}
			Dictionary<Value>: {
				val className = ModelPackage.eINSTANCE.dictionary.class.canonicalName
				'''
				«IF object.name !== null»
					"«object.name»" 
				«ENDIF»
				{
					«FOR p : object.elements»
						«p.key» «IF !(p.value instanceof Dictionary<?> && context.peek.equals(className))»= «ENDIF»«p.value.asText(context)»
					«ENDFOR»
				}'''
			}
			List: {
				'''[«FOR v : object.elements SEPARATOR ", "»«v.asText(context)»«ENDFOR»]'''
			}
			Number: {
				'''«object.value»'''
			}
			Text: {
				'''"«object.value.toString»"'''
			}
			Bool: {
				object.value.toString
			}
		}
		context.remove
		return text
	}
	
}