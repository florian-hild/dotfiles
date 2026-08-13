--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate disable and enable scripts for all enabled table/view
--              triggers. Business-logic triggers must not fire during a bulk
--              data load. Leave owner blank for current user.
--------------------------------------------------------------------------------

set echo off
set term on
set verify off
set feedback off
set heading off
set pagesize 0
set linesize 32767
set trimspool on
set wrap off

accept owners char prompt 'Enter owner(s) comma-separated (leave blank for current user): '

whenever sqlerror exit failure

col spoolname new_value spoolname
SELECT '$HOME/triggers_disable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

col spoolname_ena new_value spoolname_ena
SELECT '$HOME/triggers_enable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname_ena FROM dual;

-- DISABLE all currently enabled table/view triggers
SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT 'ALTER TRIGGER "' || owner || '"."' || trigger_name || '" DISABLE;'
  FROM dba_triggers
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND status = 'ENABLED'
    AND base_object_type IN ('TABLE', 'VIEW')
  ORDER BY owner, trigger_name;
PROMPT EXIT
SPOOL off

-- ENABLE script (captured while still enabled)
SPOOL '&spoolname_ena'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT 'ALTER TRIGGER "' || owner || '"."' || trigger_name || '" ENABLE;'
  FROM dba_triggers
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND status = 'ENABLED'
    AND base_object_type IN ('TABLE', 'VIEW')
  ORDER BY owner, trigger_name;
PROMPT EXIT
SPOOL off

select '&spoolname' from DUAL;
select '&spoolname_ena' from DUAL;
