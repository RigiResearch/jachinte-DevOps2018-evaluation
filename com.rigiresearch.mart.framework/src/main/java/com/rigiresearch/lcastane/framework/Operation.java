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
 * Represents an operation supported by the framework.
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-06-14
 * @version $Id$
 * @since 0.0.1
 */
public interface Operation<T extends Artefact> extends Serializable {

    /**
     * Represents the type of operations supported by the framework.
     * @author Lorena Castaneda
     * @date 2017-06-14
     * @version $Id$
     * @since 0.0.1
     */
    public interface OperationType extends Serializable {

        /**
         * This method is intended to be used along with the name method in
         * Java enumerations.
         * @return This operation's unique name (in the context of its
         *  corresponding artefact)
         */
        String name();
    }

    /**
     * Applies this operation on the given {@link Node}s.
     * @param artefcat The artefact in whose context this operation is applied
     * @param operands This operation's operands
     * @throws ValidationException If the operation cannot be performed on
     *  the given operands
     */
    void apply(T artefact, Node... operands) throws ValidationException;

    /**
     * Returns this operation's type.
     * @return An operation type
     */
    OperationType type();
}
