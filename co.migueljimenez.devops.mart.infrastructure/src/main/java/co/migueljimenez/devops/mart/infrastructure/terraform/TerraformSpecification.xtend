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
package co.migueljimenez.devops.mart.infrastructure.terraform

import com.rigiresearch.lcastane.framework.impl.FileSpecification
import java.io.File
import java.util.List
import java.util.Map
import org.eclipse.xtend.lib.annotations.Data
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.slf4j.LoggerFactory
import java.io.InputStream

/**
 * File-based specification that executes Terraform to format the specification
 * every time it is updated.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-14
 * @version $Id$
 * @since 0.0.1
 */
class TerraformSpecification extends FileSpecification {

	/**
	 * Represents a (simple) Terraform import.
	 * <p>
	 * This implementation, as well as the Terraform facilities implemented in
	 * this project, assume that the resource name is the same as the
	 * <code>name</code> attribute.
	 * @author Miguel Jimenez (miguel@uvic.ca)
	 * @date 2018-06-22
	 * @version $Id$
	 * @since 0.0.1
	 */
	@Data
	@FinalFieldsConstructor
	static class TerraformImport {
		/**
		 * The resource type.
		 */
		val String type

		/**
		 * The resource name.
		 */
		val String name
	}

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(TerraformSpecification)

	/**
	 * Pending imports per specification file.
	 */
	val static Map<File, List<TerraformImport>> IMPORTS = newHashMap

	/**
	 * The environment variables to execute Terraform commands.
	 */
	val List<String> environment = newArrayList

	/**
	 * Default constructor.
	 * @param file The physical file represented by this specification
	 */
	new(File file) {
		super(file)
		this.initialise
	}

	def private initialise() {
		if (!TerraformSpecification.IMPORTS.containsKey(this.file))
			TerraformSpecification.IMPORTS.put(this.file, newArrayList)
		val osConf = new Configurations().properties("openstack.properties")
		osConf.keys.forEach[k|this.environment.add('''«k»=«osConf.getString(k)»''')]
		this.environment.addAll(System.getenv.entrySet.map[e|'''«e.key»=«e.value»'''])
		this.execute("terraform init")
	}

	override void update(String contents) {
		this.update(contents, newHashMap)
	}

	override void update(String contents, Map<String, Object> data) {
		super.update(contents, data)
		this.initialise
		this.execute("terraform fmt -write=true")
		val imports = TerraformSpecification.IMPORTS.get(this.file)
		synchronized(imports) {
			imports.forEach [ i |
				this.execute('''terraform import «i.type».«i.name» «i.name»''')
			]
			imports.clear
		}
	}

	def private execute(String terraformCommand) {
		val process = Runtime.runtime.exec(
			terraformCommand,
			this.environment,
			this.file.parentFile
		)
		process.waitFor
		this.logger.info('''Executed "«terraformCommand»" (dir: «this.file.parentFile»)''')
		if (process.exitValue != 0)
			this.logger.error(
				'''Exit value is «process.exitValue». Error output is: «process.errorStream.convertToString»'''
			)
	}

	def static deferImport(File specificationFile, TerraformImport ^import) {
		if (!TerraformSpecification.IMPORTS.containsKey(specificationFile))
			TerraformSpecification.IMPORTS.put(specificationFile, newArrayList)
		TerraformSpecification.IMPORTS
			.get(specificationFile)
			.add(^import)
	}

	def String convertToString(InputStream is) {
	    val s = new java.util.Scanner(is).useDelimiter("\\A")
	    if (s.hasNext())
	    	s.next
	    else
	    	""
	}
}
