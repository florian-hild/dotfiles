--------------------------------------------------------------------------------
-- Author     : Florian Hild
-- Created    : 24-05-2024
-- Description: Displays privileges for a specified table.
--------------------------------------------------------------------------------

SET PAGESIZE 2000
SET LINESIZE 250
-- disable the display of substitution variable values before execution
SET VERIFY OFF

COL TABLE_NAME FORMAT A40
COL OWNER FORMAT A20
COL GRANTEE FORMAT A20
COL PRIVILEGE FORMAT A25
COL TYPE FORMAT A10
COL GRANTOR FORMAT A20
COL GRANTABLE FORMAT A10

ACCEPT table_name CHAR PROMPT 'Please enter table name: ';

SELECT
    OWNER,
    TABLE_NAME,
    GRANTEE,
    PRIVILEGE,
    TYPE,
    GRANTABLE,
    GRANTOR
FROM DBA_TAB_PRIVS
WHERE TABLE_NAME = TRIM(UPPER('&table_name'))
ORDER BY OWNER, TABLE_NAME, GRANTEE, TYPE, PRIVILEGE ASC;

SET VERIFY ON
