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

import com.fasterxml.jackson.annotation.JsonIgnoreProperties
import com.fasterxml.jackson.annotation.JsonProperty
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtend.lib.annotations.ToString
import com.fasterxml.jackson.databind.node.ObjectNode

/**
 * An OpenStack Event.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
@Accessors
@ToString
@JsonIgnoreProperties(ignoreUnknown=true)
class OpenStackEvent {

	@JsonProperty("_context_project_domain")
	String projectDomain

	@JsonProperty("_context_user_domain")
	String userDomain

	@JsonProperty("_context_project_name")
	String projectName

	@JsonProperty("_context_project_id")
	String projectId

	@JsonProperty("_context_user_name")
	String user

	@JsonProperty("_context_user_id")
	String userId

	@JsonProperty("message_id")
	String messageId

	@JsonProperty("event_type")
	String eventType

	@JsonProperty("payload")
	ObjectNode payload

	@JsonProperty("timestamp")
	String timestamp

	@JsonProperty("priority")
	String priority

	/**
	 * Empty constructor.
	 */
	new() {}

	/**
	 * A descriptive message of this event.
	 */
	def String description() '''
		User «this.user» from project "«this.projectName»" updated this file on «this.timestamp»
		More information:
		- User domain is "«this.projectDomain»"
		- Project domain is "«this.projectDomain»"
		- The notification type is "«this.eventType»", with priority "«this.priority»"
		- The message id is "«this.messageId»"
	'''
}
