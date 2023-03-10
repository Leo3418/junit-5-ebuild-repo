# Copyright 2022-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# Skeleton command:
# java-ebuilder --generate-ebuild --workdir . --pom pom.xml --download-uri https://github.com/jakartaee/servlet/archive/6.0.0-RELEASE.tar.gz --slot 6 --keywords "~amd64 ~arm ~arm64 ~ppc64 ~x86" --ebuild jakarta-servlet-api-6.0.0.ebuild

EAPI=8

JAVA_PKG_IUSE="doc source test"
MAVEN_ID="jakarta.servlet:jakarta.servlet-api:6.0.0"
JAVA_TESTING_FRAMEWORKS="junit-jupiter"

inherit java-pkg-2 java-pkg-simple java-pkg-junit-5

DESCRIPTION="Javax servlet API"
HOMEPAGE="https://projects.eclipse.org/projects/ee4j.servlet"
SRC_URI="https://github.com/jakartaee/servlet/archive/${PV}-RELEASE.tar.gz -> ${P}-RELEASE.tar.gz"

LICENSE="EPL-2.0 GPL-2-with-classpath-exception"
SLOT="6"
KEYWORDS="~amd64"

RDEPEND=">=virtual/jre-1.8:*"
DEPEND="
	>=virtual/jdk-11:*
	test? (
		dev-java/hamcrest:0
	)
"

DOCS=( {CONTRIBUTING,NOTICE,README}.md )

S="${WORKDIR}/servlet-${PV}-RELEASE"

JAVA_SRC_DIR="api/src/main/java"
JAVA_RESOURCE_DIRS=( api/src/main/{resources,properties} )

JAVA_TEST_SRC_DIR="api/src/test/java"
JAVA_TEST_GENTOO_CLASSPATH="hamcrest"

src_prepare() {
	default
	cp -r api/src/main/{java,properties} || die
	find api/src/main/properties -type f ! -name '*.properties' -exec rm -rf {} + || die
	java-pkg-2_src_prepare
}
