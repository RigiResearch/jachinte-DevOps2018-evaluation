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
package co.migueljimenez.terraform.validation

import co.migueljimenez.terraform.terraform.Declaration
import co.migueljimenez.terraform.terraform.FunctionCall
import co.migueljimenez.terraform.terraform.ResourceReference
import co.migueljimenez.terraform.terraform.Template
import co.migueljimenez.terraform.terraform.TerraformPackage
import org.eclipse.xtext.EcoreUtil2
import org.eclipse.xtext.validation.Check

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class TerraformValidator extends AbstractTerraformValidator {

	public static val IMPLICIT_ATTRIBUTE_REFERENCE = "implicitAttributeReference"	
	public static val INVALID_DECLARATION = "invalidResourceName"
	public static val INVALID_REFERENCE = "invalidReference"
	public static val UNKNOWN_FUNCTION = "unknownFunctionName"
	public static val UNKNOWN_RESOURCE_REFERENCE = "unknownResourceReference"

	/**
	 * List of accepted resources
	 */
	static val resources = #["variable", "output", "provider", "resource"]

	/**
	 * List of supported functions
	 * From: https://gist.github.com/davewongillies/251277c068bea5466d1583aafc4096ea
	 */
	static val functions = #[
		"abs", "basename", "base64decode", "base64encode", "base64gzip",
		"base64sha256", "base64sha512", "bcrypt", "ceil", "chomp", "cidrhost",
		"cidrnetmask", "cidrsubnet", "coalesce", "coalescelist", "compact", "concat",
		"contains", "dirname", "distinct", "element", "chunklist", "file", "floor",
		"flatten", "format", "formatlist", "indent", "index", "join", "jsonencode",
		"keys", "length", "list", "log", "lookup", "lower", "map", "matchkeys", "max",
		"merge", "min", "md5", "pathexpand", "pow", "replace", "sha1", "sha256", "sha512",
		"signum", "slice", "sort", "split", "timestamp", "title", "transpose", "trimspace",
		"upper", "urlencode", "uuid", "values", "zipmap"
	]

	@Check
	def checkDeclaration(Declaration declaration) {
		if (!TerraformValidator.resources.contains(declaration.resource)) {
			error(
				'''Unknown resource "«declaration.resource»"''',
				TerraformPackage.Literals.DECLARATION__RESOURCE,
				INVALID_DECLARATION
			)
		}
	}

	@Check
	def checkFunctionCall(FunctionCall functionCall) {
		// TODO Validate function parameters
		if (!TerraformValidator.functions.contains(functionCall.function)) {
			error(
				'''Unknown function "«functionCall.function»"''',
				TerraformPackage.Literals.FUNCTION_CALL__FUNCTION,
				UNKNOWN_FUNCTION
			)
		}
	}

	@Check
	def checkResourceRef(ResourceReference resourceRef) {
		val template = EcoreUtil2.getRootContainer(resourceRef) as Template
		var resources = newLinkedHashMap()
		for (declaration : template.declarations) {
			if (declaration.resource.equals("resource")) {
				// key is resource type
				if (!resources.containsKey(declaration.type.value))
					resources.put(declaration.type.value, newArrayList)
				resources
					.get(declaration.type.value)
					.add(declaration.name.value -> declaration.value.elements.map[p|p.key])
			} else {
				// key is resource
				val resource = if (declaration.resource.equals("variable")) "var" else declaration.resource
				if (!resources.containsKey(resource))
					resources.put(resource, newArrayList)
				resources
					.get(resource)
					.add(declaration.name.value -> declaration.value.elements.map[p|p.key])
			}
		}
		val type = resourceRef.references.get(0)
		val name = resourceRef.references.get(1)
		if (resources.containsKey(type)) {
			if (resources.get(type).map[p|p.key].contains(name)) {
				if (resourceRef.references.size > 2) {
					val attr = resourceRef.references.get(2)
					val resource = resources.get(type).findFirst[p|p.key.equals(name)]
					if (!resource.value.contains(attr))
						warning(
							'''Attribute «attr» could not be checked in resource «resource.key»''',
							TerraformPackage.Literals.RESOURCE_REFERENCE__REFERENCES,
							IMPLICIT_ATTRIBUTE_REFERENCE
						)
				}
			} else {
				error(
				'''Unknown resource «name»''',
					TerraformPackage.Literals.RESOURCE_REFERENCE__REFERENCES,
					UNKNOWN_RESOURCE_REFERENCE
				)
			}
		} else {
			error(
				'''Unknown resource «type»''',
				TerraformPackage.Literals.RESOURCE_REFERENCE__REFERENCES,
				UNKNOWN_RESOURCE_REFERENCE
			)
		}
	}

	@Check
	def checkOutputRef(ResourceReference resourceReference) {
		if (resourceReference.references.get(0).equals("output")) {
			error(
				'''Invalid reference to output "«resourceReference.references.join(".")»"''',
				TerraformPackage.Literals.RESOURCE_REFERENCE__REFERENCES,
				INVALID_REFERENCE
			)
		}
	}
	
}
