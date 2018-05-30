### DevOps Round-trip Software Engineering: On Traceability from Dev to Ops and Back

[![CircleCI](https://circleci.com/gh/RigiResearch/jachinte-DevOps2018-evaluation.svg?style=svg&circle-token=eba5bd91dcc431d76f0a62ce5f9518b22a8f0b62)](https://circleci.com/gh/RigiResearch/jachinte-DevOps2018-evaluation)

This repository contains a proof-of-concept implementation of Panorama, a framework for realizing round-trip engineering in DevOps. The various projects hosted here are described in the paper.

## Limitations

TBD

## Development Instructions

You don't need [Eclipse](http://www.eclipse.org) to get started, just [Maven](https://maven.apache.org). However, if you're planning on working with Eclipse, you should install the following plugins:

- [M2Eclipse](http://www.eclipse.org/m2e)
- [Xtext](http://www.eclipse.org/Xtext) 2.14.0
- [Xtend](http://www.eclipse.org/xtend) 2.14.0
- [Xcore](https://wiki.eclipse.org/Xcore) 1.5.0
- [Lombok](https://projectlombok.org). You only need Lombok to edit the operational framework (i.e., project com.rigiresearch.mart.framework)

You can find a description of each project in its corresponding POM file.

## Building from sources

This is a regular Maven project, there are no special profiles. Execute the following command to package the modules in a jar file:

```bash
mvn package
```

## Questions?

If you have any questions about this project or something doesn't work as expected, please [submit an issue here](https://github.com/RigiResearch/jachinte-DevOps2018-evaluation/issues).
