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

# @ECLASS_VARIABLE: JAVA_TEST_SELECTION_METHOD
# @DESCRIPTION:
# A string that represents the method to discover and select test classes to
# run on the JUnit Platform.  These values are accepted:
#
# - "traditional" (default): Use the same method as java-pkg-simple.eclass.
#
# - "scan-classpath": Rely on the JUnit Platform's ConsoleLauncher's
#   '--scan-classpath' option to discover tests, and run these discovered
#   tests.  JAVA_TEST_RUN_ONLY and JAVA_TEST_EXCLUDES are both honored.
#
# - "scan-classpath+pattern": Rely on the JUnit Platform's ConsoleLauncher's
#   '--scan-classpath' option to discover tests, but also select the same tests
#   that java-pkg-simple.eclass would select from the discovered tests
#   JAVA_TEST_RUN_ONLY and JAVA_TEST_EXCLUDES are both honored.
#
# - "console-args": Do not perform any test discovery or test selection;
#   instead, pass the JAVA_JUNIT_CONSOLE_ARGS variable's value to the JUnit
#   Platform's ConsoleLauncher.  In this case, JAVA_JUNIT_CONSOLE_ARGS should
#   contain arguments to ConsoleLauncher that select tests to run.  Neither
#   JAVA_TEST_RUN_ONLY nor JAVA_TEST_EXCLUDES is honored.
: ${JAVA_TEST_SELECTION_METHOD:=traditional}

# @ECLASS_VARIABLE: JAVA_JUNIT_CONSOLE_ARGS
# @DEFAULT_UNSET
# @DESCRIPTION:
# Extra arguments to pass to JUnit Platform's ConsoleLauncher only when
# JAVA_TEST_SELECTION_METHOD="console-args".  Any white-space character in this
# variable's value will separate tokens into different arguments.

# @ECLASS_VARIABLE: JAVA_JUNIT_CONSOLE_COLOR
# @USER_VARIABLE
# @DEFAULT_UNSET
# @DESCRIPTION:
# If this variable's value is not empty, enable color in the JUnit Platform's
# ConsoleLauncher's output.

if has test ${JAVA_PKG_IUSE}; then
	DEPEND="test? (
		dev-java/junit:5
	)"
fi

java-pkg-junit-5_pkg_setup() {
	java-pkg-2_pkg_setup
	[[ ${MERGE_TYPE} == binary ]] && return

	# Note: Each method must have a "_java-pkg-junit-5_src_test_${method}"
	# function in this eclass
	local test_selection_methods="
		traditional
		scan-classpath
		scan-classpath+pattern
		console-args
	"
	if has ${JAVA_TEST_SELECTION_METHOD} ${test_selection_methods}; then
		einfo "JUnit Platform test selection method: ${JAVA_TEST_SELECTION_METHOD}"
	else
		eerror "Unknown test selection method: ${JAVA_TEST_SELECTION_METHOD}"
		eerror "Accepted methods are:"
		local method
		for method in ${test_selection_methods}; do
			eerror "- ${method}"
		done
		die "Invalid value for JAVA_TEST_SELECTION_METHOD: ${JAVA_TEST_SELECTION_METHOD}"
	fi
}

# @FUNCTION: ejunit5
# @USAGE: [-cp <classpath>|-classpath <classpath>] <classes>
# @DESCRIPTION:
# Using the specified classpath, launches a JVM instance to run the specified
# test classes by invoking the JUnit Platform's ConsoleLauncher.
#
# This function's interface is consistent with the existing 'ejunit' and
# 'ejunit4' functions in java-utils-2.eclass.
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

	_java-pkg-junit-5_ConsoleLauncher "${cp}"$(printf -- ' -c=%q' "${@}")
}

