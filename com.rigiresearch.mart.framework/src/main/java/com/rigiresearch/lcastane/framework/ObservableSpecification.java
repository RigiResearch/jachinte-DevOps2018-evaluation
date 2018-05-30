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

import java.util.Observable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.experimental.Accessors;

/**
 * Adds observability to a {@link Notation}.
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2017-06-13
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
@EqualsAndHashCode(callSuper = false)
@RequiredArgsConstructor
public final class ObservableSpecification<T extends Specification>
    extends Observable implements Specification {

    /**
     * Serial version UID.
     */
    private static final long serialVersionUID = -3665582160942806595L;

    /**
     * The decorated notation.
     */
    @Getter
    private final T origin;

    /* (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Specification#name()
     */
    @Override
    public String name() {
        return this.origin.name();
    }

    /* (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Specification#contents()
     */
    @Override
    public String contents() {
        return this.origin.contents();
    }

    /* (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Specification
     *  #update(java.lang.String)
     */
    @Override
    public void update(String contents) {
        this.origin.update(contents);
        this.notifyObservers(contents);
    }
}
