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
package com.rigiresearch.lcastane.framework.impl;

import java.util.List;
import java.util.Observable;
import java.util.Observer;

import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.rigiresearch.lcastane.framework.Artefact;
import com.rigiresearch.lcastane.framework.MART;
import com.rigiresearch.lcastane.framework.Rule;
import com.rigiresearch.lcastane.framework.Specification;
import com.rigiresearch.lcastane.framework.validation.ValidationException;

import lombok.Setter;

/**
 * An abstract implementation of {@link MART} whose artefact and specification
 * are kept in sync.
 * 
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-01
 * @version $Id$
 * @since 0.0.1
 */
public abstract class AbstractMART<S extends Specification, A extends Artefact>
	implements MART<S, A>, Observer {

	/**
	 * Serial version UID.
	 */
	private static final long serialVersionUID = 1217477437077661698L;

	/**
	 * The logger.
	 */
	private final Logger logger = LoggerFactory.getLogger(this.getClass());

	/**
	 * The specification associated with this MART.
	 */
	protected final ObservableSpecification<S> specification;

	/**
	 * The artefact associated with this MART.
	 */
	protected final ObservableArtefact<A> artefact;

	/**
	 * The procedure to apply when the artefact changes.
	 */
	@Setter
	protected Procedure0 updateSpecification;

	/**
	 * The procedure to apply when the specification changes.
	 */
	@Setter
	protected Procedure0 updateArtefact;

	/**
	 * The semantic validations associated with this MART.
	 */
	protected final List<Rule<A>> validations;

	/**
	 * Default constructor.
	 * @param specification The specification associated with this MART.
	 * @param artefact The artefact associated with this MART.
	 * @param validations The semantic validations associated with this MART.
	 */
	public AbstractMART(final S specification, final A artefact,
		final List<Rule<A>> validations) {
		this.specification = new ObservableSpecification<S>(specification);
		this.specification.addObserver(this);
		this.artefact = new ObservableArtefact<A>(artefact);
		this.artefact.addObserver(this);
		this.validations = validations;
	}

	/* (non-Javadoc)
	 * @see java.util.Observer#update(java.util.Observable, java.lang.Object)
	 */
	@Override
	@SuppressWarnings("unchecked")
	public void update(Observable observable, Object argument) {
		if (observable instanceof ObservableArtefact<?>) {
			ObservableArtefact<A> a = (ObservableArtefact<A>) observable;
			this.logger.info(
				String.format("The %s artefact was updated", a.name())
			);
			this.updateSpecification.apply();
		} else if (observable instanceof ObservableSpecification<?>) {
			ObservableSpecification<S> s = (ObservableSpecification<S>) observable;
			this.logger.info(
				String.format("The %s specification was updated", s.name())
			);
			this.updateArtefact.apply();
		} else {
			// Should not happen as this MART should only observe its artefact and
			// specification
			this.logger.info(
				String.format("The unknown observable %s was updated", observable)
			);
		}
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.MART#artefact()
	 */
	@Override
	public A artefact() {
		return this.artefact.origin();
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.MART#specification()
	 */
	@Override
	public S specification() {
		return this.specification.origin();
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.MART#validate()
	 */
	@Override
	public void validate() throws ValidationException {
		for (Rule<A> rule : this.validations) {
			if (!rule.apply(this.artefact.origin()))
				throw new ValidationException(this.artefact.origin(), rule);
		}
	}
}
