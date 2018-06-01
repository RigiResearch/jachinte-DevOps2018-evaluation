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

import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.infrastructure.model.impl.ModelPackageImpl
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
		val xml = '''
		<?xml version="1.0" encoding="ASCII"?>
		<infrastructure:VirtualInfrastructure xmi:version="2.0" xmlns:xmi="http://www.omg.org/XMI" xmlns:infrastructure="https:/migueljimenez.co/devops/infrastructure">
		  <resources resourceType="variable" name="image">
		    <attributes>
		      <elements key="ACED000574000764656661756C74" value="ACED000574000C5562756E74752031342E3034"/>
		    </attributes>
		  </resources>
		</infrastructure:VirtualInfrastructure>
		'''
		val model = new EcoreMART.Default(
			new TerraformTemplate(new File("src/test/resources/test.tf")),
			xml,
			ModelPackageImpl.canonicalName,
			VirtualInfrastructure.canonicalName,
			Infrastructure.canonicalName,
			InfrastructureMart.canonicalName
		)
		val manager = new Manager
		// If it doesn't throw exception everything is fine
		manager.register("model-id", model)
	}
}
