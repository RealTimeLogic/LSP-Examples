/*
  The C++ Code Companion Example for the article:
  https://realtimelogic.com/articles/Modern-Approach-to-Embedding-a-Web-Server-in-a-Device
  GitHub:
  https://github.com/RealTimeLogic/LSP-Examples/tree/master/SMQ-examples/LightSwitch-And-LightBulb-App

  See also the C version bulb.c

  This example uses the SMQ protocol: https://realtimelogic.com/ba/doc/en/SMQ.html

  The accompanying JavaScript code "../www/ switch.html" uses JSON
  encoded SMQ messages. Using JSON with C/C++ can be unwieldy, but we
  provide a JSON C library that simplifies using JSON.

  This example can be compiled with or without using the JSON
  library. The JSON used in this example is very basic and can easily
  be hand crafted. However, more advanced design will benefit from
  using the JSON library.

  See the JSON tutorial for details:
  https://realtimelogic.com/ba/doc/en/C/reference/html/md_en_C_md_JSON.html#JIntroduction

  See the code section with #if USE_JSON ... #else ... #endif below.
*/


/* Broker URL:
 * The code connects to the online SMQ test broker. You can run a
 * local broker, but you must also change the URL in the switch viewer
 * "../www/switch.html".
 *
 */
#if 1
#define SMQ_DOMAIN "simplemq.com"
#else
#define SMQ_DOMAIN "127.0.0.1"
#endif
#define SMQ_URL "http://" SMQ_DOMAIN "/smq.lsp"

/* Defaults to not using JSON */
#ifndef USE_JSON
#define USE_JSON 0
#endif

#include <SMQ.h>
#if USE_JSON
#include <JDecoder.h>
#include <JEncoder.h>
#endif
#include <stdio.h>

/* The SMQ client must provide a unique ID when connecting to the
   broker. This will typically be the Ethernet MAC address for an
   embedded IoT device. The ID is usually a locally hard coded ID when
   the SMQ client is used as explained on the following page with option 2:
   https://realtimelogic.com/ba/doc/?url=/SMQ-Use-Cases.html#RtlUI
*/
static const char* getUniqueID()
{
   return "Bulb: " __DATE__ __TIME__;
}


#if USE_JSON

/* Used by JEncoder -> BufPrint in function "pubSwitchOnOff" below.
   This function would normally send the message, but in this example,
   the callback is used exclusively for error checking. Variable
   sizeRequired will be greater than zero if "char buf[15]" below is
   too small. See the Minnow Server Reference Example for how to send
   data using this callback.
   https://github.com/RealTimeLogic/MinnowServer/blob/master/example/src/MinnowRefPlatMain.c
*/
static int checkBufOverflow(BufPrint* bp, int sizeRequired)
{
   (void)bp;
   assert(sizeRequired == 0);
   return 0;
}


/* Publish switch on/off JSON message using JEncoder.
   JEncoder: https://realtimelogic.com/ba/doc/en/C/reference/html/structJEncoder.html
   SMQ: https://realtimelogic.com/ba/doc/en/C/reference/html/structSMQ.html
 */
static void pubSwitchOnOff(SMQ& smq, BaBool bulbOn, U32 tid, U32 subtid)
{
   char buf[15];
   JErr err;
   BufPrint bp(NULL, checkBufOverflow);
   BufPrint_setBuf(&bp, buf, sizeof(buf));
   JEncoder encoder(&err, &bp);
   encoder.set("{b}", "on", bulbOn);
   encoder.flush(); /* Function checkBufOverflow gets called */
   smq.publish(bp.buf,bp.cursor,tid,subtid);
}

#else /* Not: USE_JSON */

/* Publish manually crafted JSON message for turning switch on or off.
 */
static void pubSwitchOnOff(SMQ& smq, BaBool bulbOn, U32 tid, U32 subtid)
{
   static const char* onJson="{\"on\":true}";
   static const char* offJson="{\"on\":false}";
   const char* json = bulbOn ? onJson : offJson;
   smq.publish(json,strlen(json),tid,subtid);
}

#endif /* USE_JSON */


/* The complete light bulb implementation.
   This is the C code implementation for the JavaScript powered light bulb:
   "../www/bulb.html" or
   https://github.com/RealTimeLogic/LSP-Examples/blob/master/SMQ-examples/LightSwitch-And-LightBulb-App/www/bulb.html
   Make sure to compare the JavaScript implementation with the following C code.
   SMQ C Code API:
   https://realtimelogic.com/ba/doc/en/C/reference/html/group__SMQClient.html
 */
