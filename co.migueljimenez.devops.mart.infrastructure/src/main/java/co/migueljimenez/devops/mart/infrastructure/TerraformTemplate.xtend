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

import com.rigiresearch.lcastane.framework.Specification
import java.io.File
import java.nio.file.Files
import java.nio.file.Paths
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import org.slf4j.LoggerFactory

/**
 * Represents a physical file compliant with Terraform template.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
@Accessors
@ToString
class TerraformTemplate implements Specification {

	/**
	 * The logger.
	 */
	val logger = LoggerFactory.getLogger(TerraformTemplate)

	/**
	 * The physical file represented by this specification.
	 */
	val File file

	/**
	 * Default constructor.
	 * @param file The physical file represented by this specification
	 */
	new(File file) {
		this.file = file
	}

	override contents() {
		new String(
			Files.readAllBytes(
				Paths.get(this.file.toURI)
			)
		)
	}

	override name() '''«TerraformTemplate.simpleName»'''

	/**
	 * Updates the physical file represented by this specification.
	 * @param contents The terraform template text
	 */
	override update(String contents) {
		this.logger.info(
			'''Saving specification to disk. File path is "«this.file»"'''
		)
		Files.write(
			Paths.get(this.file.toURI),
			contents.bytes
		)
	}
}
