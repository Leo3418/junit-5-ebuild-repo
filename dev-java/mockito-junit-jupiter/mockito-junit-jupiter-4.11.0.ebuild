# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="org.mockito:mockito-junit-jupiter:4.11.0"
JAVA_TESTING_FRAMEWORKS="junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="Mockito JUnit 5 support"
HOMEPAGE="https://github.com/mockito/mockito"
SRC_URI="https://github.com/mockito/mockito/archive/v${PV}.tar.gz -> mockito-${PV}.tar.gz"

LICENSE="MIT"
SLOT="4"
KEYWORDS="~amd64"

CP_DEPEND="
	~dev-java/mockito-${PV}:${SLOT}
	dev-java/junit:5
"

DEPEND="
	>=virtual/jdk-1.8:*
	${CP_DEPEND}
	test? (
		dev-java/assertj-core:3
	)
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

S="${WORKDIR}/mockito-${PV}/subprojects/junit-jupiter"

JAVA_AUTOMATIC_MODULE_NAME="org.mockito.junit.jupiter"
JAVA_SRC_DIR="src/main/java"

JAVA_TEST_GENTOO_CLASSPATH="assertj-core-3"
JAVA_TEST_SRC_DIR="src/test/java"
