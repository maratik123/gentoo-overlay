# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-r3

DESCRIPTION="Nim (formerly known as 'Nimrod') is a compiled, garbage-collected systems programming language"
HOMEPAGE="http://nim-lang.org/"
EGIT_REPO_URI="https://github.com/Araq/Nim"
EGIT_CLONE_TYPE="shallow"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc +readline test"

DEPEND="
	readline? ( sys-libs/readline )
"
RDEPEND=""

src_unpack() {
	git-r3_src_unpack
	local csources_repo="https://github.com/nim-lang/csources"
	git-r3_fetch "${csources_repo}"
	git-r3_checkout "${csources_repo}" ${WORKDIR}/${P}/csources
}

nim_use_enable() {
	[[ -z $2 ]] && die "usage: nim_use_enable <USE flag> <compiler flag>"
	use $1 && echo "-d:$2"
}

src_compile() {
	cd csources && sh build.sh || die "build.sh failed"
	cd ..
	./bin/nim c koch || die "csources nim failed"
	./koch boot -d:release $(nim_use_enable readline useGnuReadline) || die "koch boot failed"
	
	if use doc; then
		PATH="./bin:$PATH" ./koch web || die "koch web failed"
	fi
}

src_test() {
	PATH="./bin:$PATH" ./koch test
}

src_install() {
	./koch install "${D}/usr/share" || die "koch install failed"
	rm -r "${D}/usr/share/nim/doc"
	dodir /usr/bin
	dosym /usr/share/nim/bin/nim /usr/bin/nim

	if use doc; then
		dohtml doc/*.html
	fi
}
