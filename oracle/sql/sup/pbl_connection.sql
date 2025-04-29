--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description:
--------------------------------------------------------------------------------

set pagesize 2000
set linesize 250

col DCP_NAME            format a15
col DCP_DIAL_NAME       format a10
col DCP_ENABLED         format 9
col DCP_X_DIRECTION_TXT format a10
col DCP_X_MODE_TXT      format a10
col DCP_LOCAL_IP       format a15
col DCP_LOCAL_PORT      format 999999
col DCP_REMOTE_IP      format a15
col DCP_REMOTE_PORT     format 999999

SELECT
  DCP_NAME,
  DCP_DIAL_NAME,
  DCP_ENABLED,
  DCP_X_DIRECTION_TXT,
  DCP_X_MODE_TXT,
  DCP_LOCAL_IP,
  DCP_LOCAL_PORT,
  DCP_REMOTE_IP,
  DCP_REMOTE_PORT
FROM DIAL_CONNECTION_PHYSICAL
ORDER BY DCP_ID;
