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

import org.junit.Test
import com.fasterxml.jackson.databind.ObjectMapper
import org.junit.Assert
import com.fasterxml.jackson.databind.DeserializationFeature

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
		// This input is not complete
		val input = '''
		{
		  "oslo.message":{
		    "_context_domain":null,
		    "_context_roles":[
		      "admin"
		    ],
		    "_context_global_request_id":null,
		    "_context_quota_class":null,
		    "event_type":"keypair.delete.start",
		    "_context_request_id":"req-e233bdb6-8a1d-43d0-ba9b-75243ce45e30",
		    "timestamp":"2018-05-29 18:45:22.103293",
		    "_context_user":"f7b01aaf29cc446383f83f04396d6f3f",
		    "_unique_id":"1e89f22e972e4b58a2c42dd970631d35",
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
		    "_context_timestamp":"2018-05-29T18:45:22.093228",
		    "_context_user_domain":"default",
		    "_context_user_name":"devops-admin",
		    "publisher_id":"api.packstack-instance.openstacklocal",
		    "message_id":"3bc71c0b-34db-4c49-9e36-371d157514ed",
		    "_context_project":"a9434954adf940a3bdbdaab99e8751bb",
		    "_context_remote_address":"100.100.100.100"
		  }
		}'''
		val mapper = new ObjectMapper()
		mapper.enable(DeserializationFeature.ACCEPT_EMPTY_STRING_AS_NULL_OBJECT)
		val node = mapper.readTree(input).get("oslo.message")
		val parser = node.traverse
		parser.codec = mapper
		val event = parser.readValueAs(OpenStackEvent)
		Assert.assertNotNull(event)
	}
}
