# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="org.assertj:assertj-core:3.24.2"
# Tests need JUnit 5 and many other unpackaged dependencies
JAVA_TESTING_FRAMEWORKS="junit-jupiter junit-vintage"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

MY_PN="assertj-build"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Rich and fluent assertions for testing for Java"
HOMEPAGE="https://assertj.github.io/doc/"
SRC_URI="https://github.com/assertj/${PN}/archive/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="3"
KEYWORDS="~amd64"

CP_DEPEND="
	>=dev-java/byte-buddy-1.12.12:0
	dev-java/hamcrest:0
	dev-java/junit:4
	dev-java/junit:5
	dev-java/opentest4j:0
"

# Limiting JDK version to >=11 for module-info.java in this package
# https://bugs.gentoo.org/796875#c3
DEPEND="
	>=virtual/jdk-11:*
	${CP_DEPEND}
	test? (
		dev-java/commons-collections:4
		dev-java/commons-io:1
		dev-java/commons-lang:3.6
		dev-java/equalsverifier:0
		dev-java/guava:0
		dev-java/jackson-databind:0
		dev-java/jaxrs-api:3
		dev-java/junit:5[vintage]
		dev-java/junit-platform-testkit:0
		dev-java/junit-pioneer:0
		dev-java/mockito:4
		dev-java/mockito-junit-jupiter:4
		dev-java/univocity-parsers:0
	)
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

DOCS=( {CODE_OF_CONDUCT,CONTRIBUTING,README}.md )

S="${WORKDIR}/assertj-${MY_P}"

JAVA_SRC_DIR=( ${PN}/src/main/java{,9} )

JAVA_TEST_GENTOO_CLASSPATH="
	commons-collections-4
	commons-io-1
	commons-lang-3.6
	equalsverifier
	guava
	jackson-databind
	jaxrs-api-3
	junit-platform-testkit
	junit-pioneer
	mockito-4
	mockito-junit-jupiter-4
	univocity-parsers
"

# The default "traditional" method causes ClassNotFoundException --
# maybe because this package has 18,000+ tests, so the command that
# launches JUnit 5 would be too long with "traditional"?
JAVA_TEST_SELECTION_METHOD="scan-classpath"
JAVA_TEST_SRC_DIR="${PN}/src/test/java"
JAVA_TEST_RESOURCE_DIRS="${PN}/src/test/resources"
JAVA_TEST_EXTRA_ARGS=(
	--add-opens=java.base/java.lang=ALL-UNNAMED
	--add-opens=java.base/java.math=ALL-UNNAMED
	--add-opens=java.base/java.util=ALL-UNNAMED
)

src_test() {
	# The Maps unit tests for org.assertj.core.internal depend on libraries
	# that are hard to package:
	# - org.hibernate.orm:hibernate-core: Large package, with a lot of source
	#   files and several dependencies not in ::gentoo yet
	# - org.springframework:spring-core: Many dependencies not in ::gentoo yet,
	#   including Kotlin
	rm -r "${JAVA_TEST_SRC_DIR}/org/assertj/core/internal"/{MapsBaseTest.java,maps} ||
		die "Failed to remove tests with unsatisfied dependencies"

	# - Our JUnit 5 package does not bundle dependencies by shadowing them
	# - Some test sources assume working directory to be ${PN}
	ebegin "Fixing test sources"
	find "${JAVA_TEST_SRC_DIR}" -type f -name '*.java' -exec sed -i \
		-e 's/org\.junit\.jupiter\.params\.shadow\.//g' \
		-e "s|src/main/scripts|${PN}/src/main/scripts|g" \
		-e "s|src/test/resources|${JAVA_TEST_RESOURCE_DIRS}|g" \
		-e "s|\"src\"|\"${PN}/src\"|g" \
		{} +
	eend $? || die "Failed to fix test sources"

	java-pkg-junit-5_src_test
}
