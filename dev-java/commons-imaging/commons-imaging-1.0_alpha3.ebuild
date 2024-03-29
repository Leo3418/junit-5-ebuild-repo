# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="org.apache.commons:commons-imaging:1.0-alpha2"
JAVA_TESTING_FRAMEWORKS="junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="Apache Commons Imaging (previously Sanselan) is a pure-Java image library."
HOMEPAGE="https://commons.apache.org/proper/commons-imaging/"
SRC_URI="mirror://apache/commons/imaging/source/commons-imaging-${PV/_/-}-src.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

# Compile dependencies
# POM: pom.xml
# test? commons-io:commons-io:2.7 -> >=dev-java/commons-io-2.11.0:1
# test? org.hamcrest:hamcrest:2.2 -> !!!artifactId-not-found!!!
# test? org.junit.jupiter:junit-jupiter:5.6.2 -> !!!groupId-not-found!!!

DEPEND="
	>=virtual/jdk-1.8:*
	test? (
		dev-java/commons-io:1
		dev-java/hamcrest:0
	)
"
RDEPEND=">=virtual/jre-1.8:*"

DOCS=( {LICENSE,NOTICE,RELEASE-NOTES}.txt README.md )

S="${WORKDIR}/${P/_/-}-src"

JAVA_SRC_DIR="src/main/java"
JAVA_RESOURCE_DIRS="src/main/resources"
JAVA_AUTOMATIC_MODULE_NAME="org.apache.commons.imaging"

JAVA_TEST_GENTOO_CLASSPATH="commons-io-1,hamcrest"
JAVA_TEST_SRC_DIR="src/test/java"
JAVA_TEST_RESOURCE_DIRS="src/test/resources"
