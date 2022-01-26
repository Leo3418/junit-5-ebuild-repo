# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source"
MAVEN_ID="org.junit.jupiter:junit-jupiter-params:5.7.2"

inherit java-pkg-2 java-pkg-simple

DESCRIPTION="JUnit Jupiter extension for parameterized tests"
HOMEPAGE="https://junit.org/junit5/"
SRC_URI="https://github.com/junit-team/junit5/archive/refs/tags/r${PV}.tar.gz -> junit5-r${PV}.tar.gz"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

# JUnit 5.x.y = Platform 1.x.y + Jupiter 5.x.y + Vintage 5.x.y
PLATFORM_PV="1.$(ver_cut 2-)"

CP_DEPEND="
	~dev-java/junit-jupiter-api-${PV}:0
	~dev-java/junit-platform-commons-${PLATFORM_PV}:0
	dev-java/apiguardian-api:0
	dev-java/univocity-parsers:0
"

DEPEND="
	>=virtual/jdk-1.8:*
	${CP_DEPEND}
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

S="${WORKDIR}/junit5-r${PV}/${PN}"

JAVA_SRC_DIR=(
	src/main/java
	src/module
)