static void bulb()
{
   U8 smqBuf[256];
   SMQ smq(smqBuf,sizeof(smqBuf));
   U32 helloTid,setTid,setSubTid; /* Topic and sub topic IDs used in this example */
   U8* msg;
   BaBool bulbOn=FALSE;

#if USE_JSON
   char maxMembN[4]; /* Buffer for holding temporary JSON member name */
   /* JSON Parser Value (JVal) Factory */
   JParserValFact pv(AllocatorIntf::getDefault(), AllocatorIntf::getDefault());
   /* JSON parser */
   JParser parser(&pv, maxMembN, sizeof(maxMembN), AllocatorIntf_getDefault(),0);
   JErr jerr;
#endif

   if(smq.init(SMQ_URL, 0) < 0)
   {  /* Error codes:
         https://realtimelogic.com/ba/doc/en/C/reference/html/group__SMQClientErrorCodes.html#SMQClientErrorCodes
      */
      printf("Cannot establish connection, status: %d\n", smq.status);
      return;
   }
   if(smq.connect(getUniqueID(), strlen(getUniqueID()),
                  0, 0, /* credentials */
                  0, 0 /* info */))
   {
      printf("SMQ Connect failed, status: %d\n", smq.status);
      return;
   }

   printf("Light bulb connected\n");

   /* Resolve topic IDs (tids) for the following 3; We only subscribe to one topic.
      See Topic and sub topic names for details:
      https://realtimelogic.com/ba/doc/?url=SMQ.html#TopicNames
    */
   smq.subscribe( "/switchui/hello");
   smq.create( "/switch/set");
   smq.createsub( "/switch/set");
   /* Simplified error management below: */
   if(SMQ_SUBACK != smq.getMessage(&msg)) return; /* failed */
   helloTid=smq.ptid; /* Topic "/switchui/hello" */
   if(SMQ_CREATEACK != smq.getMessage(&msg)) return; /* failed */
   setTid=smq.ptid; /* Topic "/switch/set" */
   if(SMQ_CREATESUBACK != smq.getMessage(&msg)) return; /* failed */
   setSubTid=smq.ptid; /* Sub-topic "/switch/set" */
   /* Inform all connected switch viewers (switch.html) that we just
    * started; publish One-2-many.
    */
   pubSwitchOnOff(smq,bulbOn,setTid,0);
   for(;;)
   {
      U8* msg;
      /* Wait for the next message */
      int len =  smq.getMessage(&msg);
      if(len < 0) /* We received a control message or an error code */
      {
         if(len == SMQE_TIMEOUT)
            continue; /* Timeout not used */
         /* We are not expecting any control messages */
         printf("Rec Error: %d.\n",smq.status);
         return;
      }
      /* If topic == "/switchui/hello" i.e. a new switch viewer (switch.html) */
      if(smq.tid == helloTid)
      {
         printf("A new switch with tid %u connected\n", smq.ptid);
         /* Send state back to sender; publish one-2-one */
         pubSwitchOnOff(smq,bulbOn,smq.ptid,setSubTid);
      }
      /* If topic == "self" (one-to-one communication). An SMQ client
       * is auto subscribed to topic "self". Compare this code with
       * the JavaScript implementation in bulb.html.
       */
      else if(smq.tid == smq.clientTid)
      {
         /* Our topic design uses only one sub-topic: "/switch/set" */
         assert(smq.subtid == setSubTid);
#if USE_JSON
         if(parser.parse(msg, len) <= 0 ||
            (pv.getFirstVal()->get(&jerr, "{b}", "on", &bulbOn),
             jerr.isError()))
         {
            printf("JSON error\n");
            return;
         }
#else
         /* Simplified JSON decoding */
         bulbOn = strncmp("{\"on\":true}", (char*)msg, 11) == 0 ? TRUE : FALSE;
#endif
         printf("Switch with tid %u set bulb %s\n", smq.ptid, bulbOn ? "on" : "off");
         /* Inform all connected switch viewers (switch.html); publish one-2-many. */
         pubSwitchOnOff(smq,bulbOn,setTid,0);
      }
      else
         return; /* Simplified  error management;  Unknown SMQ topic (tid) */
   }
}



int main()
{
#ifdef _WIN32
   WSADATA wsaData;
   /* Windows specific: Start winsock library */
    WSAStartup(MAKEWORD(1,1), &wsaData);
#endif
#if USE_JSON
    printf("Using JSON library\n");
#else
    printf("Using manually crafted JSON\n");
#endif

   printf("%s",
           "Control the bulb using:\n"
           "https://realtimelogic.com/blogmedia/ModernApproachEmbeddedWebServer/switch.html\n");



   bulb();
   return 0;
}
