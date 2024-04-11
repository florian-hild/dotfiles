/*
Check /etc/services files resolution
service_name --> port

F. Hild 2022-11-07

compiles with: gcc check_services.c -o check_services
*/

/* include libraries */
#include <netdb.h>
#include <stdio.h>
#include <netinet/in.h>

/* variable declarations */
const char *name = "ssh";
const char *proto = "tcp";

int main() {
  /*
  Example from https://linux.die.net/man/3/getservbyname
  struct servent *getservbyname(const char *name, const char *proto);
  network byte
  */
  struct servent *sptr = getservbyname( name, proto );

  /*
  Print s_port from struct and convert network byte to port
  https://www.gnu.org/software/libc/manual/html_node/Byte-Order.html
  */
  printf( "Port: %i\n", ntohs( sptr->s_port ) );
}

