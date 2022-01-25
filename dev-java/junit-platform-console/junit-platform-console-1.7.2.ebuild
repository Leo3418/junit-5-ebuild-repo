# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source"
MAVEN_ID="org.junit.platform:junit-platform-console:1.7.2"

inherit java-pkg-2 java-pkg-simple readme.gentoo-r1

# JUnit 5.x.y = Platform 1.x.y + Jupiter 5.x.y + Vintage 5.x.y
MY_PV="5.$(ver_cut 2-)"

DESCRIPTION="JUnit Platform Console for JUnit 5"
HOMEPAGE="https://junit.org/junit5/"
SRC_URI="https://github.com/junit-team/junit5/archive/refs/tags/r${MY_PV}.tar.gz -> junit5-r${MY_PV}.tar.gz"

LICENSE="EPL-2.0"
SLOT="0"
KEYWORDS="~amd64"

CP_DEPEND="
	~dev-java/junit-platform-commons-${PV}:0
	~dev-java/junit-platform-engine-${PV}:0
	~dev-java/junit-platform-launcher-${PV}:0
	~dev-java/junit-platform-reporting-${PV}:0
	dev-java/apiguardian-api:0
	dev-java/picocli:0
"

DEPEND="
	>=virtual/jdk-1.8:*
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

JAVA_MAIN_CLASS="org.junit.platform.console.ConsoleLauncher"
JAVA_LAUNCHER_FILENAME="${PN}"

README_GENTOO_SUFFIX="-java-version-compatibility"

pkg_setup() {
	java-pkg-2_pkg_setup
	if ver_test "$(java-config -g PROVIDES_VERSION)" -ge 9; then
		NO_JAVA_8_COMPAT="true"
		# Print a message in pkg_postinst indicating incompatibility with Java 8
		FORCE_PRINT_ELOG="true"
		JAVA_SRC_DIR+=( src/main/java9 )
	fi
}

src_install() {
	java-pkg-simple_src_install
	[[ "${NO_JAVA_8_COMPAT}" ]] && readme.gentoo_create_doc
}

pkg_postinst() {
	[[ "${NO_JAVA_8_COMPAT}" ]] && readme.gentoo_print_elog
}
