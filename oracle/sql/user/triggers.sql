--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col TRIGGER_NAME     format a40
col STATUS           format a8
col BASE_OBJECT_TYPE format a8
col TABLE_NAME       format a30
col TRIGGER_TYPE     format a15
col TRIGGERING_EVENT format a30

SELECT TRIGGER_NAME,STATUS,BASE_OBJECT_TYPE,TABLE_NAME,TRIGGER_TYPE,TRIGGERING_EVENT
  FROM user_triggers
  ORDER BY TRIGGER_NAME,TABLE_NAME ASC;
