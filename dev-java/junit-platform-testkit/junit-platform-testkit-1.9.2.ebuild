# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# This package will be eventually replaced by dev-java/junit:5[testkit]

EAPI=8

JAVA_PKG_IUSE="doc source"
MAVEN_ID="org.junit.platform:junit-platform-testkit:1.9.2"

inherit java-pkg-2 java-pkg-simple

# JUnit 5.x.y = Platform 1.x.y + Jupiter 5.x.y + Vintage 5.x.y
MY_PV="5.$(ver_cut 2-)"

DESCRIPTION="JUnit Platform Test Kit"
HOMEPAGE="https://junit.org/junit5/"
SRC_URI="https://github.com/junit-team/junit5/archive/refs/tags/r${MY_PV}.tar.gz -> junit-${MY_PV}.tar.gz"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

CP_DEPEND="
	~dev-java/junit-${MY_PV}:5
	dev-java/apiguardian-api:0
	>=dev-java/assertj-core-3.14.0:3
	dev-java/opentest4j:0
"

DEPEND="
	>=virtual/jdk-11:*
	${CP_DEPEND}
"

RDEPEND="
	>=virtual/jre-1.8:*
	${CP_DEPEND}
"

S="${WORKDIR}/junit5-r${MY_PV}/${PN}"

JAVA_SRC_DIR=(
	src/main/java
	src/module
)
