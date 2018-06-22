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

import com.rigiresearch.lcastane.framework.impl.FileSpecification
import java.io.File
import java.util.Map

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
	 * Default constructor.
	 * @param file The physical file represented by this specification
	 */
	new(File file) {
		super(file)
	}

	override void update(String contents) {
		this.update(contents, newHashMap)
	}

	override void update(String contents, Map<String, Object> data) {
		super.update(contents, data)
		Runtime.runtime.exec(
			"terraform fmt -write=true",
			System.getenv.entrySet.map[e|'''«e.key»=«e.value»'''],
			this.file.parentFile
		)
	}
}
