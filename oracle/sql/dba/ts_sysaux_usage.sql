--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 17-06-2024
-- Description: Show which objects are using most space
--              https://www.markusdba.de/2021/04/06/mein-sysaux-tablespace-waechst-und-waechst-was-soll-kann-ich-tun/
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

column occupant_name format a25
column occupant_desc format a53
column USED_MB       format 99999.99

SELECT OCCUPANT_NAME,OCCUPANT_DESC, SPACE_USAGE_KBYTES USED_KB, SPACE_USAGE_KBYTES  / 1024 "USED_MB"
  FROM V$SYSAUX_OCCUPANTS
  WHERE SPACE_USAGE_KBYTES >= 1000
  ORDER BY SPACE_USAGE_KBYTES desc;

