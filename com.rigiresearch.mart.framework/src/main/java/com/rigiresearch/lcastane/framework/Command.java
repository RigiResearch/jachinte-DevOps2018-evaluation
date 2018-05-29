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

import com.rigiresearch.lcastane.framework.Operation.OperationType;
import java.io.Serializable;
import java.util.Arrays;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import lombok.experimental.Accessors;

/**
 * Represents an operation call.
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-07-11
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
@EqualsAndHashCode(callSuper = false)
@Getter
public final class Command implements Serializable {

    /**
     * Serial version UID.
     */
    private static final long serialVersionUID = 6107843158616889186L;

    /**
     * The operation type.
     */
    private final OperationType operationType;

    /**
     * The operation's required operands.
     */
    @Setter
    private Node[] operands;

    /**
     * Default constructor.
     * @param operationType The operation type
     * @param operands The operation's required operands
     */
    public Command(final OperationType operationType,
        final Node... operands) {
        this.operationType = operationType;
        this.operands = operands;
    }

    /*
     * (non-Javadoc)
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return String.format(
            "%s%s", 
            this.operationType.toString(),
            Arrays.toString(
                this.operands
            )
        );
    }
}
