--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250
alter session set nls_date_format='DD-MON-YYYY HH24:MI:SS';

col DRUCKERNAME      format a20
col DRUCKERQUEUE     format a20
col DRUCKERQUEUE_TYP format a16

select DRUCKERNAME,DRUCKERQUEUE,DRUCKERQUEUE_TYP,MODDAT
  FROM druckerqueue
  ORDER BY DRUCKERNAME,DRUCKERQUEUE_TYP,DRUCKERQUEUE,MODDAT;
