-- login.sql
--
-- $Id: login.sql,v 1.2 2010/03/04 22:40:56 oracle Exp $
--
-- SQL*Plus environment configuration file.
-- 
-- David Robillard, April 4th, 2007.

-- Display the current USER and ORACLE_SID at the SQL prompt.
-- For Oracle 10g and above:
set sqlprompt "_USER'@'_CONNECT_IDENTIFIER _PRIVILEGE> "

-- Set a longer linesize and pagesize.
-- Normal US Letter is pagesize 66 and linesize 80.
set linesize 155 pagesize 50;

-- Set some frequently used column format.
col file_name for a55;
col name for a30;
col segment_name for a55;
col value for a50;

-- Configure the SHOW PARAMETER output.
col type for a15;
col value_col_plus_show_param for a85 heading VALUE;

-- Change the edit filename.
set editfile "sqlplus.edit"

-- Use vi(1) for command line edition.
define _EDITOR=vi

-- EOF