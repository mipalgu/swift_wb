#
#	$Id$
#
# GU swift whiteboard Makefile
#
BIN=swift_wb

ALL_TARGETS=host
#CI_SERVER_DOC_SUBDIR=utils

SWIFT_SRCS=swift_wb.swift main.swift
SWIFT_BRIDGING_HEADER=swift_wb-Bridging-Header.h
SWIFTCFLAGS=-I${SRCDIR}/../.. -I${SRCDIR}/../../../Common

#USE_WB_LIB=yes				# libgusimplewhiteboard (not working)

.include "../../../mk/whiteboard.mk"	# I need the C whiteboard
.include "../../../mk/mipal.mk"		# comes last!
