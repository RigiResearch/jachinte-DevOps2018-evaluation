/**
 * Copyright 2017 University of Victoria
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
package com.rigiresearch.lcastane.framework.validation;

import com.rigiresearch.lcastane.framework.Artefact;
import com.rigiresearch.lcastane.framework.Operation;
import com.rigiresearch.lcastane.framework.Rule;

/**
 * Represents an exception for when a {@link Rule} fails.
 * @author Lorena Castaneda
 * @date 2017-06-13
 * @version $Id$
 * @since 0.0.1
 */
public final class ValidationException extends Exception {

    /**
     * Serial version UID.
     */
    private static final long serialVersionUID = 3478423996140467989L;

    /**
     * Default constructor.
     * @param artefact The artefact that threw this exception
     * @param rule The failing validation rule
     */
    public ValidationException(final Artefact artefact, Operation<?> operation,
        final Rule<?> rule) {
        super(
            String.format(
                "Validation rule '%s' failed to vaidate artefact '%s' while"
                + " performing operation '%s'. Error message is: '%s'"
                + ".",
                rule.name(),
                artefact.name(),
                operation.type().toString(),
                rule.errorMessage()
            )
        );
    }

    /**
     * Secondary constructor.
     * @param artefact The artefact that threw this exception
     * @param validation The failing validation rule
     */
    public ValidationException(final Artefact artefact,
    	final Rule<?> rule) {
    	super(
    		String.format(
    			"Validation rule '%s' failed to validate artefact '%s'.",
    			rule.name(),
    			artefact.name()
    		)
    	);
    }
}
