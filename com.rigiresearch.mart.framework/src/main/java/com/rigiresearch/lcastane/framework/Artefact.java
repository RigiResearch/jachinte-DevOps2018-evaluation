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
package com.rigiresearch.lcastane.framework;

import com.rigiresearch.lcastane.framework.validation.ValidationException;
import java.io.Serializable;

/**
 * Defines the basic behavior for a runtime artefact.
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-06-13
 * @version $Id$
 * @since 0.0.1
 */
public interface Artefact extends Serializable {

    /**
     * A name describing this artefact.
     * @return A name
     */
    String name();

    /**
     * Applies the commanded (supported) operation to the given operands.
     * @param command The command to apply
     * @throws ValidationException If the operation cannot be performed
     */
    void apply(Command command) throws ValidationException;

    /**
     * Sets the MART instance associated with this artefact.
     * This is added for facilitating traversing from specification to artefact
     * and vice versa.
     */
    void setMart(MART<?, ?> parent);
}
