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
package com.rigiresearch.lcastane.framework.impl;

import com.rigiresearch.lcastane.framework.Artefact;
import com.rigiresearch.lcastane.framework.Command;
import com.rigiresearch.lcastane.framework.MART;
import com.rigiresearch.lcastane.framework.validation.ValidationException;
import java.util.Observable;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.experimental.Accessors;

/**
 * Adds observability to an {@link Artefact}.
 * @author Lorena Castaneda - Initial contribution and API
 * @date 2018-02-25
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
@EqualsAndHashCode(callSuper = false)
@RequiredArgsConstructor
public final class ObservableArtefact<T extends Artefact>
    extends Observable implements Artefact {

    /**
     * Serial version UID.
     */
    private static final long serialVersionUID = -601037744088572225L;

    /**
     * The decorated artefact.
     */
    @Getter
    private final T origin;

    /* (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Artefact#name()
     */
    @Override
    public String name() {
        return this.origin.name();
    }

    /* (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Artefact
     *  #apply(com.rigiresearch.lcastane.framework.Command)
     */
    @Override
    public void apply(Command command) throws ValidationException {
        this.origin.apply(command);
        this.setChanged();
        this.notifyObservers(command.context());
    }

    /*
     * (non-Javadoc)
     * @see com.rigiresearch.lcastane.framework.Artefact
     *  #setMart(com.rigiresearch.lcastane.framework.MART)
     */
	@Override
	public void setMart(MART<?, ?> parent) {
		this.origin.setMart(parent);
	}
}
