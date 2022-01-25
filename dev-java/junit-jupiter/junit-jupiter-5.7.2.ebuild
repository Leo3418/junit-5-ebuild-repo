# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MAVEN_ID="org.junit.jupiter:junit-jupiter:5.7.2"

inherit java-pkg-2

DESCRIPTION="JUnit Jupiter (Aggregator) Metapackage for JUnit 5"
HOMEPAGE="https://junit.org/junit5/"

LICENSE="metapackage"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=virtual/jdk-1.8:*
"

RDEPEND="
	>=virtual/jre-1.8:*
	~dev-java/junit-jupiter-api-${PV}:0
	~dev-java/junit-jupiter-params-${PV}:0
	~dev-java/junit-jupiter-engine-${PV}:0
"

S="${WORKDIR}"

src_install() {
	java-pkg_register-dependency junit-jupiter-api
	java-pkg_register-dependency junit-jupiter-params
	java-pkg_register-dependency junit-jupiter-engine
}
