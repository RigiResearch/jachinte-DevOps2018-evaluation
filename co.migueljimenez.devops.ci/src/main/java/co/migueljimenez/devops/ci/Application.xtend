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
package co.migueljimenez.devops.ci

import co.migueljimenez.devops.infrastructure.model.VirtualInfrastructure
import co.migueljimenez.devops.mart.infrastructure.Infrastructure
import co.migueljimenez.devops.mart.infrastructure.InfrastructureMart
import co.migueljimenez.devops.mart.infrastructure.TerraformTemplate
import co.migueljimenez.devops.mart.infrastructure.validation.ConstrainedRam
import com.rigiresearch.lcastane.framework.EcoreMART
import com.rigiresearch.lcastane.framework.validation.ValidationException
import com.rigiresearch.lcastane.primor.ManagerService
import com.rigiresearch.lcastane.primor.RemoteService
import de.xn__ho_hia.storage_unit.StorageUnits
import java.io.File
import java.rmi.registry.LocateRegistry
import java.rmi.registry.Registry
import org.apache.commons.configuration2.Configuration
import org.apache.commons.configuration2.builder.fluent.Configurations

/**
 * The main execution entry.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
class Application {

	/**
	 * The local template file.
	 */
	val File localTemplate

	/**
	 * The MART instance associated with the input template.
	 */
	val InfrastructureMart mart

	/**
	 * The (remote) RMI registry.
	 */
	val Registry registry

	/**
	 * The PrIMoR's model manager.
	 */
	val ManagerService models

	/**
	 * The PrIMoR properties configuration.
	 */
	val Configuration primorConfig

	/**
	 * Default constructor.
	 * @param template The template associated with the MART's specification
	 */
	new(File template) {
		this.localTemplate = template
		this.mart = new InfrastructureMart(
			new TerraformTemplate(template),
			new ConstrainedRam(StorageUnits.gigabyte(1L))
		)
		this.primorConfig = new Configurations().properties("primor.properties")
		this.registry = LocateRegistry.getRegistry(
			this.primorConfig.getString("manager-host"),
			this.primorConfig.getInt("manager-port")
		)
		this.models =
			this.registry.lookup(RemoteService.MANAGER.toString) as ManagerService
	}

	/**
	 * Validates the MART.
	 */
	def validate() {
		try {
			this.mart.validate()
		} catch (ValidationException e) {
			System.err.println(e.message)
			System.exit(1)
		}
	}

	/**
	 * Registers the MART on PrIMoR.
	 */
	def deploy() {
		this.models.register(
			this.localTemplate.toString,
			new EcoreMART.Default(
				this.mart.specification,
				this.mart.artefact.serialize,
				VirtualInfrastructure.canonicalName,
				Infrastructure.canonicalName,
				InfrastructureMart.canonicalName
			)
		)
	}

	def static void main(String[] args) {
		if (args.length != 1)
			throw new IllegalArgumentException("A Terraform file path is expected")
		val app = new Application(new File(args.get(0)))
		app.validate
		app.deploy
	}
}