# @FUNCTION: _java-pkg-junit-5_ConsoleLauncher
# @INTERNAL
# @USAGE: <classpath> [args]
# @DESCRIPTION:
# Invokes the JUnit Platform's ConsoleLauncher on the specified classpath,
# using the specified arguments.
_java-pkg-junit-5_ConsoleLauncher() {
	debug-print-function ${FUNCNAME} $*

	local cp=${1}
	shift 1

	# Save test reports, which contain information about
	# the test execution that can be useful to QA checks
	local reports_dir=${T}/junit-5-reports
	mkdir -p "${reports_dir}" || die "Failed to create JUnit report directory"

	local runner=org.junit.platform.console.ConsoleLauncher
	local runner_args=(
		--reports-dir="${reports_dir}"
		--fail-if-no-tests

		# By default, remove ANSI escape code for coloring
		# to make log files more readable
		$([[ ${JAVA_JUNIT_CONSOLE_COLOR} ]] || echo --disable-ansi-colors)

		${JAVA_PKG_DEBUG:+--details=verbose}
	)

	local args=(
		-cp "${cp}"
		-Djava.io.tmpdir="${T}"
		-Djava.awt.headless=true
		"${JAVA_TEST_EXTRA_ARGS[@]}"
		${runner}
		"${runner_args[@]}"
		"${JAVA_TEST_RUNNER_EXTRA_ARGS[@]}"
		"${@}"
	)

	set -- java "${args[@]}"
	debug-print "Calling: ${*}"
	echo "${@}" >&2
	"${@}"
	local ret=${?}
	[[ ${ret} -eq 2 ]] && die "No JUnit tests found"
	[[ ${ret} -eq 0 ]] || die "ConsoleLauncher failed"

	# Check whether any test engine installed with dev-java/junit:5 ran tests,
	# but the test engine's corresponding USE flag is not declared in the
	# dev-java/junit:5 atom's USE dependencies.
	#
	# Suppose an ebuild author has already installed dev-java/junit:5 with the
	# 'suite' USE flag enabled, and they are creating a new ebuild that has
	# tests to run on the junit-platform-suite test engine.  If the author had
	# disabled the 'suite' USE flag, some tests might fail due to the missing
	# JUnit 5 modules, so the author could realize that the ebuild needs to
	# depend on dev-java/junit:5[suite].  However, the USE flag is enabled, so
	# it is possible that all tests pass in the author's environment, thus the
	# author thinks the ebuild does not have issues and publishes it.
	#
	# When another person gets the ebuild and tries to run the tests in an
	# environment where dev-java/junit:5's 'suite' USE flag is _not_ enabled,
	# the tests _will_ launch and then fail.  The dev-java/junit:5[suite]
	# dependency is not declared, so the package manager will not enforce it.
	#
	# Therefore, this check is added to help avoid such situations.

	# If a test engine ran any tests, its report will contain a
	# '<testcase ...>...</testcase>' XML entry for each test it ran
	local engines_with_tests=$(grep -l '</testcase>' \
		"${reports_dir}"/TEST-junit-*.xml)
	# A test engine's report filename format is "TEST-${engine_id}.xml"
	engines_with_tests="${engines_with_tests//"${reports_dir}/TEST-"}"
	engines_with_tests="${engines_with_tests//.xml}"

	local engine flag
	local unexpected_engines=()
	for engine in ${engines_with_tests}; do
		case ${engine} in
			junit-jupiter)
				# Built unconditionally in dev-java/junit:5; no USE flag needed
				;;
			junit-platform-suite)
				flag=suite
				;;
			junit-vintage)
				flag=vintage
				;;
		esac
		[[ -z ${flag} ]] || _java-pkg-junit-5_dep_has_use "${flag}" ||
			unexpected_engines+=( "${engine}: dev-java/junit:5[${flag}]" )
	done
	if [[ -n ${unexpected_engines[@]} ]]; then
		eqawarn "Some tests ran on a JUnit Platform test engine whose USE flag"
		eqawarn "is not enabled by the dev-java/junit:5 atom in DEPEND."
		eqawarn "Please check the following test engine list and add the"
		eqawarn "mentioned USE dependencies into DEPEND=\"test? ( ... )\":"
		for engine in "${unexpected_engines}"; do
			eqawarn "- ${engine}"
		done
	fi
}

# @FUNCTION: _java-pkg-junit-5_dep_has_use
# @INTERNAL
# @USAGE: <flag>
# @DESCRIPTION:
# Checks whether dev-java/junit:5 is declared with USE dependency on the
# specified USE flag (i.e. dev-java/junit:5[<flag>]) in DEPEND.
# @RETURN: Shell true if the check passed, shell false otherwise
_java-pkg-junit-5_dep_has_use() {
	debug-print-function ${FUNCNAME} $*

	local flag=${1}

	local re="\bdev-java/junit(-[0-9].*)?:5\[[^]]*\b${flag}\b[^]]*\]"
	# Do not match "dev-java/junit:5[-${flag}]"
	local n_re1="\bdev-java/junit(-[0-9].*)?:5\[[^]]*-\b${flag}\b[^]]*\]"
	[[ ${DEPEND} =~ ${re} && ! ${DEPEND} =~ ${n_re1} ]]
}

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

	"_java-pkg-junit-5_src_test_${JAVA_TEST_SELECTION_METHOD}"
}

