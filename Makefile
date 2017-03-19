#
#	$Id$
#
# Global Makefile
#

ALL_TARGETS=host-local

SWIFTCFLAGS+=-L/usr/local/lib -I/usr/local/include

.include "../../../mk/mipal.mk"		# comes last!

CFLAGS+=-I../../../Common
