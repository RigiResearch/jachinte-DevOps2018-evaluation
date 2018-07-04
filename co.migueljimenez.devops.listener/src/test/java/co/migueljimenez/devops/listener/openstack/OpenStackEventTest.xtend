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
	def novaNotification1() {
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
	def novaNotification2() {
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

		@Test
	def neutronNotification1() {
		val input = '''
		{
			"_context_domain": null,
			"_context_roles": [
				"_member_"
			],
			"_context_global_request_id": null,
			"_context_tenant_name": "devops-project",
			"event_type": "security_group.delete.start",
			"_context_request_id": "req-3e3a0fb3-44cb-4ba9-9e78-8f36fd993583",
			"timestamp": "2018-07-04 18:15:29.229265",
			"_context_user": "7908dbde98524927a6f18466b2572810",
			"_unique_id": "804d2972301b4656b47c9f8da4717153",
			"_context_resource_uuid": null,
			"_context_tenant_id": "9dbc97d98e4d4e59a4aac759b5749230",
			"_context_is_admin_project": true,
			"_context_user_id": "7908dbde98524927a6f18466b2572810",
			"payload": {
				"security_group_id": "bb78c754-085b-49f0-850a-bea14a14e6e6"
			},
			"_context_project_name": "devops-project",
			"_context_user_identity": "7908dbde98524927a6f18466b2572810 9dbc97d98e4d4e59a4aac759b5749230 - default default",
			"_context_auth_token": "gAAAAABbPQ1qCC_zCxQyin0hr8oRqNbUV0gNtg1vQEnO4Vh_FIui-7fAX-iwU33aCaM8GaHs7Qzh4W5APpJ-zIymIAUZ_YzRwiXl_q43XJNsewQCZJh1xXfT3ND7yPUCrDv1qhEQgmnE0f97SRrgVQn1ZIHONTfTSh1rUzHXhVzPFbmhvPAgj29p05vL7Xrvk6E_bkrQD_VX",
			"_context_show_deleted": false,
			"_context_tenant": "9dbc97d98e4d4e59a4aac759b5749230",
			"priority": "INFO",
			"_context_read_only": false,
			"_context_is_admin": false,
			"_context_project_id": "9dbc97d98e4d4e59a4aac759b5749230",
			"_context_project_domain": "default",
			"_context_timestamp": "2018-07-04 18:15:29.211595",
			"_context_user_domain": "default",
			"_context_user_name": "miguel",
			"publisher_id": "network.openstack.westcloud",
			"message_id": "47e66d37-d7c8-455b-af80-11d9bd2b73f9",
			"_context_project": "9dbc97d98e4d4e59a4aac759b5749230"
		}'''
		val mapper = new ObjectMapper()
		val event = mapper.readValue(input, OpenStackEvent)
		Assert.assertNotNull(event)
	}

		@Test
	def neutronNotification2() {
		val input = '''
		{
			"_context_domain": null,
			"_context_roles": [
				"_member_"
			],
			"_context_global_request_id": null,
			"_context_tenant_name": "devops-project",
			"event_type": "security_group_rule.create.start",
			"_context_request_id": "req-9091cf8e-3c0b-42c3-9b0b-e97ff09c1f92",
			"timestamp": "2018-07-04 18:17:11.209381",
			"_context_user": "7908dbde98524927a6f18466b2572810",
			"_unique_id": "7a28fbafa0e54399a35672c2b33ea24c",
			"_context_resource_uuid": null,
			"_context_tenant_id": "9dbc97d98e4d4e59a4aac759b5749230",
			"_context_is_admin_project": true,
			"_context_user_id": "7908dbde98524927a6f18466b2572810",
			"payload": {
				"security_group_rule": {
					"remote_group_id": null,
					"direction": "ingress",
					"protocol": "tcp",
					"ethertype": "IPv4",
					"port_range_max": 1099,
					"security_group_id": "9767b58a-8781-4e3b-bbc7-9b5d332512fb",
					"port_range_min": 1099,
					"remote_ip_prefix": "0.0.0.0/0"
				}
			},
			"_context_project_name": "devops-project",
			"_context_user_identity": "7908dbde98524927a6f18466b2572810 9dbc97d98e4d4e59a4aac759b5749230 - default default",
			"_context_auth_token": "gAAAAABbPQ1qCC_zCxQyin0hr8oRqNbUV0gNtg1vQEnO4Vh_FIui-7fAX-iwU33aCaM8GaHs7Qzh4W5APpJ-zIymIAUZ_YzRwiXl_q43XJNsewQCZJh1xXfT3ND7yPUCrDv1qhEQgmnE0f97SRrgVQn1ZIHONTfTSh1rUzHXhVzPFbmhvPAgj29p05vL7Xrvk6E_bkrQD_VX",
			"_context_show_deleted": false,
			"_context_tenant": "9dbc97d98e4d4e59a4aac759b5749230",
			"priority": "INFO",
			"_context_read_only": false,
			"_context_is_admin": false,
			"_context_project_id": "9dbc97d98e4d4e59a4aac759b5749230",
			"_context_project_domain": "default",
			"_context_timestamp": "2018-07-04 18:17:11.202710",
			"_context_user_domain": "default",
			"_context_user_name": "miguel",
			"publisher_id": "network.openstack.westcloud",
			"message_id": "cf3ca9a9-2272-45bd-af07-470ddf6acab3",
			"_context_project": "9dbc97d98e4d4e59a4aac759b5749230"
		}'''
		val mapper = new ObjectMapper()
		val event = mapper.readValue(input, OpenStackEvent)
		Assert.assertNotNull(event)
	}

	@Test
	def glanceNotification() {
		val input = '''
		{
			"oslo.message": "{\"priority\": \"INFO\", \"_unique_id\": \"1911f2aafeb24a66844693e767cd547d\", \"event_type\": \"image.create\", \"timestamp\": \"2018-07-04 18:45:03.409609\", \"publisher_id\": \"image.localhost\", \"payload\": {\"status\": \"queued\", \"deleted_at\": null, \"name\": \"demo\", \"tags\": [], \"deleted\": false, \"checksum\": null, \"created_at\": \"2018-07-04T18:45:03Z\", \"disk_format\": \"qcow2\", \"updated_at\": \"2018-07-04T18:45:03Z\", \"visibility\": \"private\", \"properties\": {\"architecture\": \"bare\"}, \"owner\": \"9dbc97d98e4d4e59a4aac759b5749230\", \"protected\": false, \"min_ram\": 0, \"container_format\": \"bare\", \"min_disk\": 0, \"is_public\": false, \"virtual_size\": null, \"id\": \"2ec3c6e1-ad2a-4d44-b9d0-f513718ba395\", \"size\": null}, \"message_id\": \"340b71dd-e7d9-40bb-957d-6222f4695e08\"}",
			"oslo.version": "2.0"
		}'''
		val mapper = new ObjectMapper()
		val innerMessage = mapper.readTree(input).path("oslo.message").asText
		val parser = mapper.readTree(innerMessage).traverse
		parser.codec = mapper
		val event = parser.readValueAs(OpenStackEvent)
		Assert.assertNotNull(event)
	}
}
