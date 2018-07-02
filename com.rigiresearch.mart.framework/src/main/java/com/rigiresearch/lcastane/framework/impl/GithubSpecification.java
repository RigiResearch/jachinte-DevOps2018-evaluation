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

import java.io.IOException;
import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.configuration2.Configuration;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.ex.ConfigurationException;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.api.errors.NoFilepatternException;
import org.eclipse.jgit.merge.MergeStrategy;
import org.eclipse.jgit.transport.CredentialsProvider;
import org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.rigiresearch.lcastane.framework.MART;
import com.rigiresearch.lcastane.framework.Specification;

import lombok.Getter;
import lombok.experimental.Accessors;

/**
 * A simple decorator to commit and push changes to a Github repository.
 * @author Miguel Jimenez (miguel@uvic.ca)
 * @date 2018-06-02
 * @version $Id$
 * @since 0.0.1
 */
@Accessors(fluent = true)
public class GithubSpecification implements Specification {

	/**
	 * Serial version UID.
	 */
	private static final long serialVersionUID = -1195173764888520896L;

	/**
	 * The logger.
	 */
	private final Logger logger = LoggerFactory.getLogger(GithubSpecification.class);

	/**
	 * The decorated specification.
	 */
	@Getter
	private final FileSpecification origin;

	/**
	 * The Github credentials provider.
	 */
	private final CredentialsProvider credentialsProvider;

	/**
	 * Whether CI build should be skipped.
	 */
	private final boolean skipCi;

	/**
	 * Default constructor.
	 * 
	 * FIXME Find a way to setup Github per MART. As of now, PrIMoR will assume
	 * that all MART use the same credentials specified in github.properties
	 * 
	 * @param origin The decorated specification
	 * @param skipCi Whether to skip CI
	 */
	public GithubSpecification(final FileSpecification origin,
		final boolean skipCi) {
		this.origin = origin;
		this.skipCi = skipCi;
		Configuration config = null;
		try {
			config = new Configurations().properties("github.properties");
		} catch (ConfigurationException e) {
			throw new RuntimeException(e.getMessage(), e.getCause());
		}
		this.credentialsProvider = new UsernamePasswordCredentialsProvider(
			config.getString("authentication-token"),
			new String()
		);
	}

	/**
	 * Secondary constructor.
	 * 
	 * @param origin The decorated specification
	 */
	public GithubSpecification(final FileSpecification origin) {
		this(origin, false);
	}

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
		this.update(contents, new HashMap<String, Object>());
	}

	/* (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification
	 *  #update(java.lang.String, java.util.Map)
	 */
	@Override
	public void update(String contents, Map<String, Object> data) {
		try(Git git = Git.open(this.origin.file().getParentFile())) {
			git.pull()
				.setStrategy(MergeStrategy.THEIRS)
				.setCredentialsProvider(credentialsProvider)
				.call();
			this.origin.update(contents, data);
			if (git.status().call().isClean())
				return;
			this.addAndCommit(git, data);
			git.push()
				.setCredentialsProvider(credentialsProvider)
				.call();
			this.logger.info("The changes were pushed to Github");
		} catch (IOException | GitAPIException e) {
			e.printStackTrace();
		}		
	}

	/**
	 * Adds updated, removed and new files to the index and then commits the
	 * changes.
	 * @param git The git repository
	 * @param data Additional information to commit
	 * @throws NoFilepatternException See {@link Git#add()}
	 * @throws GitAPIException See {@link Git}
	 */
	private void addAndCommit(final Git git, final Map<String, Object> data)
		throws NoFilepatternException, GitAPIException {
		for (String file : git.status().call().getModified()) {
			git.add().addFilepattern(file).call();
			this.commit(git, data, String.format("Update %s", file));
		}
		for (String file : git.status().call().getMissing()) {
			git.add().addFilepattern(file).call();
			this.commit(git, data, String.format("Remove %s", file));
		}
		for (String file : git.status().call().getUntracked()) {
			git.add().addFilepattern(file).call();
			this.commit(git, data, String.format("Add %s", file));
		}
	}

	/**
	 * Commits already added changes.
	 * @param git The git repository
	 * @param data Additional information to commit
	 * @param message The commit message
	 * @throws GitAPIException See {@link Git}
	 */
	private void commit(final Git git, final Map<String, Object> data,
		String message) throws GitAPIException {
		String host = "Unknown";
		try {
			host = InetAddress.getLocalHost().getHostName();
		} catch (UnknownHostException e) {}
		git.commit()
			.setAuthor((String) data.get("author"), (String) data.get("email"))
			.setCommitter("PrIMOr", String.format("PrIMoR@%s", host))
			.setMessage(
				String.format(
					"%s%s",
					message,
					this.skipCi ? " [skip ci]" : ""
				)
			)
			.call();
	}

	/*
	 * (non-Javadoc)
	 * @see com.rigiresearch.lcastane.framework.Specification
	 *  #setMart(com.rigiresearch.lcastane.framework.MART)
	 */
	@Override
	public void setMart(MART<?, ?> parent) {
		this.origin.setMart(parent);
	}
}
