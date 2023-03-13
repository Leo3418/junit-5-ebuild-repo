# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# No tests since we don't have junit-jupiter
JAVA_PKG_IUSE="doc source test"
MAVEN_ID="jakarta.el:jakarta.el-api:5.0.1"
JAVA_TESTING_FRAMEWORKS="junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="Jakarta Expression Language defines an expression language for Java applications"
HOMEPAGE="https://projects.eclipse.org/projects/ee4j.el"
SRC_URI="https://github.com/jakartaee/expression-language/archive/${PV}-RELEASE-api.tar.gz -> ${P}.tar.gz"

LICENSE="EPL-2.0 GPL-2-with-classpath-exception"
KEYWORDS="~amd64"
SLOT="5.0"

DEPEND=">=virtual/jdk-11:*"
# <release>11</release>
# https://github.com/jakartaee/expression-language/blob/5.0.1-RELEASE-api/api/pom.xml#L143
RDEPEND=">=virtual/jre-11:*"

DOCS=( {CONTRIBUTING,NOTICE,README}.md )

S="${WORKDIR}/expression-language-${PV}-RELEASE-api"

JAVA_SRC_DIR="api/src/main/java"

JAVA_TEST_SRC_DIR="api/src/test/java"
