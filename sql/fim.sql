SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: finish_run_job(bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION finish_run_job(in_key bigint, in_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
  BEGIN
    UPDATE jobs SET date_end = in_date WHERE key = in_key;
  END
  $$;


ALTER FUNCTION public.finish_run_job(in_key bigint, in_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: insert_aide_object(character varying, character varying, character varying, numeric, character varying, numeric, numeric, character varying, character varying, character varying, character varying, character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION insert_aide_object(in_host character varying, in_proc character varying, in_name character varying, in_attr numeric, in_perm character varying, in_uid numeric, in_gid numeric, in_md5 character varying, in_sha256 character varying, in_acl character varying, in_xattr character varying, in_selinux character varying, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.aide_objects (report_host, report_proc, name,
    attr, perm, uid, gid, md5, sha256, acl,
    xattr, selinux, first_date, last_date)
  VALUES (in_host, in_proc, in_name, in_attr, in_perm, in_uid,
    in_gid, in_md5, in_sha256, in_acl, in_xattr, in_selinux,
    report_date, report_date);
END
$$;


ALTER FUNCTION public.insert_aide_object(in_host character varying, in_proc character varying, in_name character varying, in_attr numeric, in_perm character varying, in_uid numeric, in_gid numeric, in_md5 character varying, in_sha256 character varying, in_acl character varying, in_xattr character varying, in_selinux character varying, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: insert_rpm_file_object(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION insert_rpm_file_object(in_host character varying, in_proc character varying, in_name character varying, in_fileclass character varying, in_rpmname character varying, in_ver_rel_arch character varying, in_fileusername character varying, in_filegroupname character varying, in_filedevices character varying, in_sha256 character varying, in_perm character varying, in_fileverifyflags character varying, in_uid numeric, in_gid numeric, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.rpm_file_objects (report_host, report_proc, name, fileclass,
    rpmname, ver_rel_arch, fileusername, filegroupname, filedevices, sha256, perm,
    fileverifyflags, uid, gid, first_date, last_date)
  VALUES (in_host, in_proc, in_name, in_fileclass, in_rpmname, in_ver_rel_arch,
    in_fileusername, in_filegroupname, in_filedevices, in_sha256, in_perm,
    in_fileverifyflags, in_uid, in_gid, report_date, report_date);
END
$$;


ALTER FUNCTION public.insert_rpm_file_object(in_host character varying, in_proc character varying, in_name character varying, in_fileclass character varying, in_rpmname character varying, in_ver_rel_arch character varying, in_fileusername character varying, in_filegroupname character varying, in_filedevices character varying, in_sha256 character varying, in_perm character varying, in_fileverifyflags character varying, in_uid numeric, in_gid numeric, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: insert_rpm_package_object(character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, timestamp without time zone, character varying, character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION insert_rpm_package_object(in_host character varying, in_proc character varying, in_name character varying, in_ver_rel_arch character varying, in_version character varying, in_release character varying, in_arch character varying, in_installtime numeric, in_sha1header character varying, in_siggpg_date timestamp without time zone, in_siggpg_key character varying, in_sigmd5 character varying, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.rpm_package_objects (
    report_host, report_proc, name, ver_rel_arch, version, release, arch,
    installtime, sha1header, siggpg_date,
    siggpg_key, sigmd5, first_date, last_date
    )
    VALUES (
    in_host, in_proc, in_name, in_ver_rel_arch, in_version, in_release, in_arch,
    in_installtime, in_sha1header, in_siggpg_date,
    in_siggpg_key, in_sigmd5, report_date, report_date);
END
$$;


ALTER FUNCTION public.insert_rpm_package_object(in_host character varying, in_proc character varying, in_name character varying, in_ver_rel_arch character varying, in_version character varying, in_release character varying, in_arch character varying, in_installtime numeric, in_sha1header character varying, in_siggpg_date timestamp without time zone, in_siggpg_key character varying, in_sigmd5 character varying, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: insert_run_job(character varying, inet, character varying, character varying, character varying, timestamp without time zone, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION insert_run_job(in_job character varying, in_ip inet, in_user character varying, in_host character varying, in_proc character varying, in_rptdate timestamp without time zone, in_start timestamp without time zone, in_end timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  table_name text;
  sql text;
BEGIN
  SELECT 'jobs_'
    || EXTRACT(YEAR FROM in_start)::text
    || '_'
    || EXTRACT(MONTH FROM in_start)::text
    INTO table_name;
  EXECUTE format('INSERT INTO ' || table_name || ' (job_name, insert_ip,
    insert_user, report_host, report_proc, report_date, date_start, date_end)
    VALUES (' || quote_literal(in_job) || ',' || quote_literal(in_ip) || ','
    || quote_literal(in_user) || ',' || quote_literal(in_host) || ','
    || quote_literal(in_proc) || ', NULL,' || quote_literal(in_start) || ', NULL);');
END
$$;


ALTER FUNCTION public.insert_run_job(in_job character varying, in_ip inet, in_user character varying, in_host character varying, in_proc character varying, in_rptdate timestamp without time zone, in_start timestamp without time zone, in_end timestamp without time zone) OWNER TO fim_database;

--
-- Name: jobs_auto_partition(timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION jobs_auto_partition(in_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  junk_record pg_tables%ROWTYPE;
  table_name text;
  this_month timestamp without time zone;
  next_month timestamp without time zone;
BEGIN
  SELECT 'jobs_'
    || EXTRACT(YEAR FROM in_date)::text
    || '_'
    || EXTRACT(MONTH FROM in_date)::text
    INTO table_name;
  SELECT FROM pg_tables INTO junk_record where tablename = table_name;
  IF NOT FOUND THEN
    SELECT date_trunc('MONTH', in_date)::timestamp without time zone INTO this_month;
    SELECT date_trunc('MONTH', in_date + interval '1 month')::timestamp without time zone INTO next_month;
    --EXECUTE format('CREATE TABLE ' || table_name || ' ( CHECK (( report_date >= '''
    --  || this_month || ''' AND report_date < ''' || next_month || ''' ) OR report_date is NULL) INHERITS (jobs);');
    EXECUTE format('CREATE TABLE ' || table_name || ' () INHERITS (jobs);');
    EXECUTE format('CREATE INDEX ' || table_name || '_key_idx ON ' || table_name || ' USING btree (key);');
    EXECUTE format('CREATE INDEX ' || table_name || '_report_host_idx ON ' || table_name || ' USING btree (report_host);');
    EXECUTE format('CREATE INDEX ' || table_name || '_report_proc_idx ON ' || table_name || ' USING btree (report_proc);');
    EXECUTE format('CREATE INDEX ' || table_name || '_date_start_idx ON ' || table_name || ' USING btree (date_start);');
    EXECUTE format('REVOKE ALL ON TABLE ' || table_name || ' FROM PUBLIC;');
    EXECUTE format('REVOKE ALL ON TABLE ' || table_name || ' FROM fim_database;');
    EXECUTE format('GRANT ALL ON TABLE ' || table_name || ' TO fim_database;');
    EXECUTE format('GRANT ALL ON TABLE ' || table_name || ' TO postgres;');
    EXECUTE format('GRANT SELECT ON TABLE ' || table_name || ' TO fim_users;');
    EXECUTE format('GRANT SELECT,INSERT,UPDATE ON TABLE ' || table_name || ' TO fim_query_tables;');
  END IF;
END
$$;


ALTER FUNCTION public.jobs_auto_partition(in_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: set_correlated_aide(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_correlated_aide(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE aide_objects SET correlated = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_correlated_aide(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: set_correlated_rpm_package(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_correlated_rpm_package(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE rpm_package_objects SET correlated = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_correlated_rpm_package(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: set_removed_aide(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_removed_aide(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE aide_objects SET removed = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_removed_aide(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: set_removed_rpm_package(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_removed_rpm_package(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE rpm_package_objects SET removed = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_removed_rpm_package(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: set_reviewed_aide(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_reviewed_aide(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE aide_objects SET reviewed = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_reviewed_aide(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: set_reviewed_rpm_package(bigint); Type: FUNCTION; Schema: public; Owner: fim_query_tables
--

CREATE FUNCTION set_reviewed_rpm_package(in_key bigint) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE rpm_package_objects SET reviewed = 'true' where key = in_key;
END
$$;


ALTER FUNCTION public.set_reviewed_rpm_package(in_key bigint) OWNER TO fim_query_tables;

--
-- Name: update_aide_object(bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION update_aide_object(in_key bigint, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.aide_objects SET last_date = report_date WHERE key = in_key;
END
$$;


ALTER FUNCTION public.update_aide_object(in_key bigint, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: update_rpm_file_object(bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION update_rpm_file_object(in_key bigint, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.rpm_file_objects SET last_date = report_date WHERE key = in_key;
END
$$;


ALTER FUNCTION public.update_rpm_file_object(in_key bigint, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: update_rpm_package_object(bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION update_rpm_package_object(in_key bigint, report_date timestamp without time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  UPDATE public.rpm_package_objects SET last_date = report_date WHERE key = in_key;
END
$$;


ALTER FUNCTION public.update_rpm_package_object(in_key bigint, report_date timestamp without time zone) OWNER TO fim_database;

--
-- Name: upsert_aide_object(character varying, character varying, character varying, numeric, character varying, numeric, numeric, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION upsert_aide_object(in_host character varying, in_proc character varying, in_name character varying, in_attr numeric, in_perm character varying, in_uid numeric, in_gid numeric, in_md5 character varying, in_sha256 character varying, in_acl character varying, in_xattr character varying, in_selinux character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  report_date TIMESTAMP WITHOUT TIME ZONE;
  last_record public.aide_objects%ROWTYPE;
  object_row public.aide_objects%ROWTYPE;
BEGIN
  SELECT INTO report_date backend_start::TIMESTAMP WITHOUT TIME ZONE FROM pg_stat_activity
    WHERE usename = "session_user"() AND client_addr = inet_client_addr()
    AND client_port = inet_client_port();
  SELECT * INTO last_record FROM public.aide_objects
    WHERE report_host = in_host AND report_proc = in_proc AND name = in_name
    AND attr IS NOT DISTINCT FROM in_attr
    AND perm IS NOT DISTINCT FROM in_perm
    AND uid IS NOT DISTINCT FROM in_uid
    AND gid IS NOT DISTINCT FROM in_gid
    AND md5 IS NOT DISTINCT FROM in_md5
    AND sha256 IS NOT DISTINCT FROM in_sha256
    AND acl IS NOT DISTINCT FROM in_acl
    AND xattr IS NOT DISTINCT FROM in_xattr
    AND selinux IS NOT DISTINCT FROM in_selinux
    AND correlated = 'f'
    ORDER BY last_date LIMIT 1;
  IF NOT FOUND THEN
    FOR object_row IN
      SELECT * FROM public.aide_objects
        WHERE report_host = in_host AND report_proc = in_proc AND name = in_name
        AND correlated = 'f'
    LOOP
      PERFORM set_correlated_aide(object_row.key);
    END LOOP;
    PERFORM insert_aide_object(in_host, in_proc, in_name, in_attr,
      in_perm, in_uid, in_gid, in_md5, in_sha256, in_acl,
      in_xattr, in_selinux, report_date);
    PERFORM set_correlated_aide(last_record.key);
    RETURN false;
  ELSE
    PERFORM update_aide_object(last_record.key, report_date);
    RETURN true;
  END IF;
END
$$;


ALTER FUNCTION public.upsert_aide_object(in_host character varying, in_proc character varying, in_name character varying, in_attr numeric, in_perm character varying, in_uid numeric, in_gid numeric, in_md5 character varying, in_sha256 character varying, in_acl character varying, in_xattr character varying, in_selinux character varying) OWNER TO fim_database;

--
-- Name: upsert_rpm_file_object(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION upsert_rpm_file_object(in_host character varying, in_proc character varying, in_name character varying, in_fileclass character varying, in_rpmname character varying, in_ver_rel_arch character varying, in_fileusername character varying, in_filegroupname character varying, in_filedevices character varying, in_sha256 character varying, in_perm character varying, in_fileverifyflags character varying, in_uid numeric, in_gid numeric) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  report_date TIMESTAMP WITHOUT TIME ZONE;
  last_record public.rpm_file_objects%ROWTYPE;
BEGIN
  SELECT INTO report_date backend_start::TIMESTAMP WITHOUT TIME ZONE FROM pg_stat_activity
    WHERE usename = "session_user"() AND client_addr = inet_client_addr()
    AND client_port = inet_client_port();
  SELECT * INTO last_record FROM public.rpm_file_objects
    WHERE report_host = in_host AND report_proc = in_proc AND name = in_name
    AND fileclass IS NOT DISTINCT FROM in_fileclass 
    AND rpmname IS NOT DISTINCT FROM in_rpmname
    AND ver_rel_arch IS NOT DISTINCT FROM in_ver_rel_arch 
    AND fileusername IS NOT DISTINCT FROM in_fileusername
    AND filegroupname IS NOT DISTINCT FROM in_filegroupname 
    AND sha256 IS NOT DISTINCT FROM in_sha256
    AND perm IS NOT DISTINCT FROM in_perm 
    AND fileverifyflags IS NOT DISTINCT FROM in_fileverifyflags
    AND uid IS NOT DISTINCT FROM in_uid 
    AND gid IS NOT DISTINCT FROM in_gid
    AND correlated = 'f'
    ORDER BY last_date LIMIT 1;
  IF NOT FOUND THEN
    PERFORM insert_rpm_file_object(in_host, in_proc, in_name,
      in_fileclass, in_rpmname, in_ver_rel_arch, in_fileusername,
      in_filegroupname, in_filedevices, in_sha256, in_perm, in_fileverifyflags,
      in_uid, in_gid, report_date);
    RETURN false;
  ELSE
    PERFORM update_rpm_file_object(last_record.key, report_date);
    RETURN true;
  END IF;
END
$$;


ALTER FUNCTION public.upsert_rpm_file_object(in_host character varying, in_proc character varying, in_name character varying, in_fileclass character varying, in_rpmname character varying, in_ver_rel_arch character varying, in_fileusername character varying, in_filegroupname character varying, in_filedevices character varying, in_sha256 character varying, in_perm character varying, in_fileverifyflags character varying, in_uid numeric, in_gid numeric) OWNER TO fim_database;

--
-- Name: upsert_rpm_package_object(character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, character varying, timestamp without time zone, character varying, character varying); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION upsert_rpm_package_object(in_host character varying, in_proc character varying, in_name character varying, in_ver_rel_arch character varying, in_version character varying, in_release character varying, in_arch character varying, in_installtime numeric, in_sha1header character varying, in_siggpg_date timestamp without time zone, in_siggpg_key character varying, in_sigmd5 character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
  report_date TIMESTAMP WITHOUT TIME ZONE;
  last_record public.rpm_package_objects%ROWTYPE;
  object_row public.rpm_package_objects%ROWTYPE;
BEGIN
  SELECT INTO report_date backend_start::TIMESTAMP WITHOUT TIME ZONE FROM pg_stat_activity
    WHERE usename = "session_user"() AND client_addr = inet_client_addr()
    AND client_port = inet_client_port();
  SELECT * INTO last_record FROM public.rpm_package_objects
    WHERE report_host = in_host AND report_proc = in_proc AND name = in_name
    AND ver_rel_arch IS NOT DISTINCT FROM in_ver_rel_arch
    AND version IS NOT DISTINCT FROM in_version
    AND release IS NOT DISTINCT FROM in_release
    AND arch IS NOT DISTINCT FROM in_arch
    AND installtime IS NOT DISTINCT FROM in_installtime
    AND sha1header IS NOT DISTINCT FROM in_sha1header
    AND siggpg_date IS NOT DISTINCT FROM in_siggpg_date
    AND siggpg_key IS NOT DISTINCT FROM in_siggpg_key
    AND sigmd5 IS NOT DISTINCT FROM in_sigmd5
    AND correlated = 'f'
    ORDER BY last_date LIMIT 1;
  IF NOT FOUND THEN
    FOR object_row IN
      SELECT * FROM public.rpm_package_objects
        WHERE report_host = in_host AND report_proc = in_proc AND name = in_name
        AND ver_rel_arch = in_ver_rel_arch AND correlated = 'f'
    LOOP
      PERFORM set_correlated_rpm_package(object_row.key);
    END LOOP;
    PERFORM insert_rpm_package_object(in_host, in_proc, in_name, in_ver_rel_arch,
      in_version, in_release, in_arch, in_installtime, in_sha1header,
      in_siggpg_date, in_siggpg_key, in_sigmd5, report_date);
    RETURN false;
  ELSE
    PERFORM update_rpm_package_object(last_record.key, report_date);
    RETURN true;
  END IF;
END
$$;


ALTER FUNCTION public.upsert_rpm_package_object(in_host character varying, in_proc character varying, in_name character varying, in_ver_rel_arch character varying, in_version character varying, in_release character varying, in_arch character varying, in_installtime numeric, in_sha1header character varying, in_siggpg_date timestamp without time zone, in_siggpg_key character varying, in_sigmd5 character varying) OWNER TO fim_database;

--
-- Name: upsert_run_job(character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: fim_database
--

CREATE FUNCTION upsert_run_job(in_job character varying, in_host character varying, in_proc character varying, in_action character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  working_date TIMESTAMP WITHOUT TIME ZONE;
  last_record public.jobs%ROWTYPE;
  object_row record;
  count int;
BEGIN
  SELECT INTO working_date backend_start::TIMESTAMP WITHOUT TIME ZONE FROM pg_stat_activity
    WHERE usename = "session_user"() AND client_addr = inet_client_addr()
    AND client_port = inet_client_port();
  PERFORM jobs_auto_partition(working_date);
  IF in_job = 'DATABASE_RUN' THEN
    IF in_action = 'START' THEN
      PERFORM insert_run_job(in_job, inet_client_addr(),
        "session_user"()::character varying, in_host, in_proc, NULL::timestamp without time zone,
        working_date, NULL::timestamp without time zone);
    ELSIF in_action = 'STOP' THEN
      SELECT * INTO last_record FROM jobs WHERE insert_ip = inet_client_addr()
        AND insert_user = "session_user"() AND report_host = in_host
        AND report_proc = in_proc AND job_name = in_job AND date_end is NULL;
      PERFORM finish_run_job(last_record.key, working_date);
      IF in_proc = 'rpm_package' THEN
        SELECT count(*) INTO count FROM jobs where report_host = in_host
          AND report_proc = in_proc AND job_name = in_job;
        IF count > 1 THEN
          FOR object_row IN
            SELECT * FROM rpm_package_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND last_date < working_date
              AND correlated = 'f' AND removed = 'f'
          LOOP
            PERFORM insert_rpm_package_object(
              in_host,
              in_proc,
              object_row.name,
              object_row.ver_rel_arch,
              NULL::character varying,
              NULL::character varying,
              NULL::character varying,
              NULL::numeric,
              NULL::character varying,
              NULL::timestamp without time zone,
              NULL::character varying,
              NULL::character varying,
              working_date);
            PERFORM set_correlated_rpm_package(object_row.key);
          END LOOP;
          FOR object_row IN
            SELECT * from rpm_package_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND last_date = working_date
              AND first_date = working_date AND reviewed = 'f'
              AND correlated = 'f' AND installtime is NULL
          LOOP
            PERFORM set_correlated_rpm_package(object_row.key);
            PERFORM set_removed_rpm_package(object_row.key);
          END LOOP;
        ELSE
          FOR object_row IN
            SELECT * FROM rpm_package_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND first_date = working_date
          LOOP
            PERFORM set_reviewed_rpm_package(object_row.key);
          END LOOP;
        END IF;
      ELSIF in_proc = 'aide' THEN
        SELECT count(*) INTO count FROM jobs where report_host = in_host
          AND report_proc = in_proc AND job_name = in_job;
        IF count > 1 THEN
          FOR object_row IN
            SELECT * FROM aide_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND last_date < working_date
              AND correlated = 'f' AND removed = 'f'
          LOOP
            PERFORM insert_aide_object(
              in_host,
              in_proc,
              object_row.name,
              NULL::numeric,
              NULL::character varying,
              NULL::numeric,
              NULL::numeric,
              NULL::character varying,
              NULL::character varying,
              NULL::character varying,
              NULL::character varying,
              NULL::character varying,
              working_date);
            PERFORM set_correlated_aide(object_row.key);
          END LOOP;
          FOR object_row IN
            SELECT * from aide_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND last_date = working_date
              AND first_date = working_date AND removed = 'f'
              AND correlated = 'f' AND attr IS NULL
          LOOP
            PERFORM set_correlated_aide(object_row.key);
            PERFORM set_removed_aide(object_row.key);
          END LOOP;
        ELSE
          FOR object_row IN
            SELECT * FROM aide_objects WHERE insert_ip = inet_client_addr()
              AND insert_user = "session_user"() AND report_host = in_host
              AND report_proc = in_proc AND first_date = working_date
          LOOP
            PERFORM set_reviewed_aide(object_row.key);
          END LOOP;
        END IF;
      END IF;
    END IF;
  END IF;
END
$$;


ALTER FUNCTION public.upsert_run_job(in_job character varying, in_host character varying, in_proc character varying, in_action character varying) OWNER TO fim_database;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: aide_objects; Type: TABLE; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE TABLE aide_objects (
    key bigint NOT NULL,
    name character varying(8192) NOT NULL,
    insert_ip cidr DEFAULT inet_client_addr(),
    insert_user character varying(64) DEFAULT "session_user"(),
    report_host character varying(253) NOT NULL,
    report_proc character varying(64) NOT NULL,
    priority integer DEFAULT 0,
    removed boolean DEFAULT false,
    correlated boolean DEFAULT false,
    reviewed boolean DEFAULT false,
    first_date timestamp without time zone NOT NULL,
    last_date timestamp without time zone NOT NULL,
    attr numeric,
    perm character varying(16),
    uid numeric,
    gid numeric,
    md5 character varying(64),
    sha256 character varying(64),
    acl character varying(1024),
    xattr character varying(8192),
    selinux character varying(1024)
)
WITH (autovacuum_enabled=true, fillfactor=50);


ALTER TABLE aide_objects OWNER TO fim_database;

--
-- Name: aide_objects_key_seq; Type: SEQUENCE; Schema: public; Owner: fim_database
--

CREATE SEQUENCE aide_objects_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE aide_objects_key_seq OWNER TO fim_database;

--
-- Name: aide_objects_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fim_database
--

ALTER SEQUENCE aide_objects_key_seq OWNED BY aide_objects.key;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE TABLE jobs (
    key bigint NOT NULL,
    job_name character varying(64),
    insert_ip cidr DEFAULT inet_client_addr(),
    insert_user character varying(64) DEFAULT "session_user"(),
    report_host character varying(253) NOT NULL,
    report_proc character varying(64) NOT NULL,
    report_date timestamp without time zone,
    date_start timestamp without time zone,
    date_end timestamp without time zone
);


ALTER TABLE jobs OWNER TO fim_database;

--
-- Name: jobs_key_seq; Type: SEQUENCE; Schema: public; Owner: fim_database
--

CREATE SEQUENCE jobs_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jobs_key_seq OWNER TO fim_database;

--
-- Name: jobs_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fim_database
--

ALTER SEQUENCE jobs_key_seq OWNED BY jobs.key;


--
-- Name: rpm_file_objects; Type: TABLE; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE TABLE rpm_file_objects (
    key bigint NOT NULL,
    name character varying(8192) NOT NULL,
    insert_ip cidr DEFAULT inet_client_addr(),
    insert_user character varying(64) DEFAULT "session_user"(),
    report_host character varying(253) NOT NULL,
    report_proc character varying(64) NOT NULL,
    priority integer DEFAULT 0,
    removed boolean DEFAULT false,
    correlated boolean DEFAULT false,
    reviewed boolean DEFAULT false,
    first_date timestamp without time zone NOT NULL,
    last_date timestamp without time zone NOT NULL,
    fileclass character varying(2048),
    rpmname character varying(256),
    ver_rel_arch character varying(256),
    fileusername character varying(64),
    filegroupname character varying(64),
    filedevices character varying(256),
    sha256 character(64),
    perm character varying(16),
    fileverifyflags character varying(10),
    uid numeric,
    gid numeric
)
WITH (autovacuum_enabled=true, fillfactor=50);


ALTER TABLE rpm_file_objects OWNER TO fim_database;

--
-- Name: rpm_file_objects_key_seq; Type: SEQUENCE; Schema: public; Owner: fim_database
--

CREATE SEQUENCE rpm_file_objects_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rpm_file_objects_key_seq OWNER TO fim_database;

--
-- Name: rpm_file_objects_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fim_database
--

ALTER SEQUENCE rpm_file_objects_key_seq OWNED BY rpm_file_objects.key;


--
-- Name: rpm_package_objects; Type: TABLE; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE TABLE rpm_package_objects (
    key bigint NOT NULL,
    name character varying(8192) NOT NULL,
    insert_ip cidr DEFAULT inet_client_addr(),
    insert_user character varying(64) DEFAULT "session_user"(),
    report_host character varying(253) NOT NULL,
    report_proc character varying(64) NOT NULL,
    priority integer DEFAULT 0,
    removed boolean DEFAULT false,
    correlated boolean DEFAULT false,
    reviewed boolean DEFAULT false,
    first_date timestamp without time zone NOT NULL,
    last_date timestamp without time zone NOT NULL,
    ver_rel_arch character varying(256),
    version character varying(256),
    release character varying(256),
    arch character varying(256),
    installtime numeric,
    sha1header character varying(128),
    siggpg_date timestamp without time zone,
    siggpg_key character varying(64),
    sigmd5 character varying(64)
)
WITH (autovacuum_enabled=true, fillfactor=50);


ALTER TABLE rpm_package_objects OWNER TO fim_database;

--
-- Name: rpm_package_objects_key_seq; Type: SEQUENCE; Schema: public; Owner: fim_database
--

CREATE SEQUENCE rpm_package_objects_key_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE rpm_package_objects_key_seq OWNER TO fim_database;

--
-- Name: rpm_package_objects_key_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: fim_database
--

ALTER SEQUENCE rpm_package_objects_key_seq OWNED BY rpm_package_objects.key;


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY aide_objects ALTER COLUMN key SET DEFAULT nextval('aide_objects_key_seq'::regclass);


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs ALTER COLUMN key SET DEFAULT nextval('jobs_key_seq'::regclass);


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2015_12 ALTER COLUMN key SET DEFAULT nextval('jobs_key_seq'::regclass);


--
-- Name: insert_ip; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2015_12 ALTER COLUMN insert_ip SET DEFAULT inet_client_addr();


--
-- Name: insert_user; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2015_12 ALTER COLUMN insert_user SET DEFAULT "session_user"();


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2016_1 ALTER COLUMN key SET DEFAULT nextval('jobs_key_seq'::regclass);


--
-- Name: insert_ip; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2016_1 ALTER COLUMN insert_ip SET DEFAULT inet_client_addr();


--
-- Name: insert_user; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY jobs_2016_1 ALTER COLUMN insert_user SET DEFAULT "session_user"();


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY rpm_file_objects ALTER COLUMN key SET DEFAULT nextval('rpm_file_objects_key_seq'::regclass);


--
-- Name: key; Type: DEFAULT; Schema: public; Owner: fim_database
--

ALTER TABLE ONLY rpm_package_objects ALTER COLUMN key SET DEFAULT nextval('rpm_package_objects_key_seq'::regclass);


--
-- Name: aide_objects_key_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX aide_objects_key_idx ON aide_objects USING btree (key);


--
-- Name: aide_objects_name_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX aide_objects_name_idx ON aide_objects USING btree (name);


--
-- Name: aide_objects_report_host_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX aide_objects_report_host_idx ON aide_objects USING btree (report_host);


--
-- Name: aide_objects_report_proc_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX aide_objects_report_proc_idx ON aide_objects USING btree (report_proc);


--
-- Name: jobs_2015_12_date_start_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2015_12_date_start_idx ON jobs_2015_12 USING btree (date_start);


--
-- Name: jobs_2015_12_key_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2015_12_key_idx ON jobs_2015_12 USING btree (key);


--
-- Name: jobs_2015_12_report_host_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2015_12_report_host_idx ON jobs_2015_12 USING btree (report_host);


--
-- Name: jobs_2015_12_report_proc_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2015_12_report_proc_idx ON jobs_2015_12 USING btree (report_proc);


--
-- Name: jobs_2016_1_date_start_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2016_1_date_start_idx ON jobs_2016_1 USING btree (date_start);


--
-- Name: jobs_2016_1_key_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2016_1_key_idx ON jobs_2016_1 USING btree (key);


--
-- Name: jobs_2016_1_report_host_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2016_1_report_host_idx ON jobs_2016_1 USING btree (report_host);


--
-- Name: jobs_2016_1_report_proc_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX jobs_2016_1_report_proc_idx ON jobs_2016_1 USING btree (report_proc);


--
-- Name: rpm_file_objects_key_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_file_objects_key_idx ON rpm_file_objects USING btree (key);


--
-- Name: rpm_file_objects_name_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_file_objects_name_idx ON rpm_file_objects USING btree (name);


--
-- Name: rpm_file_objects_report_host_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_file_objects_report_host_idx ON rpm_file_objects USING btree (report_host);


--
-- Name: rpm_file_objects_report_proc_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_file_objects_report_proc_idx ON rpm_file_objects USING btree (report_proc);


--
-- Name: rpm_package_objects_key_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_package_objects_key_idx ON rpm_package_objects USING btree (key);


--
-- Name: rpm_package_objects_name_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_package_objects_name_idx ON rpm_package_objects USING btree (name);


--
-- Name: rpm_package_objects_report_host_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_package_objects_report_host_idx ON rpm_package_objects USING btree (report_host);


--
-- Name: rpm_package_objects_report_proc_idx; Type: INDEX; Schema: public; Owner: fim_database; Tablespace: 
--

CREATE INDEX rpm_package_objects_report_proc_idx ON rpm_package_objects USING btree (report_proc);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: aide_objects; Type: ACL; Schema: public; Owner: fim_database
--

REVOKE ALL ON TABLE aide_objects FROM PUBLIC;
REVOKE ALL ON TABLE aide_objects FROM fim_database;
GRANT ALL ON TABLE aide_objects TO fim_database;
GRANT ALL ON TABLE aide_objects TO postgres;
GRANT SELECT ON TABLE aide_objects TO fim_users;
GRANT SELECT,INSERT,UPDATE ON TABLE aide_objects TO fim_query_tables;


--
-- Name: jobs; Type: ACL; Schema: public; Owner: fim_database
--

REVOKE ALL ON TABLE jobs FROM PUBLIC;
REVOKE ALL ON TABLE jobs FROM fim_database;
GRANT ALL ON TABLE jobs TO fim_database;
GRANT ALL ON TABLE jobs TO postgres;
GRANT SELECT ON TABLE jobs TO fim_users;
GRANT SELECT,INSERT,UPDATE ON TABLE jobs TO fim_query_tables;


--
-- Name: rpm_file_objects; Type: ACL; Schema: public; Owner: fim_database
--

REVOKE ALL ON TABLE rpm_file_objects FROM PUBLIC;
REVOKE ALL ON TABLE rpm_file_objects FROM fim_database;
GRANT ALL ON TABLE rpm_file_objects TO fim_database;
GRANT ALL ON TABLE rpm_file_objects TO postgres;
GRANT SELECT ON TABLE rpm_file_objects TO fim_users;
GRANT SELECT,INSERT,UPDATE ON TABLE rpm_file_objects TO fim_query_tables;


--
-- Name: rpm_package_objects; Type: ACL; Schema: public; Owner: fim_database
--

REVOKE ALL ON TABLE rpm_package_objects FROM PUBLIC;
REVOKE ALL ON TABLE rpm_package_objects FROM fim_database;
GRANT ALL ON TABLE rpm_package_objects TO fim_database;
GRANT ALL ON TABLE rpm_package_objects TO postgres;
GRANT SELECT ON TABLE rpm_package_objects TO fim_users;
GRANT SELECT,INSERT,UPDATE ON TABLE rpm_package_objects TO fim_query_tables;


--
-- PostgreSQL database dump complete
--

