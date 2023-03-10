# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: java-pkg-junit-5.eclass
# @MAINTAINER:
# Yuan Liao <liaoyuan@gmail.com>
# @AUTHOR:
# Yuan Liao <liaoyuan@gmail.com>
# @SUPPORTED_EAPIS: 8
# @PROVIDES: java-pkg-simple
# @BLURB: Experimental eclass to add support for testing on the JUnit Platform
# @DESCRIPTION:
# This eclass runs tests on the JUnit Platform (which is a JUnit 5 sub-project)
# during the src_test phase.  It is an experimental eclass whose code should
# eventually be merged into java-utils-2.eclass and/or java-pkg-simple.eclass
# when it is mature.

if [[ ! ${_JAVA_PKG_JUNIT_5_ECLASS} ]]; then

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI} unsupported." ;;
esac

inherit java-pkg-simple

# @ECLASS_VARIABLE: JAVA_JUNIT_5_EXTRA_ARGS
# @DEFAULT_UNSET
# @DESCRIPTION:
# An array of extra arguments to be passed into the JUnit Platform's
# ConsoleLauncher class during the src_test phase.

# TODO: JUnit Vintage is unconditionally enabled for now.  To minimize the set
# of test dependencies pulled, use of JUnit Jupiter and JUnit Vintage should be
# controlled by JAVA_TESTING_FRAMEWORKS, and they should be included in DEPEND
# only if they are added to the variable.  The identifiers for JUnit Jupiter
# and JUnit Vintage in JAVA_TESTING_FRAMEWORKS are to be determined.
if has test ${JAVA_PKG_IUSE}; then
	DEPEND="test? (
		dev-java/junit:5
	)"
fi

# @FUNCTION: ejunit5
# @USAGE: [-cp <classpath>|-classpath <classpath>] <classes>
# @DESCRIPTION:
# Using the specified classpath, launches a JVM instance to run the specified
# test classes by invoking the JUnit Platform's ConsoleLauncher.
ejunit5() {
	debug-print-function ${FUNCNAME} $*

	local pkgs
	if [[ -f ${JAVA_PKG_DEPEND_FILE} ]]; then
		for atom in $(cat ${JAVA_PKG_DEPEND_FILE} | tr : ' '); do
			pkgs=${pkgs},$(echo ${atom} | sed -re "s/^.*@//")
		done
	fi

	local junit="junit-5"
	local cp=$(java-pkg_getjars --with-dependencies ${junit}${pkgs})
	if [[ ${1} = -cp || ${1} = -classpath ]]; then
		cp="${2}:${cp}"
		shift 2
	else
		cp=".:${cp}"
	fi

	local runner=org.junit.platform.console.ConsoleLauncher
	local runner_args=(
		# Remove ANSI escape code for coloring to make log files more readable
		--disable-ansi-colors
		${JAVA_PKG_DEBUG:+--details=verbose}
		"${JAVA_JUNIT_5_EXTRA_ARGS[@]}"
		# Each test class needs to be passed in with a '-c' option
		$(printf -- '-c=%q ' "${@}")
	)
	debug-print "Calling: java -cp \"${cp}\" -Djava.io.tmpdir=\"${T}\" -Djava.awt.headless=true ${JAVA_TEST_EXTRA_ARGS[@]} ${runner} ${runner_args[@]}"
	set -- java -cp "${cp}" -Djava.io.tmpdir="${T}/" -Djava.awt.headless=true \
		${JAVA_TEST_EXTRA_ARGS[@]} ${runner} "${runner_args[@]}"
	echo "${@}" >&2
	"${@}" || die "Tests on the JUnit Platform failed"
}

# @FUNCTION: java-pkg-junit-5_src_test
# @DESCRIPTION:
# Runs tests on the JUnit Platform.
java-pkg-junit-5_src_test() {
	if ! has test ${JAVA_PKG_IUSE}; then
		return
	elif ! use test; then
		return
	fi

	local junit_5_classpath="junit-5"
	JAVA_TEST_GENTOO_CLASSPATH+=" ${junit_5_classpath}"
	java-pkg-simple_src_test
	elog "java-pkg-simple.eclass might have printed a \"No suitable function found\""
	elog "message.  This is OK, as java-pkg-junit-5.eclass will handle JUnit 5..."

	local classes="target/test-classes"
	local classpath="${classes}:${JAVA_JAR_FILENAME}"
	java-pkg-simple_getclasspath
	java-pkg-simple_prepend_resources ${classes} "${JAVA_TEST_RESOURCE_DIRS[@]}"

	local tests_to_run
	# grab a set of tests that testing framework will run
	if [[ -n ${JAVA_TEST_RUN_ONLY} ]]; then
		tests_to_run="${JAVA_TEST_RUN_ONLY[@]}"
	else
		tests_to_run=$(find "${classes}" -type f\
			\( -name "*Test.class"\
			-o -name "Test*.class"\
			-o -name "*Tests.class"\
			-o -name "*TestCase.class" \)\
			! -name "*Abstract*"\
			! -name "*BaseTest*"\
			! -name "*TestTypes*"\
			! -name "*TestUtils*"\
			! -name "*\$*")
		tests_to_run=${tests_to_run//"${classes}"\/}
		tests_to_run=${tests_to_run//.class}
		tests_to_run=${tests_to_run//\//.}

		# exclude extra test classes, usually corner cases
		# that the code above cannot handle
		for class in "${JAVA_TEST_EXCLUDES[@]}"; do
			tests_to_run=${tests_to_run//${class}}
		done
	fi

	ejunit5 -classpath "${classpath}" ${tests_to_run}
}

_JAVA_PKG_JUNIT_5_ECLASS=1
fi

EXPORT_FUNCTIONS src_test
