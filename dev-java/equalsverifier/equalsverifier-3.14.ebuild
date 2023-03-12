# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Tests not enabled: Need JUnit 5 and several unpackaged dependencies
JAVA_PKG_IUSE="doc source"
MAVEN_ID="nl.jqno.equalsverifier:equalsverifier:3.14"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="Library for testing the Object.equals and Object.hashCode methods' contract"
HOMEPAGE="https://jqno.nl/equalsverifier/"
SRC_URI="https://github.com/jqno/equalsverifier/archive/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

CP_DEPEND="
	dev-java/byte-buddy:0
	dev-java/findbugs-annotations:0
	dev-java/guava:0
	dev-java/joda-time:0
	dev-java/objenesis:0
"

DEPEND="
	>=virtual/jdk-1.8:*
	${CP_DEPEND}
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

S="${WORKDIR}/${PN}-${P}"

JAVA_SRC_DIR="${PN}-core/src/main/java"

JAVA_TEST_SRC_DIR="${PN}-core/src/test/java"
JAVA_TEST_RESOURCE_DIRS="${PN}-core/src/test/resources"
