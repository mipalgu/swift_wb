#
#	$Id$
#
# Global Makefile
#
NO_DEFAULT_DEPENDENCIES_TARGETS=yes

ALL_TARGETS=build

SWIFT_BUILD_CONFIG?=debug

USE_WB_LIB=yes

#.include "../../mk/subdir.mk"		# required for meta-makefiles


build:	clean
	env swift build -c ${SWIFT_BUILD_CONFIG} ${SWIFTCFLAGS:=-Xswiftc %} ${CFLAGS:=-Xcc %} ${LDFLAGS:=-Xlinker %}
	#cd machines && bmake && cd ../

test:	clean
	swift test ${SWIFTCFLAGS:=-Xswiftc %} ${CFLAGS:=-Xcc %} ${LDFLAGS:=-Xlinker %}

clean:
	swift build --clean
	#cd machines && bmake clean && cd ../

.include "../../mk/mipal.mk"		# comes last!

.if ${OS} == Darwin
LDFLAGS+=-lc++
.endif
