#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "/home/simon/perl/ziAPI.h"

#include "const-c.inc"

MODULE = Lab::Zhinst		PACKAGE = Lab::Zhinst		

INCLUDE: const-xs.inc
