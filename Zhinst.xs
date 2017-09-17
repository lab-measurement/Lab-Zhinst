#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <ziAPI.h>

#include "const-c.inc"

typedef ZIConnection Lab__Zhinst;

#define ALLOC_START_SIZE 100

# define ZHINST_UNUSED __attribute__((__unused__))

static HV *
demod_sample_to_hash(pTHX_ ZIDemodSample *sample)
{
  HV *hash = newHV();
  hv_stores(hash, "timeStamp", newSVuv(sample->timeStamp));
  hv_stores(hash, "x",         newSVnv(sample->x));
  hv_stores(hash, "y",         newSVnv(sample->y));
  hv_stores(hash, "frequency", newSVnv(sample->frequency));
  hv_stores(hash, "phase",     newSVnv(sample->phase));
  hv_stores(hash, "dioBits",   newSVuv(sample->dioBits));
  hv_stores(hash, "trigger",   newSVuv(sample->trigger));
  hv_stores(hash, "auxIn0",    newSVnv(sample->auxIn0));
  hv_stores(hash, "auxIn1",    newSVnv(sample->auxIn1));
  return newRV_noinc((SV *) hash);
}

static HV *
dio_sample_to_hash(pTHX_ ZIDIOSample *sample)
{
  HV *hash = newHV();
  hv_stores(hash, "timeStamp", newSVuv(sample->timeStamp));
  hv_stores(hash, "bits",      newSVuv(sample->bits));
  hv_stores(hash, "reserved",  newSVuv(sample->reserved));
  return newRV_noinc((SV *) hash);        
}

static HV *
aux_in_sample_to_hash(pTHX_ ZIAuxInSample *sample)
{
  HV *hash = newHV();
  hv_stores(hash, "timeStamp", newSVuv(sample->timeStamp));
  hv_stores(hash, "ch0",       newSVnv(sample->ch0));
  hv_stores(hash, "ch1",       newSVnv(sample->ch1));
  return newRV_noinc((SV *) hash);
}

static SV *
pointer_object(pTHX_ const char *class_name, void *pv)
{
    SV *rv = newSV(0);
    sv_setref_pv(rv, class_name, pv);
    return rv;
}

MODULE = Lab::Zhinst		PACKAGE = Lab::Zhinst		PREFIX = ziAPI

INCLUDE: const-xs.inc


void
ziAPIInit(const char *class, const char *hostname, U16 port)
PPCODE:
    ZIConnection conn;
    int rv = ziAPIInit(&conn);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHs(pointer_object(aTHX_ class, conn));


void
DESTROY(Lab::Zhinst conn)
CODE:
    ziAPIDestroy(conn);


void
ziAPIConnect(Lab::Zhinst conn, const char *hostname, uint16_t port)
PPCODE:
    int rv = ziAPIConnect(conn, hostname, port);
    mXPUSHi(rv);


void
ziAPIDisconnect(Lab::Zhinst conn)
PPCODE:
    int rv = ziAPIDisconnect(conn);
    mXPUSHi(rv);



void
ziAPIListImplementations()
PPCODE:
    size_t buffer_len = 100;
    char *buffer;
    Newx(buffer, buffer_len, char);
    int rv = ziAPIListImplementations(buffer, buffer_len);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHp(buffer, strlen(buffer));
    Safefree(buffer);


void
ziAPIGetConnectionAPILevel(Lab::Zhinst conn)
PPCODE:
    ZIAPIVersion_enum version;
    int rv = ziAPIGetConnectionAPILevel(conn, &version);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHi(version);


void
ziAPIListNodes(Lab::Zhinst conn, const char *path, uint32_t bufferSize, uint32_t flags)
PPCODE:
    char *nodes;
    Newx(nodes, bufferSize, char);
    int rv = ziAPIListNodes(conn, path, nodes, bufferSize, flags);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHp(nodes, strlen(nodes));
    Safefree(nodes);


void
ziAPIGetValueD(Lab::Zhinst conn, const char *path)
PPCODE:
    double result;
    int rv = ziAPIGetValueD(conn, path, &result);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHn(result);

void
ziAPIGetValueI(Lab::Zhinst conn, const char *path)
PPCODE:
    IV result;
    int rv = ziAPIGetValueI(conn, path, &result);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHi(result);


void
ziAPIGetDemodSample(Lab::Zhinst conn, const char *path)
PPCODE:
    ZIDemodSample sample;
    int rv = ziAPIGetDemodSample(conn, path, &sample);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHs(demod_sample_to_hash(aTHX_ &sample));


void
ziAPIGetDIOSample(Lab::Zhinst conn, const char *path)
PPCODE:
    ZIDIOSample sample;
    int rv = ziAPIGetDIOSample(conn, path, &sample);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHs(dio_sample_to_hash(aTHX_ &sample));

