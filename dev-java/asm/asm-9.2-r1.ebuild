# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
JAVA_PKG_IUSE="doc source test"
MAVEN_ID="org.ow2.asm:asm:9.2"
JAVA_TESTING_FRAMEWORKS="junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="Bytecode manipulation framework for Java"
HOMEPAGE="https://asm.ow2.io"
MY_P="ASM_${PV//./_}"
SRC_URI="https://gitlab.ow2.org/asm/asm/-/archive/${MY_P}/asm-${MY_P}.tar.gz"
LICENSE="BSD"
SLOT="9"
KEYWORDS="~amd64"

CDEPEND=""
DEPEND=">=virtual/jdk-1.8:*"
RDEPEND=">=virtual/jre-1.8:*"

JAVA_SRC_DIR="asm-${MY_P}/${PN}/src/main/java"

JAVA_TEST_SRC_DIR=(
	"asm-${MY_P}/${PN}/src/test/java"
	"asm-${MY_P}/${PN}-test/src/main/java"
)
JAVA_TEST_RESOURCE_DIRS=(
	"asm-${MY_P}/${PN}/src/test/resources"
	"asm-${MY_P}/${PN}-test/src/main/resources"
)

src_test() {
	# The test suite attempts to find these files under the working directory
	mkdir -p src/test/resources || die
	cp -v "${JAVA_TEST_RESOURCE_DIRS[0]}"/*.class src/test/resources || die
	java-pkg-junit-5_src_test
}
