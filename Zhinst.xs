#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <ziAPI.h>

#include "const-c.inc"

typedef ZIConnection Lab__Zhinst;

static void
handle_error(ZIResult_enum number, const char *function)
{
  if (number == ZI_INFO_SUCCESS)
    return;
  
  char *buffer;
  ziAPIGetError(number, &buffer, NULL);
  croak("Error in %s: %s\nnumber: %d\n", function, buffer, number);
}

MODULE = Lab::Zhinst		PACKAGE = Lab::Zhinst		

INCLUDE: const-xs.inc



TYPEMAP: <<HERE
Lab::Zhinst T_PTROBJ
HERE



Lab::Zhinst
new(const char *class, const char *hostname, U16 port)
CODE:
    ZIConnection connection;
    handle_error(ziAPIInit(&connection), "ziAPIInit");
    handle_error(ziAPIConnectEx(connection, hostname, port, ZI_API_VERSION_5, NULL), "ziAPIConnectEx");
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
    size_t buffer_len = 1000;
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
    size_t nodes_len = 100;

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