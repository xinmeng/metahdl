/* Copyright (C) 1996 Himanshu M. Thaker

This file is part of vpp.

Vpp is distributed in the hope that it will be useful,
but without any warranty.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.

Everyone is granted permission to copy, modify and redistribute
vpp, but only under the conditions described in the
document "vpp copying permission notice".   An exact copy
of the document is supposed to have been given to you along with
vpp so that you can know how you may redistribute it all.
It should be in a file named COPYING.  Among other things, the
copyright notice and this notice must be preserved on all copies.  */

#ifndef VPP_COMMON_H
#define VPP_COMMON_H

/*
 * first, the include files...
 */
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>

/*
 * then, some globally accessible defines...
 */
#define MAXSTR 256
#define MAXNAME 16384
#define BASE 8161
#define	FALSE	0
#define	TRUE	1
#define MALLOC(type)     ((type *) malloc(sizeof(type)))
#define NMALLOC(n,type)  ((type *) malloc((n)*sizeof(type)))
#define CALLOC(n,type)   ((type *) calloc((n),sizeof(type)))

#endif /* VPP_COMMON_H */
