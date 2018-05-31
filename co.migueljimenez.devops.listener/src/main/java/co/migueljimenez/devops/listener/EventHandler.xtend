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
package co.migueljimenez.devops.listener

import org.slf4j.LoggerFactory

/**
 * A simple event handler.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-05-31
 * @version $Id$
 * @since 0.0.1
 */
interface EventHandler {

	/**
	 * Handles the given event.
	 */
	def void handle(Object event)

	/**
	 * The type of events handled by this handler.
	 */
	def Class<?> handledType()

	/**
	 * A null implementation of this interface that logs all the handled events.
	 * @author Miguel Jimenez (miguel@uvic.ca)
	 * @date 2018-05-31
	 * @version $Id$
	 * @since 0.0.1
	 */
	static class NullHandler implements EventHandler {

		/**
	     * The logger.
	     */
		val logger = LoggerFactory.getLogger(NullHandler)

		override handle(Object event) {
			this.logger.info('''«event»''')
		}

		override handledType() {
			Object
		}
	}
}
