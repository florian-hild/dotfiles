--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col BELEGART         format a12
col DRUCKART         format a7
col DRUCKERQUEUE_TYP format a16

select BELEGART,DRUCKART,DRUCKERQUEUE_TYP,MODDAT
  FROM belegartzuordnung
  WHERE DRUCKART != 'K'
  ORDER BY DRUCKART,DRUCKERQUEUE_TYP,BELEGART;
