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

import java.nio.charset.Charset
import java.nio.file.Files
import java.nio.file.Paths
import org.junit.Test
import org.junit.Assert

/**
 * Tests {@link HclModelMapper}
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-04
 * @version $Id$
 * @since 0.0.1
 */
class HclMappingTest {

	@Test
	def void parse() {
		val url = this.class.classLoader.getResource("openstack-demo.tf")
		val contents = new String(
			Files.readAllBytes(Paths.get(url.toURI)),
			Charset.forName("UTF-8")
		)
		val mapping = new Text2Hcl(contents)
		val translated = new Hcl2Text(mapping.model).asText
		Assert.assertEquals(contents, translated)
	}
}