void
ziAPIGetAuxInSample(Lab::Zhinst conn, const char *path)
PPCODE:
    ZIAuxInSample sample;
    int rv = ziAPIGetAuxInSample(conn, path, &sample);
    mXPUSHi(rv);
    if (rv == 0)
        mXPUSHs(aux_in_sample_to_hash(aTHX_ &sample));



void
ziAPIGetValueB(Lab::Zhinst conn, const char *path, unsigned int bufferSize)
PPCODE:
    char *buffer;
    Newx(buffer, bufferSize, char);
    unsigned int length;
    int rv = ziAPIGetValueB(conn, path, buffer, &length, bufferSize);
    mXPUSHi(rv);
    if (rv == 0) {
        mXPUSH
    while (1) {
        Renew(result, result_avail, char);
        int rv = ziAPIGetValueB(conn, path, (unsigned char*) result, &length,
                                result_avail);
        if (rv == 0)
            break;
        if (rv != ZI_ERROR_LENGTH)
          {
            Safefree(result);
            handle_error(aTHX_ conn, rv, "ziAPIGetValueB");
          }
        result_avail = (result_avail * 3) / 2;
    }
    RETVAL = newSVpvn(result, length);
    Safefree(result);
OUTPUT:
    RETVAL


void
ziAPISetValueD(Lab::Zhinst conn, const char *path, double value)
PPCODE:
    int rv = ziAPISetValueD(conn, path, value);
    handle_error(aTHX_ conn, rv, "ziAPISetValueD");

void
ziAPISetValueI(Lab::Zhinst conn, const char *path, IV value)
PPCODE:
    int rv = ziAPISetValueI(conn, path, value);
    handle_error(aTHX_ conn, rv, "ziAPISetValueI");

void
ziAPISetValueB(Lab::Zhinst conn, const char *path, SV *value)
PPCODE:
    if (!SvOK(value)) {
       croak("value is not a valid scalar");
    }
    const char *bytes;
    STRLEN len;
    bytes = SvPV(value, len);
    int rv = ziAPISetValueB(conn, path, (unsigned char *) bytes, len);
    handle_error(aTHX_ conn, rv, "ziAPISetValueB");


double
ziAPISyncSetValueD(Lab::Zhinst conn, const char *path, double value)
PPCODE:
    double result = value;
    int rv = ziAPISyncSetValueD(conn, path, &result);
    handle_error(aTHX_ conn, rv, "ziAPISyncSetValueD");
    RETVAL = result;
OUTPUT:
    RETVAL

IV
ziAPISyncSetValueI(Lab::Zhinst conn, const char *path, IV value)
PPCODE:
    IV result = value;
    int rv = ziAPISyncSetValueI(conn, path, &result);
    handle_error(aTHX_ conn, rv, "ziAPISyncSetValueI");
    RETVAL = result;
OUTPUT:
    RETVAL

SV *
ziAPISyncSetValueB(Lab::Zhinst conn, const char *path, SV *value)
PPCODE:
    if (!SvOK(value)) {
       croak("value is not a valid scalar");
    }
    const char *original;
    STRLEN len;
    original = SvPV(value, len);

    char *new_string;
    New(0, new_string, len, char);
    Copy(original, new_string, len, char);
    int rv = ziAPISyncSetValueB(conn,  path, (uint8_t *) new_string,
                                (uint32_t *) &len, len);
    handle_error(aTHX_ conn, rv, "ziAPISyncSetValueB");
    RETVAL = newSVpvn(new_string, len);
    Safefree(new_string);
OUTPUT:
    RETVAL


void
ziAPISync(Lab::Zhinst conn)
PPCODE:
    int rv = ziAPISync(conn);
    handle_error(aTHX_ conn, rv, "ziAPISync");

void
ziAPIEchoDevice(Lab::Zhinst conn, const char *device_serial)
PPCODE:
    int rv = ziAPIEchoDevice(conn, device_serial);
    handle_error(aTHX_ conn, rv, "ziAPIEchoDevice");

void
ziAPISetDebugLevel(I32 level)

void
ziAPIWriteDebugLog(I32 level, const char *message)


const char *
ziAPIDiscoveryFind(Lab::Zhinst conn, const char *device_address)
PPCODE:
    const char *device_id;
    int rv = ziAPIDiscoveryFind(conn, device_address, &device_id);
    handle_error(aTHX_ conn, rv, "ziAPIDiscoveryFind");
    RETVAL = device_id;
OUTPUT:
    RETVAL


const char *
ziAPIDiscoveryGet(Lab::Zhinst conn, const char *device_id)
PPCODE:
    const char *props_json;
    int rv = ziAPIDiscoveryGet(conn, device_id, &props_json);
    handle_error(aTHX_ conn, rv, "ziAPIDiscoveryGet");
    RETVAL = props_json;
OUTPUT:
    RETVAL
