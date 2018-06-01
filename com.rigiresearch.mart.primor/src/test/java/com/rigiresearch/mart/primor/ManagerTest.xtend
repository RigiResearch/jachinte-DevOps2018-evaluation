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
package com.rigiresearch.mart.primor

import co.migueljimenez.devops.infrastructure.model.InfrastructureModelElements
import co.migueljimenez.devops.infrastructure.model.SerializationParser
import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import co.migueljimenez.devops.mart.infrastructure.InfrastructureMart
import co.migueljimenez.devops.mart.infrastructure.TerraformTemplate
import com.rigiresearch.lcastane.framework.EcoreMART
import com.rigiresearch.lcastane.primor.Manager
import java.io.File
import org.junit.Test

/**
 * Tests {@link Manager}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-01
 * @version $Id$
 * @since 0.0.1
 */
class ManagerTest {

	@Test
	def void ecoreMart() {
		val i = new InfrastructureModelElements
		val parser = new SerializationParser
		val project = i.infrastructure
		i.unknownResource(
			"variable",
			null,
			"image",
			#[i.entry("default", "Ubuntu 14.04")],
			project
		)
		val model = new EcoreMART.Default(
			new TerraformTemplate(new File("src/test/resources/test.tf")),
			parser.asXml(project),
			VirtualInfrastructure.canonicalName,
			Infrastructure.canonicalName,
			InfrastructureMart.canonicalName
		)
		val manager = new Manager
		// If it doesn't throw exception everything is fine
		manager.register("model-id", model)
	}
}
