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
import java.io.InputStream
import java.util.List
import java.util.Map
import java.util.Scanner
import org.apache.commons.configuration2.builder.fluent.Configurations
import org.slf4j.LoggerFactory

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
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(TerraformSpecification)

	/**
	 * Pending commands per model (specification file).
	 */
	val static Map<File, List<String>> COMMANDS = newHashMap

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

	/**
	 * Sets the specification file.
	 */
	override file(File file) {
		if (COMMANDS.containsKey(this.file)) {
			COMMANDS.put(file, COMMANDS.remove(this.file))
		}
		super.file(file)
	}

	def private initialise() {
		if (!COMMANDS.containsKey(this.file)) {
			COMMANDS.put(this.file, newArrayList)
			val osConf = new Configurations().properties("openstack.properties")
			osConf.keys.forEach[k|this.environment.add('''«k»=«osConf.getString(k)»''')]
			this.environment.addAll(System.getenv.entrySet.map[e|'''«e.key»=«e.value»'''])
			this.execute("terraform init -input=false")
		}
	}

	override void update(String contents) {
		this.update(contents, newHashMap)
	}

	override void update(String contents, Map<String, Object> data) {
		super.update(contents, data)
		this.initialise
		this.execute("terraform fmt -write=true")
		val commands = TerraformSpecification.COMMANDS.get(this.file)
		synchronized(commands) {
			commands.forEach[c|this.execute(c)]
			commands.clear
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

	def static deferCommand(File specificationFile, String command) {
		if (!COMMANDS.containsKey(specificationFile))
			COMMANDS.put(specificationFile, newArrayList)
		COMMANDS.get(specificationFile).add(command)
	}

	def String convertToString(InputStream is) {
	    val s = new Scanner(is).useDelimiter("\\A")
	    if (s.hasNext())
	    	s.next
	    else
	    	""
	}
}
