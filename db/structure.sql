SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

CREATE FUNCTION public.graphemes_revisions_drop_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        partition TEXT;
      BEGIN
          partition := TG_RELNAME || '_' || replace(OLD.id :: varchar, '-', '_');
          EXECUTE 'DROP ' || partition;
          RETURN NULL;
      END;
      $$;

CREATE FUNCTION public.graphemes_revisions_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
      DECLARE
        partition TEXT;
      BEGIN
          partition := TG_RELNAME || '_' || replace(NEW.revision_id :: varchar, '-', '_');
          EXECUTE 'INSERT INTO ' || partition || ' SELECT(' || TG_RELNAME || ' ' || quote_literal(NEW) || ').* RETURNING revision_id;';
          RETURN NULL;
      END;
      $$;

CREATE FUNCTION public.uuid_array_intersect(a1 uuid[], a2 uuid[]) RETURNS uuid[]
    LANGUAGE plpgsql
    AS $$
      declare
          ret uuid[];
      begin
          if a1 is null then
              return a2;
          elseif a2 is null then
              return a1;
          end if;
          select array_agg(e) into ret
          from (
              select unnest(a1)
              intersect
              select unnest(a2)
          ) as dt(e);
          return ret;
      end;
      $$;

CREATE AGGREGATE public.uuid_array_intersect_agg(uuid[]) (
    SFUNC = public.uuid_array_intersect,
    STYPE = uuid[]
);

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE public.administrators (
    id bigint NOT NULL,
    email character varying,
    password_digest character varying,
    first_name character varying,
    last_name character varying,
    remember_token character varying,
    remember_token_expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE SEQUENCE public.administrators_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.administrators_id_seq OWNED BY public.administrators.id;

CREATE TABLE public.annotations (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    content text,
    editor_id uuid,
    areas box[],
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    surface_number integer,
    mode integer DEFAULT 0,
    payload json DEFAULT '{}'::json,
    status integer DEFAULT 0
);

CREATE TABLE public.annotations_revisions (
    annotation_id uuid NOT NULL,
    revision_id uuid NOT NULL
);

CREATE TABLE public.apps (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    secret character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.async_responses (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    payload jsonb,
    status integer DEFAULT 0,
    editor_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.branches (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    revision_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    editor_id uuid,
    status integer DEFAULT 0
);

CREATE TABLE public.correction_logs (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    grapheme_id uuid NOT NULL,
    revision_id uuid NOT NULL,
    editor_id uuid NOT NULL,
    status integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    surface_number integer
);

CREATE TABLE public.delayed_jobs (
    id bigint NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    handler text NOT NULL,
    last_error text,
    run_at timestamp without time zone,
    locked_at timestamp without time zone,
    failed_at timestamp without time zone,
    locked_by character varying,
    queue character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);

CREATE SEQUENCE public.delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.delayed_jobs_id_seq OWNED BY public.delayed_jobs.id;

CREATE TABLE public.documents (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    title character varying NOT NULL,
    author character varying,
    authority character varying,
    date date,
    editor character varying,
    license character varying,
    notes text,
    publisher character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer NOT NULL,
    app_id uuid NOT NULL,
    languages character varying[],
    ocr_model_ids uuid[]
);

CREATE TABLE public.editors (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    email character varying NOT NULL,
    first_name character varying,
    last_name character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.graphemes (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    zone_id uuid NOT NULL,
    area box NOT NULL,
    value character(1) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    certainty numeric(5,4) DEFAULT 0.0,
    status integer DEFAULT 0,
    parent_ids uuid[] DEFAULT '{}'::uuid[],
    position_weight numeric(12,6)
);

CREATE TABLE public.images (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    name character varying,
    image_scan character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    document_id uuid,
    "order" integer DEFAULT 0,
    hocr character varying,
    processed_image character varying
);

CREATE TABLE public.ocr_model_samples (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    ocr_model_id uuid,
    sample_image character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.ocr_models (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    backend integer NOT NULL,
    filename character varying NOT NULL,
    name character varying NOT NULL,
    description text,
    languages character varying[] NOT NULL,
    scripts character varying[] NOT NULL,
    version_code character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.pipelines (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    type character varying,
    status integer,
    document_id uuid,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE public.que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);

COMMENT ON TABLE public.que_jobs IS '3';

CREATE SEQUENCE public.que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.que_jobs_job_id_seq OWNED BY public.que_jobs.job_id;

CREATE TABLE public.revisions (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id uuid,
    status integer DEFAULT 0,
    merged_with_id uuid
);

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);

CREATE TABLE public.stashed_files (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    attachment character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.surfaces (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    document_id uuid NOT NULL,
    area box NOT NULL,
    number integer NOT NULL,
    image_id uuid NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);

CREATE TABLE public.zones (
    id uuid DEFAULT public.gen_random_uuid() NOT NULL,
    document_id uuid,
    area box,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    surface_id uuid NOT NULL,
    position_weight numeric(12,6) DEFAULT 0,
    direction integer DEFAULT 0
);

ALTER TABLE ONLY public.administrators ALTER COLUMN id SET DEFAULT nextval('public.administrators_id_seq'::regclass);

ALTER TABLE ONLY public.delayed_jobs ALTER COLUMN id SET DEFAULT nextval('public.delayed_jobs_id_seq'::regclass);

ALTER TABLE ONLY public.que_jobs ALTER COLUMN job_id SET DEFAULT nextval('public.que_jobs_job_id_seq'::regclass);

ALTER TABLE ONLY public.administrators
    ADD CONSTRAINT administrators_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.annotations
    ADD CONSTRAINT annotations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.apps
    ADD CONSTRAINT apps_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);

ALTER TABLE ONLY public.async_responses
    ADD CONSTRAINT async_responses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.branches
    ADD CONSTRAINT branches_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.correction_logs
    ADD CONSTRAINT correction_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.editors
    ADD CONSTRAINT editors_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.graphemes
    ADD CONSTRAINT graphemes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.images
    ADD CONSTRAINT images_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.ocr_model_samples
    ADD CONSTRAINT ocr_model_samples_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.ocr_models
    ADD CONSTRAINT ocr_models_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.pipelines
    ADD CONSTRAINT pipelines_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);

ALTER TABLE ONLY public.revisions
    ADD CONSTRAINT revisions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);

ALTER TABLE ONLY public.stashed_files
    ADD CONSTRAINT stashed_files_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.surfaces
    ADD CONSTRAINT surfaces_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.zones
    ADD CONSTRAINT zones_pkey PRIMARY KEY (id);

CREATE INDEX delayed_jobs_priority ON public.delayed_jobs USING btree (priority, run_at);

CREATE INDEX index_surfaces_on_area ON public.surfaces USING gist (area);

CREATE INDEX index_zones_on_area ON public.zones USING gist (area);

CREATE INDEX index_zones_on_surface_id ON public.zones USING btree (surface_id);

CREATE TRIGGER graphemes_revisions_drop BEFORE DELETE ON public.revisions FOR EACH ROW EXECUTE PROCEDURE public.graphemes_revisions_drop_trigger();

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20170814142123'),
('20170817145750'),
('20170818073425'),
('20170818163059'),
('20170821184720'),
('20170822104154'),
('20170822105041'),
('20170822125710'),
('20170822162110'),
('20170823133643'),
('20170824101512'),
('20170824101649'),
('20170824101731'),
('20170824120613'),
('20170824121351'),
('20170824121723'),
('20170824124437'),
('20170828070141'),
('20170828084422'),
('20170828113253'),
('20170901132912'),
('20170905080141'),
('20170905103223'),
('20170908090222'),
('20170909073405'),
('20170922144030'),
('20170925092607'),
('20170926125916'),
('20171030144303'),
('20171106114305'),
('20171117181119'),
('20180109122852'),
('20180123101056'),
('20180125105900'),
('20180125111014'),
('20180125120531'),
('20180129134830'),
('20180129161937'),
('20180129171020'),
('20180131143632'),
('20180202161034'),
('20180220150734'),
('20180220151622'),
('20180228130000'),
('20180301102910'),
('20180301165602'),
('20180307082649'),
('20180308120321'),
('20180313171908'),
('20180403155425'),
('20180411115247'),
('20180626133220'),
('20180803154451'),
('20181009101443'),
('20181023114004'),
('20181029151147');

