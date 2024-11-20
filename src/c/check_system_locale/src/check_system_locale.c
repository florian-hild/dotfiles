/*
Check system locale interpretation

F. Hild 2024-11-20

See: man -s 3 setlocale
compiles and link with: gcc -o check_system_locale check_system_locale.c -Wall
*/

/* include libraries */
#include <locale.h>
#include <stdio.h>
#include <string.h>

int main() {
  printf("Lokale Settings: %s\n", setlocale ( LC_NUMERIC, "" ));
  printf("Dezimaltrenner: %c\n", localeconv()->decimal_point[0]);
}

