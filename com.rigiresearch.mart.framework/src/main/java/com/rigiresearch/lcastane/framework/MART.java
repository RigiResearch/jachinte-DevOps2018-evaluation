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

import java.io.Serializable;

import com.rigiresearch.lcastane.framework.validation.ValidationException;

/**
 * Describes the basic behavior of a model.
 * @author Miguel Jimenez (miguel@uvic.ca) - Add method {@link #validate()}
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-06-13
 * @version $Id$
 * @since 0.0.1
 */
public interface MART<S extends Specification, A extends Artefact>
    extends Serializable {

    /**
     * Returns an instance of {@link Artefact} that is in sync with the
     * associated {@link Notation}.
     * @return an instance of {@link Artefact}
     */
    A artefact();

    /**
     * Returns an instance of {@link Notation} that is in sync with the
     * associated {@link Artefact}.
     * @return an instance of {@code Notation}
     */
    S specification();

    /**
     * Runs the semantic validations associated with this MART.
     * @throws ValidationException If any of the validations fail
     */
    void validate() throws ValidationException;
}
