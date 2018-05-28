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

import co.migueljimenez.devops.listener.EventListener
import com.rabbitmq.client.AMQP
import com.rabbitmq.client.Channel
import com.rabbitmq.client.Connection
import com.rabbitmq.client.ConnectionFactory
import com.rabbitmq.client.DefaultConsumer
import com.rabbitmq.client.Envelope
import java.io.File
import java.io.IOException
import org.apache.commons.configuration.Configuration
import org.apache.commons.configuration.DefaultConfigurationBuilder
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1

/**
 * Listens for OpenStack Events.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-14
 * @version $Id$
 * @since 0.0.1
 */
class OpenStackListener implements EventListener {

	/**
	 * RabbitMQ configuration.
	 */
	val Configuration configuration

	/**
	 * The RabbitMQ connection.
	 */
	val Connection connection

	/**
	 * The communication channel with the RabbitMQ server.
	 */
	val Channel channel

	/**
	 * The exchange from which this listener consumes events.
	 */
	val String exchange

	/**
	 * The routing key to use.
	 */
	val String routingKey

	/**
	 * Default constructor.
	 */
	new(String exchange, String routingKey) {
		this.configuration = new DefaultConfigurationBuilder(
            new File("properties.xml")
        ).configuration
		this.connection = this.factory().newConnection
		this.channel = connection.createChannel
		this.exchange = exchange
		this.routingKey = routingKey
	}

	/**
	 * Instantiates and configures the RabbitMQ connection factory.
	 */
	def protected factory() {
		val factory = new ConnectionFactory()
		factory.setUsername(this.configuration.getString("username"))
		factory.setPassword(this.configuration.getString("password"))
		factory.setVirtualHost(this.configuration.getString("vhost"))
		factory.setHost(this.configuration.getString("host"))
		factory.setPort(this.configuration.getInt("port"))
		return factory
	}

	override listen(Procedure1<Object> handler) {
		val queue = this.channel.queueDeclare().queue
		this.channel.queueBind(queue, this.exchange, this.routingKey)
		this.channel.basicConsume(
			queue,
			false,
			"devops-consumer",
			new DefaultConsumer(this.channel) {
				override handleDelivery(String consumerTag, Envelope envelope,
					AMQP.BasicProperties properties, byte[] body) throws IOException {
					handler.apply(new OpenStackEvent(new String(body)))
					channel.basicAck(envelope.getDeliveryTag(), false)
				}
			}
		)
	}

	override stop() {
		this.connection.close
		this.channel.close
	}
}
