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

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.rigiresearch.lcastane.framework.Specification;

import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.ToString;
import lombok.experimental.Accessors;

/**
 * A file-based specification.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-02
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
@RequiredArgsConstructor
@ToString
public class FileSpecification implements Specification {

	/**
	 * Serial version UID.
	 */
	private static final long serialVersionUID = 138421129024385117L;

	/**
	 * The logger.
	 */
	private final Logger logger = LoggerFactory.getLogger(FileSpecification.class);

	/**
	 * The physical file represented by this specification.
	 */
	@Getter
	private final File file;

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification#name()
	 */
	@Override
	public String name() {
		return FileSpecification.class.getSimpleName();
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification#contents()
	 */
	@Override
	public String contents() {
		try {
			return new String(
				Files.readAllBytes(
					Paths.get(this.file.toURI())
				)
			);
		} catch (IOException e) {
			e.printStackTrace();
		}
		return new String();
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification
	 *  #update(java.lang.String)
	 */
	@Override
	public void update(String contents) {
		this.update(contents, new HashMap<String, Object>());
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification
	 *  #update(java.lang.String, java.util.Map)
	 */
	@Override
	public void update(String contents, Map<String, Object> data) {
		try {
			Files.write(Paths.get(this.file.toURI()), contents.getBytes());
			this.logger.info(
				String.format(
					"The specification file (%s) was updated",
					this.file
				)
			);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
}
