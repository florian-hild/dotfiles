--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col WAAGENNUMMER format 99
col WAAGETERMINAL format a10
col WAAGETERMINALBESCHREIBUNG format a30
col WAAGETERMINALTYP format a15
col BETRIEBSSTATUS format 99
col ARBEITSPLATZ format a20
col IP_ADRESSE format a20
col IP_PORT format a10

SELECT
  WAAGENNUMMER,
  WAAGETERMINAL,
  WAAGETERMINALBESCHREIBUNG,
  IP_ADRESSE,
  IP_PORT,
  ARBEITSPLATZ,
  WAAGETERMINALTYP,
  BETRIEBSSTATUS
FROM waageterminal
ORDER BY WAAGENNUMMER, WAAGETERMINAL, ARBEITSPLATZ;
