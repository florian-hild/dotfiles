--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Generate disable and enable scripts for all enabled foreign
--              key (referential) constraints. FK constraints are what block
--              TRUNCATE / DATA_ONLY loads. Leave owner blank for current user.
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
SELECT '$HOME/constraints_disable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname FROM dual;

col spoolname_ena new_value spoolname_ena
SELECT '$HOME/constraints_enable_' || to_char(sysdate, 'yyyy-mm-dd_hh24-mi-ss') || '.sql' spoolname_ena FROM dual;

-- DISABLE all currently enabled foreign keys
SPOOL '&spoolname'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" DISABLE CONSTRAINT "' || constraint_name || '";'
  FROM dba_constraints
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND constraint_type = 'R'
    AND status = 'ENABLED'
  ORDER BY owner, table_name, constraint_name;
PROMPT EXIT
SPOOL off

-- ENABLE script (captured while still enabled). NOVALIDATE = fast; data comes
-- from a consistent source. Change to ENABLE VALIDATE if you must re-verify.
SPOOL '&spoolname_ena'
PROMPT WHENEVER SQLERROR CONTINUE
SELECT 'ALTER TABLE "' || owner || '"."' || table_name || '" ENABLE NOVALIDATE CONSTRAINT "' || constraint_name || '";'
  FROM dba_constraints
  WHERE (('&owners' IS NULL AND owner = user)
         OR INSTR(',' || REPLACE(UPPER('&owners'), ' ') || ',',
                  ',' || owner || ',') > 0)
    AND constraint_type = 'R'
    AND status = 'ENABLED'
  ORDER BY owner, table_name, constraint_name;
PROMPT EXIT
SPOOL off

select '&spoolname' from DUAL;
select '&spoolname_ena' from DUAL;
