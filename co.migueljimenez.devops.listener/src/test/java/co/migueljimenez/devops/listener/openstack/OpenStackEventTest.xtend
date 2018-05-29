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
package co.migueljimenez.devops.listener.openstack

import com.fasterxml.jackson.databind.ObjectMapper
import org.junit.Assert
import org.junit.Test

/**
 * Tests {@link OpenStackEvent}.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-29
 * @version $Id$
 * @since 0.0.1
 */
class OpenStackEventTest {

	@Test
	def instantiation1() {
		// This input is not complete
		val input = '''
		{
		  "_context_domain":null,
		  "_context_roles":[
		    "admin"
		  ],
		  "_context_global_request_id":null,
		  "_context_quota_class":null,
		  "event_type":"keypair.create.start",
		  "_context_request_id":"req-18c635dd-541d-4834-b9b2-5399dbe79559",
		  "timestamp":"2018-05-29 18:35:45.383536",
		  "_context_user":"f7b01aaf29cc446383f83f04396d6f3f",
		  "_unique_id":"ca8424a13f40406783a48a0ed39840ce",
		  "_context_resource_uuid":null,
		  "_context_instance_lock_checked":false,
		  "_context_is_admin_project":true,
		  "_context_user_id":"f7b01aaf29cc446383f83f04396d6f3f",
		  "payload":{
		    "tenant_id":"a9434954adf940a3bdbdaab99e8751bb",
		    "user_id":"f7b01aaf29cc446383f83f04396d6f3f",
		    "key_name":"mykeypair"
		  },
		  "_context_project_name":"devops-project",
		  "_context_read_deleted":"no",
		  "_context_user_identity":"f7b01aaf29cc446383f83f04396d6f3f a9434954adf940a3bdbdaab99e8751bb - default default",
		  "_context_auth_token":"gAAAAABbDZ1258hhCtDFuP4Si12LSLw8ntBNurqK8JgieU6D9nofgK-ngMmrgQuoJ_8ZqcB-okfJGx9tkYilzmO3dioFTzxjSIcbTtICeDynL2EqbFKi8Y9tuORL08td-Q5wam8c7xgnck_90ppPEEa-fIneG2uRt-8EBhCN7trNF-6TulTI2VX-B4ECXqM8Ihdp74yPvngr",
		  "_context_show_deleted":false,
		  "_context_tenant":"a9434954adf940a3bdbdaab99e8751bb",
		  "priority":"INFO",
		  "_context_read_only":false,
		  "_context_is_admin":true,
		  "_context_project_id":"a9434954adf940a3bdbdaab99e8751bb",
		  "_context_project_domain":"default",
		  "_context_timestamp":"2018-05-29T18:35:45.046384",
		  "_context_user_domain":"default",
		  "_context_user_name":"devops-admin",
		  "publisher_id":"api.packstack-instance.openstacklocal",
		  "message_id":"2f32134e-4364-41b8-b43b-8042c0f8dc7b",
		  "_context_project":"a9434954adf940a3bdbdaab99e8751bb",
		  "_context_remote_address":"100.100.100.100"
		}'''
		val mapper = new ObjectMapper()
		val event = mapper.readValue(input, OpenStackEvent)
		Assert.assertNotNull(event)
	}

	@Test
	def instantiation2() {
		val input = '''
		{
		  "oslo.message":"{\"_context_domain\": null, \"_context_roles\": [\"admin\"], \"_context_global_request_id\": null, \"_context_quota_class\": null, \"event_type\": \"keypair.delete.start\", \"_context_request_id\": \"req-cd2f8512-57a4-4573-8b8f-ac985779990f\", \"_context_service_catalog\": [{\"endpoints\": [{\"adminURL\": \"http://192.168.113.5:8778/placement\", \"region\": \"RegionOne\", \"internalURL\": \"http://192.168.113.5:8778/placement\", \"publicURL\": \"http://206.167.181.110:8778/placement\"}], \"type\": \"placement\", \"name\": \"placement\"}, {\"endpoints\": [{\"adminURL\": \"http://192.168.113.5:8776/v3/a9434954adf940a3bdbdaab99e8751bb\", \"region\": \"RegionOne\", \"internalURL\": \"http://192.168.113.5:8776/v3/a9434954adf940a3bdbdaab99e8751bb\", \"publicURL\": \"http://206.167.181.110:8776/v3/a9434954adf940a3bdbdaab99e8751bb\"}], \"type\": \"volumev3\", \"name\": \"cinderv3\"}, {\"endpoints\": [{\"adminURL\": \"http://192.168.113.5:9696\", \"region\": \"RegionOne\", \"internalURL\": \"http://192.168.113.5:9696\", \"publicURL\": \"http://206.167.181.110:9696\"}], \"type\": \"network\", \"name\": \"neutron\"}, {\"endpoints\": [{\"adminURL\": \"http://192.168.113.5:9292\", \"region\": \"RegionOne\", \"internalURL\": \"http://192.168.113.5:9292\", \"publicURL\": \"http://206.167.181.110:9292\"}], \"type\": \"image\", \"name\": \"glance\"}], \"timestamp\": \"2018-05-29 20:12:38.640725\", \"_context_user\": \"f7b01aaf29cc446383f83f04396d6f3f\", \"_unique_id\": \"a7272b841bf348b88e3c37956a708765\", \"_context_resource_uuid\": null, \"_context_instance_lock_checked\": false, \"_context_is_admin_project\": true, \"_context_user_id\": \"f7b01aaf29cc446383f83f04396d6f3f\", \"payload\": {\"tenant_id\": \"a9434954adf940a3bdbdaab99e8751bb\", \"user_id\": \"f7b01aaf29cc446383f83f04396d6f3f\", \"key_name\": \"mykeypair2\"}, \"_context_project_name\": \"devops-project\", \"_context_read_deleted\": \"no\", \"_context_user_identity\": \"f7b01aaf29cc446383f83f04396d6f3f a9434954adf940a3bdbdaab99e8751bb - default default\", \"_context_auth_token\": \"gAAAAABbDbMs8qspfZKwBP0ity5PW8Y1uUhLT6oW6CaebDwLzgIz1iod_caff78-t74YaG_ExoGOpGSzfpeMXUCrXPcqLB8MEnE22evHY83QlbAzuAIbf3EQqy8nRnp50pkqal6q1E90VtzH3nbe2vTTB3C_B_cpT7ZN2lNI1DarlM38syEYn-74Xhx-hlCzHdblZcau_zNB\", \"_context_show_deleted\": false, \"_context_tenant\": \"a9434954adf940a3bdbdaab99e8751bb\", \"priority\": \"INFO\", \"_context_read_only\": false, \"_context_is_admin\": true, \"_context_project_id\": \"a9434954adf940a3bdbdaab99e8751bb\", \"_context_project_domain\": \"default\", \"_context_timestamp\": \"2018-05-29T20:12:38.632015\", \"_context_user_domain\": \"default\", \"_context_user_name\": \"devops-admin\", \"publisher_id\": \"api.packstack-instance.openstacklocal\", \"message_id\": \"c92ddae1-9147-4f43-bc01-4de4ef837e55\", \"_context_project\": \"a9434954adf940a3bdbdaab99e8751bb\", \"_context_remote_address\": \"100.100.100.100\"}",
		  "oslo.version":"2.0"
		}'''
		val mapper = new ObjectMapper()
		val innerMessage = mapper.readTree(input).path("oslo.message").asText
		val parser = mapper.readTree(innerMessage).traverse
		parser.codec = mapper
		val event = parser.readValueAs(OpenStackEvent)
		Assert.assertNotNull(event)
	}
}
