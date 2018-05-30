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

import java.io.File
import org.eclipse.xtend.lib.annotations.Accessors

/**
 * The main execution entry.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
@Accessors
class Application {

	/**
	 * The MART instance corresponding to the given template.
	 */
	val InfrastructureMart mart

	/**
	 * Default constructor.
	 */
	new(File template) {
		this.mart = new InfrastructureMart(
			new TerraformTemplate(template)
		)
	}

	/**
	 * Instantiates a new Infrastructure MART associated with the specified
	 * Terraform template as argument.
	 * 
	 * TODO in the future: support Git repository, accepting only the template
	 * file path relative to the repository. Test the local MART instance, and
	 * deploy if tests are good.
	 * 
	 * @param args This application arguments
	 */
	def static void main(String[] args) {
		if (args.length != 1)
			throw new IllegalArgumentException("The Terraform file path is expected as argument")
		new Application(new File(args.get(0)))
	}
}
