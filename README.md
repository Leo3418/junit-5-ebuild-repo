# JUnit 5 ebuild Repository for Gentoo

This is an ebuild repository containing experimental packages and eclasses that
support running tests with JUnit 5 from Gentoo package managers.  Its main
purpose is for early prototyping, development, and testing of JUnit 5 support
for Gentoo.

This ebuild repository should be considered to be in the **alpha** stage.
Packages may be removed, and incompatible eclass changes may occur at any time.

## Tasks

- [x] Create external dependencies of most JUnit 5 modules
  - [x] `org.apiguardian:apiguardian-api`
  - [x] `org.opentest4j:opentest4j`
- [x] Create a minimal set of packages to support execution of a common JUnit
  Jupiter test suite
  - [x] `junit-platform-commons`
  - [x] `junit-platform-engine`
  - [x] `junit-platform-launcher`
  - [x] `junit-platform-reporting`
  - [x] `junit-platform-console`
  - [x] `junit-jupiter-api`
  - [x] `junit-jupiter-engine`
- [x] Create an experimental eclass that can launch tests on the JUnit Platform
- [x] Create packages to support [parameterized
  tests][junit-5-parameterized-tests]
  - [x] `com.univocity:univocity-parsers:2.9.1`
  - [x] `junit-jupiter-params`
- [ ] Use packages and eclasses in this repository to run test suites of
  packages that depend on JUnit Jupiter
  - [ ] <https://bugs.gentoo.org/829072>
    - [x] `>=dev-java/jnr-ffi-2.2.8`
    - [ ] `>=dev-java/log4j-api` and `>=dev-java/log4j-api-java9`
  - [ ] `>=dev-java/guava-30.1.1`
- [ ] Enable `src_test` for all ebuilds for JUnit 5 support in this repository
  - [ ] `dev-java/univocity-parsers`
  - [ ] `dev-java/junit-*`
- [ ] Determine keys for JUnit Jupiter in `JAVA_TESTING_FRAMEWORKS`
  - [ ] `junit-jupiter` or `junit-5`?
  - [ ] Support for `junit-vintage` as a substitute of `junit-4`?
    ([Issue][gh-1])
    - [x] `junit-vintage-engine`
    - [ ] `junit-jupiter-migrationsupport`

### Stretch Goals

- [ ] Build tools for updating JUnit 5 packages for a new upstream release
  - [ ] A program/script that bumps all `dev-java/junit-*` packages' version
  - [ ] Support for automatically modifying `MAVEN_ID` and checking its
    correctness
  - [ ] Test updating JUnit 5 packages to 5.8.2
    - [ ] Test building JUnit 5.8.2 with Java 8, as the upstream starts to
      require JDK 17 for building since 5.8

[junit-5-parameterized-tests]: https://junit.org/junit5/docs/current/user-guide/#writing-tests-parameterized-tests
[gh-1]: https://github.com/Leo3418/junit-5-ebuild-repo/issues/1

## Running JUnit Jupiter Tests from ebuilds Inheriting `java-pkg-simple.eclass`

A small eclass `java-pkg-junit-5.eclass` has been created to facilitate testing
JUnit 5 support for Gentoo.  Please note that as mentioned above, this eclass
is to be considered in the alpha stage and should not be used in production.
However, it is ready for ebuild developers to experiment with running JUnit
Jupiter tests of a package from its ebuild.

To enable execution of JUnit Jupiter tests, please make the following
modifications to the ebuild:

1. If the ebuild is not using EAPI 8, make sure it does so.

   ```diff
   -EAPI=7
   +EAPI=8
   ```

2. If the ebuild does not include the `test` USE flag in the `JAVA_PKG_IUSE`
   variable, make sure it does so.  In addition, ensure the
   `JAVA_TESTING_FRAMEWORKS` variable's value is *not empty* (it *needs not*
   contain any special value like `junit-jupiter` or `junit-5`).

   ```diff
   -JAVA_PKG_IUSE="doc source"
   +JAVA_PKG_IUSE="doc source test"
   +JAVA_TESTING_FRAMEWORKS="foo"

    inherit java-pkg-2 java-pkg-simple
   ```

3. Inherit the eclass without removing inheritance of any other eclass.

   ```diff
   -inherit java-pkg-2 java-pkg-simple
   +inherit java-pkg-2 java-pkg-simple java-pkg-junit-5
   ```

4. If there is any call to `java-pkg-simple_src_test`, replace them with
   `java-pkg-junit-5_src_test`.

   ```diff
   -	java-pkg-simple_src_test
   +	java-pkg-junit-5_src_test
   ```

Besides packages supporting JUnit 5, this ebuild repository may also have some
unrelated ebuilds that run tests on the JUnit Platform using
`java-pkg-junit-5.eclass`.  Please feel free to consult them or add more
ebuilds with JUnit Jupiter tests enabled.
