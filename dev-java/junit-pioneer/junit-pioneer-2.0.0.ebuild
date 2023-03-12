# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Tests not enabled: Need JUnit 5 and several unpackaged dependencies
JAVA_PKG_IUSE="doc source"
MAVEN_ID="org.junit-pioneer:junit-pioneer:2.0.0"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="A JUnit 5 extension pack"
HOMEPAGE="https://junit-pioneer.org/"
SRC_URI="https://github.com/junit-pioneer/junit-pioneer/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

CP_DEPEND="
	dev-java/jackson-core:0
	dev-java/jackson-databind:0
	dev-java/junit:5
"

# Limiting JDK version to >=11 for module-info.java in this package
# https://bugs.gentoo.org/796875#c3
DEPEND="
	>=virtual/jdk-11:*
	${CP_DEPEND}
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

# Restore the default value of 'S' overridden by java-pkg-simple.eclass
S="${WORKDIR}/${P}"

JAVA_SRC_DIR="src/main/java"
JAVA_RESOURCE_DIRS="src/main/resources"

JAVA_TEST_SRC_DIR="src/test/java"
JAVA_TEST_RESOURCE_DIRS="src/test/resources"