# @FUNCTION: _java-pkg-junit-5_src_test_traditional
# @INTERNAL
# @DESCRIPTION:
# Finds tests to run using the traditional method that java-pkg-simple.eclass
# utilizes, then runs these tests on the JUnit Platform.
#
# The method to find tests is:
# 1. If JAVA_TEST_RUN_ONLY is defined, run only the tests listed in it, and
#    skip the rest steps.
# 2. Use the 'find' command to gather a list of Java source files whose
#    filename matches a preset pattern.
# 3. Remove any tests in JAVA_TEST_EXCLUDES from the list.  Run tests that are
#    still in the list after the removal.
_java-pkg-junit-5_src_test_traditional() {
	debug-print-function ${FUNCNAME} $*

	local tests_to_run
	# grab a set of tests that testing framework will run
	if [[ -n ${JAVA_TEST_RUN_ONLY} ]]; then
		tests_to_run="${JAVA_TEST_RUN_ONLY[@]}"
	else
		pushd "${JAVA_TEST_SRC_DIR}" > /dev/null || die
		tests_to_run=$(find * -type f\
			\( -name "*Test.java"\
			-o -name "Test*.java"\
			-o -name "*Tests.java"\
			-o -name "*TestCase.java" \)\
			! -name "*Abstract*"\
			! -name "*BaseTest*"\
			! -name "*TestTypes*"\
			! -name "*TestUtils*"\
			! -name "*\$*")
		tests_to_run=${tests_to_run//"${classes}"\/}
		tests_to_run=${tests_to_run//.java}
		tests_to_run=${tests_to_run//\//.}
		popd > /dev/null || die

		# exclude extra test classes, usually corner cases
		# that the code above cannot handle
		local class
		for class in "${JAVA_TEST_EXCLUDES[@]}"; do
			tests_to_run=${tests_to_run//${class}}
		done
	fi

	ejunit5 -classpath "${classpath}" ${tests_to_run}
}

# @FUNCTION: _java-pkg-junit-5_src_test_scan-classpath
# @INTERNAL
# @DESCRIPTION:
# If JAVA_TEST_RUN_ONLY is defined, runs only the tests listed in it on the
# JUnit Platform.
# Otherwise, runs the JUnit Platform's ConsoleLauncher with the
# '--scan-classpath' to let the JUnit Platform automatically detect, select,
# and run tests.  JAVA_TEST_EXCLUDES is still honored in this case.
_java-pkg-junit-5_src_test_scan-classpath() {
	debug-print-function ${FUNCNAME} $*

	if [[ -n ${JAVA_TEST_RUN_ONLY} ]]; then
		ejunit5 -classpath "${classpath}" "${JAVA_TEST_RUN_ONLY[@]}"
	else
		local args=(
			--scan-classpath
		)

		# 'includes' and 'excludes' may be set by another function.
		#
		# The 'classname' options take a regular expression for a class's
		# fully qualified name, which contains the class's package.
		# '^(.*\.)*' matches the package part in the class name;
		# '[^.]*$' prevents the pattern for a class name to match any part of
		# the package name.
		local pattern
		for pattern in "${includes[@]}"; do
			args+=( --include-classname="^(.*\\.)*${pattern}[^.]*\$" )
		done
		for pattern in "${excludes[@]}"; do
			args+=( --exclude-classname="^(.*\\.)*${pattern}[^.]*\$" )
		done

		local class
		for class in "${JAVA_TEST_EXCLUDES[@]}"; do
			args+=( --exclude-classname="^${class//./\\.}\$" )
		done

		_java-pkg-junit-5_ConsoleLauncher "${classpath}" "${args[@]}"
	fi
}

# @FUNCTION: _java-pkg-junit-5_src_test_scan-classpath+pattern
# @INTERNAL
# @DESCRIPTION:
# If JAVA_TEST_RUN_ONLY is defined, runs only the tests listed in it on the
# JUnit Platform.
# Otherwise, finds tests to run using the JUnit Platform's ConsoleLauncher's
# '--scan-classpath' option, and also includes and excludes class names based
# on the test class name patterns that java-pkg-simple.eclass uses.  Then, runs
# the found tests on the JUnit Platform.
_java-pkg-junit-5_src_test_scan-classpath+pattern() {
	debug-print-function ${FUNCNAME} $*

	local includes=(
		'.*Test'
		'Test.*'
		'.*Tests'
		'.*TestCase'
	)
	local excludes=(
		'.*Abstract.*'
		'.*BaseTest.*'
		'.*TestTypes.*'
		'.*TestUtils.*'
		'.*\$.*'
	)
	_java-pkg-junit-5_src_test_scan-classpath
}

# @FUNCTION: _java-pkg-junit-5_src_test_console-args
# @INTERNAL
# @DESCRIPTION:
# Does not do anything with regards to test selection at all; instead, passes
# JAVA_JUNIT_CONSOLE_ARGS to JUnit Platform's ConsoleLauncher, and lets the
# arguments in JAVA_JUNIT_CONSOLE_ARGS control test selection.
_java-pkg-junit-5_src_test_console-args() {
	_java-pkg-junit-5_ConsoleLauncher "${classpath}" ${JAVA_JUNIT_CONSOLE_ARGS}
}

_JAVA_PKG_JUNIT_5_ECLASS=1
fi

EXPORT_FUNCTIONS pkg_setup src_test
