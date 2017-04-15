#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <ziAPI.h>

#include "const-c.inc"

#if (IVSIZE != 8 || UVSIZE != 8)
#  error "Lab::Zhinst needs a perl with 64-bit integer support."
#endif

typedef ZIConnection Lab__Zhinst;

#define ALLOC_START_SIZE 100

static void
handle_error(ZIResult_enum number, const char *function)
{
  if (number == ZI_INFO_SUCCESS)
    return;
  
  char *buffer;
  ziAPIGetError(number, &buffer, NULL);
  croak("Error in %s: %s", function, buffer);
}

MODULE = Lab::Zhinst		PACKAGE = Lab::Zhinst		

INCLUDE: const-xs.inc



TYPEMAP: <<HERE
Lab::Zhinst          T_PTROBJ
HV *                 T_HVREF_REFCOUNT_FIXED
HERE



Lab::Zhinst
new(const char *class, const char *hostname, U16 port)
CODE:
    ZIConnection connection;
    handle_error(ziAPIInit(&connection), "ziAPIInit");
    handle_error(ziAPIConnect(connection, hostname, port), "ziAPIConnect");
    RETVAL = connection;
OUTPUT:
    RETVAL


void
DESTROY(Lab::Zhinst conn)
CODE:
    ziAPIDisconnect(conn);
    ziAPIDestroy(conn);



char *
ListImplementations()
CODE:
    size_t buffer_len = 100;
    char *buffer;
    New(0, buffer, buffer_len, char);
    handle_error(ziAPIListImplementations(buffer, buffer_len), "ziAPIListImplementations");
    RETVAL = buffer;
OUTPUT:
    RETVAL



unsigned
GetConnectionAPILevel(Lab::Zhinst conn)
CODE:
    ZIAPIVersion_enum version;
    handle_error(ziAPIGetConnectionAPILevel(conn, &version), "ziAPIGetConnectionAPILevel");
    RETVAL = version;
OUTPUT:
    RETVAL



char *
ListNodes(Lab::Zhinst conn, const char *path, U32 flags)
CODE:
    char *nodes = NULL;
    size_t nodes_len = ALLOC_START_SIZE;

    while (1) {
        Renew(nodes, nodes_len, char);
        int rv = ziAPIListNodes(conn, path, nodes, nodes_len, flags);
        if (rv == 0)
            break;
        if (rv != ZI_ERROR_LENGTH)
            handle_error(rv, "ziAPIListNodes");

        nodes_len = (nodes_len * 3) / 2;
    }
    RETVAL = nodes;
OUTPUT:
    RETVAL


double
GetValueD(Lab::Zhinst conn, const char *path)
CODE:
    double result;
    handle_error(ziAPIGetValueD(conn, path, &result), "ziAPIGetValueD");
    RETVAL = result;
OUTPUT:
    RETVAL

IV
GetValueI(Lab::Zhinst conn, const char *path)
CODE:
    IV result;
    handle_error(ziAPIGetValueI(conn, path, &result), "ziAPIGetValueI");
    RETVAL = result;
OUTPUT:
    RETVAL

HV *
GetDemodSample(Lab::Zhinst conn, const char *path)
CODE:
    ZIDemodSample sample;
    handle_error(ziAPIGetDemodSample(conn, path, &sample), "ziAPIGetDemodSample");
    HV *hash = newHV();
    hv_stores(hash, "timeStamp", newSVuv(sample.timeStamp));
    hv_stores(hash, "x", newSVnv(sample.x));
    hv_stores(hash, "y", newSVnv(sample.y));
    hv_stores(hash, "frequency", newSVnv(sample.frequency));
    hv_stores(hash, "phase", newSVnv(sample.phase));
    hv_stores(hash, "dioBits", newSVuv(sample.dioBits));
    hv_stores(hash, "trigger", newSVuv(sample.trigger));
    hv_stores(hash, "auxIn0", newSVnv(sample.auxIn0));
    hv_stores(hash, "auxIn1", newSVnv(sample.auxIn1));
    RETVAL = hash;
OUTPUT:
    RETVAL

SV *
GetValueB(Lab::Zhinst conn, const char *path)
CODE:
    char *result = NULL;
    size_t result_avail = ALLOC_START_SIZE;
    unsigned length;

    while (1) {
        Renew(result, result_avail, char);
        int rv = ziAPIGetValueB(conn, path, (unsigned char*) result, &length, result_avail);
        if (rv == 0)
            break;
        if (rv != ZI_ERROR_LENGTH)
            handle_error(rv, "ziAPIGetValueB");

        result_avail = (result_avail * 3) / 2;
    }
    RETVAL = newSVpvn(result, length);
OUTPUT:
    RETVAL

void
SetValueD(Lab::Zhinst conn, const char *path, double value)
CODE:
    handle_error(ziAPISetValueD(conn, path, value), "ziAPISetValueD");

void
SetValueI(Lab::Zhinst conn, const char *path, IV value)
CODE:
    handle_error(ziAPISetValueI(conn, path, value), "ziAPISetValueI");


void
SetValueB(Lab::Zhinst conn, const char *path, SV *value)
CODE:
    if (!SvOK(value)) {
       croak("value is not a valid scalar");
    }
    char *bytes;
    STRLEN len;
    bytes = SvPV(value, len);
    handle_error(ziAPISetValueB(conn, path, (unsigned char *) bytes, len), "ziAPISetValueB");


double
SyncSetValueD(Lab::Zhinst conn, const char *path, double value)
CODE:
    double result = value;
    handle_error(ziAPISyncSetValueD(conn, path, &result), "ziAPISyncSetValueD");
    RETVAL = result;
OUTPUT:
    RETVAL

IV
SyncSetValueI(Lab::Zhinst conn, const char *path, IV value)
CODE:
    IV result = value;
    handle_error(ziAPISyncSetValueI(conn, path, &result), "ziAPISyncSetValueI");
    RETVAL = result;
OUTPUT:
    RETVAL

SV *
SyncSetValueB(Lab::Zhinst conn, const char *path, SV *value)
CODE:
    if (!SvOK(value)) {
       croak("value is not a valid scalar");
    }
    char *original;
    STRLEN len;
    original = SvPV(value, len);

    char *new_string;
    New(0, new_string, len, char);
    Copy(original, new_string, len, char);
    handle_error(ziAPISyncSetValueB(conn, path, (uint8_t *) new_string, (uint32_t *) &len, len),
                 "ziAPISyncSetValueB");
    RETVAL = newSVpvn(new_string, len);
    Safefree(new_string);
OUTPUT:
    RETVAL
