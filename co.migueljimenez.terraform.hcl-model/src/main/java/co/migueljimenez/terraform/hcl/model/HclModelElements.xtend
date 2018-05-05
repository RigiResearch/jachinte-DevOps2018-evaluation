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

/**
 * Facilitates instantiating the elements from the HCL model.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-04
 * @version $Id$
 * @since 0.0.1
 */
class HclModelElements {

	def specification(Resource... resources) {
		val spec = ModelFactory.eINSTANCE.createSpecification
		spec.resources.addAll(resources)
		return spec
	}

	def input(String name, Value ^default) {
		val input = ModelFactory.eINSTANCE.createInput
		input.name = name
		input.^default = ^default
		return input
	}

	def output(String name, Value value) {
		val output = ModelFactory.eINSTANCE.createOutput
		output.name = name
		output.value = value
		return output
	}

	def resource(String resourceType, String type, String name, Dictionary<Value> attributes) {
		val resource = ModelFactory.eINSTANCE.createResource
		resource.resourceType = resourceType
		resource.type = type
		resource.name = name
		resource.attributes = attributes
		return resource
	}

	def expression(Reference reference) {
		val expr = ModelFactory.eINSTANCE.createTextExpression
		expr.expression = reference
		return expr
	}

	def functionCall(String name, Value... arguments) {
		val call = ModelFactory.eINSTANCE.createFunctionCall
		call.name = name
		call.arguments.addAll(arguments)
		return call
	}

	def resourceRef(String... elements) {
		val reference = ModelFactory.eINSTANCE.createResourceReference
		reference.fullyQualifiedName.addAll(elements)
		return reference
	}

	def <V extends Value> list(java.util.List<V> value) {
		val list = ModelFactory.eINSTANCE.createList
		list.elements.addAll(value)
		return list
	}

	def <V extends Value> dictionary(String name, KeyValuePair<String, V>... value) {
		val dictionary = ModelFactory.eINSTANCE.createDictionary
		dictionary.name = name
		dictionary.elements.addAll(value)
		return dictionary
	}

	def <K, V extends Value> KeyValuePair<K, V> entry(K key, V value) {
		val pair = ModelFactory.eINSTANCE.createKeyValuePair
		pair.key = key
		pair.value = value
		return pair
	}

	def text(String contents) {
		val text = ModelFactory.eINSTANCE.createText
		text.value = contents
		return text
	}

	def number(String value) {
		val number = ModelFactory.eINSTANCE.createNumber
		number.value = value
		return number
	}

	def bool(boolean value) {
		val bool = ModelFactory.eINSTANCE.createBool
		bool.value = value
		return bool
	}
	
}