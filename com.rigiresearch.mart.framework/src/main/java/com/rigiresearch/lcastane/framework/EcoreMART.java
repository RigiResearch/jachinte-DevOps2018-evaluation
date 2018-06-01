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
package com.rigiresearch.lcastane.framework;

import java.io.Serializable;

import com.rigiresearch.lcastane.framework.validation.ValidationException;

import lombok.RequiredArgsConstructor;

/**
 * A MART whose artefact is an Ecore model. This MART is only used as a
 * temporary model sent over the network. Once it is received by the PrIMoR
 * manager, a {@link MART} is instantiated and registered.
 * 
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-01
 * @version $Id$
 * @since 0.0.1
 */
public interface EcoreMART<S extends Specification>
	extends MART<S, EcoreMART.NullArtefact> {

	/**
	 * The Ecore-based artefact serialized as XMI.
	 * @return A XML string
	 */
	public String serializedArtefact();

	/**
	 * Class name of the Ecore package. <b>Notice</b> that the class name should
	 * refer to the package implementation instead of the interface.
	 * @return A fully qualified class name
	 */
	public String packageImplClassName();

	/**
	 * Class name of the Ecore model (the root class).
	 * @return A fully qualified class name
	 */
	public String modelClassName();

	/**
	 * Class name of the {@link Artefact} that decorates the Ecore-based model.
	 * @return A fully qualified class name
	 */
	public String decoratorClassName();

	/**
	 * Class name of the {@link MART}.
	 * @return A fully qualified class name
	 */
	public String martClassName();

	/**
	 * A default implementation of the Ecore-based MART.
	 * @author Miguel Jimenez (miguel@uvic.ca)
	 * @date 2018-06-01
	 * @version $Id$
	 * @since 0.0.1
	 */
	@RequiredArgsConstructor
	public static class Default implements EcoreMART<Specification> {

		/**
		 * Serial version UID.
		 */
		private static final long serialVersionUID = -357931850145435897L;

		/**
		 * A null artefact that does nothing.
		 */
		private final NullArtefact artefact = new NullArtefact();

		/**
		 * The {@link Serializable} specification.
		 */
		private final Specification specification;

		/**
		 * The artefact serialized as XMI.
		 */
		private final String serializedArtefact;

		/**
		 * Class name of the Ecore package. <b>Notice</b> that the class name should
		 * refer to the package implementation instead of the interface.
		 */
		private final String packageImplClassName;

		/**
		 * Class name of the Ecore model (the root class).
		 */
		private final String modelClassName;

		/**
		 * Class name of the {@link Artefact} that decorates the Ecore-based model.
		 */
		private final String decoratorClassName;

		/**
		 * Class name of the {@link MART}.
		 */
		private final String martClassName;

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.MART#artefact()
		 */
		@Override
		public NullArtefact artefact() {
			return this.artefact;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.MART#specification()
		 */
		@Override
		public Specification specification() {
			return this.specification;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.MART#validate()
		 */
		@Override
		public void validate() throws ValidationException {
			// Do nothing
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.EcoreMART#serializedArtefact()
		 */
		@Override
		public String serializedArtefact() {
			return this.serializedArtefact;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.EcoreMART#packageClassName()
		 */
		@Override
		public String packageImplClassName() {
			return this.packageImplClassName;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.EcoreMART#modelClassName()
		 */
		@Override
		public String modelClassName() {
			return this.modelClassName;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.EcoreMART#decoratorClassName()
		 */
		@Override
		public String decoratorClassName() {
			return this.decoratorClassName;
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.EcoreMART#martClassName()
		 */
		@Override
		public String martClassName() {
			return this.martClassName;
		}
	}

	/**
	 * A null implementation of {@link Artefact}. It does nothing.
	 * @author Miguel Jimenez (miguel@uvic.ca)
	 * @date 2018-06-01
	 * @version $Id$
	 * @since 0.0.1
	 */
	public static class NullArtefact implements Artefact {

		/**
		 * Serial version UID.
		 */
		private static final long serialVersionUID = 7930442776002900809L;

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.Artefact#name()
		 */
		@Override
		public String name() {
			return NullArtefact.class.getSimpleName();
		}

		/* (non-Javadoc)
		 * @see com.rigiresearch.lcastane.framework.Artefact
		 *  #apply(com.rigiresearch.lcastane.framework.Command)
		 */
		@Override
		public void apply(Command command) throws ValidationException {
			// Do nothing
		}
	}
}
