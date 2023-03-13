# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="org.apache.logging.log4j:log4j-api:2.17.1"
JAVA_TESTING_FRAMEWORKS="junit-vintage junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="The Apache Log4j API"
HOMEPAGE="https://logging.apache.org/log4j/2.x/"
SRC_URI="https://archive.apache.org/dist/logging/log4j/${PV}/apache-log4j-${PV}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="2"
KEYWORDS="~amd64"

# junit-{jupiter,vintage} is not available in ::gentoo
#RESTRICT="test"

# Compile dependencies
# POM: ${PN}/pom.xml
# org.osgi:org.osgi.core:4.3.1 -> >=dev-java/osgi-core-api-5.0.0:0
# POM: ${PN}/pom.xml
# test? com.fasterxml.jackson.core:jackson-core:2.12.4 -> >=dev-java/jackson-core-2.13.0:0
# test? com.fasterxml.jackson.core:jackson-databind:2.12.4 -> >=dev-java/jackson-databind-2.13.0:0
# test? org.apache.commons:commons-lang3:3.12.0 -> >=dev-java/commons-lang-3.12.0:3.6
# test? org.apache.felix:org.apache.felix.framework:5.6.12 -> !!!groupId-not-found!!!
# test? org.apache.maven:maven-core:3.6.3 -> !!!groupId-not-found!!!
# test? org.assertj:assertj-core:3.20.2 -> !!!suitable-mavenVersion-not-found!!!
# test? org.eclipse.tycho:org.eclipse.osgi:3.13.0.v20180226-1711 -> !!!groupId-not-found!!!
# test? org.junit.jupiter:junit-jupiter-engine:5.7.2 -> !!!groupId-not-found!!!
# test? org.junit.jupiter:junit-jupiter-migrationsupport:5.7.2 -> !!!groupId-not-found!!!
# test? org.junit.jupiter:junit-jupiter-params:5.7.2 -> !!!groupId-not-found!!!
# test? org.junit.vintage:junit-vintage-engine:5.7.2 -> !!!groupId-not-found!!!

DEPEND=">=virtual/jdk-1.8:*
	dev-java/osgi-core-api:0
	test? (
		dev-java/junit:5[vintage]
		>=dev-java/commons-lang-3.12.0:3.6
		>=dev-java/jackson-core-2.13.0:0
		>=dev-java/jackson-databind-2.13.0:0
		dev-java/assertj-core:3
		dev-java/maven-bin:3.9
	)"

RDEPEND=">=virtual/jre-1.8:*"

DOCS=( {CONTRIBUTING,README,RELEASE-NOTES,SECURITY}.md LICENSE.txt )

S="${WORKDIR}/apache-log4j-${PV}-src"

JAVA_CLASSPATH_EXTRA="osgi-core-api"
JAVA_SRC_DIR="${PN}/src/main/java"
JAVA_RESOURCE_DIRS="${PN}/src/main/resources"

JAVA_TEST_GENTOO_CLASSPATH="
	jackson-core
	jackson-databind
	commons-lang-3.6
	assertj-core-3
	maven-bin-3.9
"
JAVA_TEST_SRC_DIR="${PN}/src/test/java"
JAVA_TEST_RESOURCE_DIRS=(
	"${PN}/src/test/resources"
)

#	src_prepare() {
#		default
#		mkdir -p log4j-api/src/main/resources/META-INF/versions/9 || die
#		pushd log4j-api/src/main/resources/META-INF/versions/9 || die
#			jar -xf "$(java-pkg_getjar --build-only log4j-api-java9-2 log4j-api-java9.jar)" \
#				org/apache/logging/log4j/util module-info.class || die
#			rm org/apache/logging/log4j/util/{PrivateSecurityManagerStackTraceUtil,PropertySource}.class || die
#		popd || die
#	}

src_test() {
	if ver_test "$(java-config -g PROVIDES_VERSION)" -ge 9; then
		rm -v "${JAVA_TEST_SRC_DIR}/org/apache/logging/log4j/util/StackLocatorUtilTest.java" ||
			die "Failed to remove extraneous test file"
		elog "Removed tests using classes no longer available on Java 9+"
	fi
	java-pkg-junit-5_src_test
}

src_install() {
	default # https://bugs.gentoo.org/789582
	java-pkg-simple_src_install
}
