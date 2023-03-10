# JUnit 5 ebuild Repository for Gentoo

This is an ebuild repository for prototyping, development, and testing of JUnit
5 support for Gentoo packages.  Right now, it contains:
- An experimental eclasses `java-pkg-junit-5.eclass`, which allows an ebuild to
  run a Java package's tests using JUnit 5.
- Some ebuilds that need JUnit 5 for running tests and therefore use
  `java-pkg-junit-5.eclass`.  These ebuilds also act as test cases for
  `java-pkg-junit-5.eclass`.

This ebuild repository should be considered to be in the **alpha** stage.
Packages may be removed, and incompatible eclass changes may occur at any time.

## Stages of Work

- [x] Add JUnit 5 to the Gentoo repository (<https://bugs.gentoo.org/839687>)
- [ ] Add JUnit 5 support to eclasses (<https://bugs.gentoo.org/839681>)
  - [ ] Determine keys for JUnit Jupiter in `JAVA_TESTING_FRAMEWORKS`
    - [ ] `junit-jupiter` or `junit-5`?
    - [ ] Support for `junit-vintage` as a substitute of `junit-4`?
      ([Issue][gh-1])
- [ ] Enable test for ebuilds that need JUnit 5 for running tests
  (<https://bugs.gentoo.org/829072>)

[gh-1]: https://github.com/Leo3418/junit-5-ebuild-repo/issues/1

## Using JUnit 5 from an ebuild That Uses `java-pkg-simple.eclass`

To use JUnit 5 from an ebuild that inherits `java-pkg-simple.eclass`, please
make the following modifications to the ebuild:

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

4. If the ebuild overrides `pkg_setup`, ensure that its `pkg_setup` calls
   `java-pkg-junit-5_pkg_setup`.  Note that `java-pkg-junit-5_pkg_setup` may
   replace any occurrence of `java-pkg-2_pkg_setup`.

   ```diff
   	pkg_setup() {
   -		java-pkg-2_pkg_setup
   +		java-pkg-junit-5_pkg_setup
   	}
   ```

5. If the ebuild makes any calls to `java-pkg-simple_src_test`, replace them
   with `java-pkg-junit-5_src_test`.

   ```diff
   -	java-pkg-simple_src_test
   +	java-pkg-junit-5_src_test
   ```
