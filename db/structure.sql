--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.1
-- Dumped by pg_dump version 9.6.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: delayed_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delayed_jobs (
    id integer NOT NULL,
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


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delayed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delayed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delayed_jobs_id_seq OWNED BY delayed_jobs.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE groups (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    slug character varying,
    description text,
    ancestry text,
    ancestry_depth integer DEFAULT 0 NOT NULL,
    acronym text,
    description_reminder_email_at timestamp without time zone,
    members_completion_score integer
);


--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE groups_id_seq OWNED BY groups.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE memberships (
    id integer NOT NULL,
    group_id integer NOT NULL,
    person_id integer NOT NULL,
    role text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    leader boolean DEFAULT false,
    subscribed boolean DEFAULT true NOT NULL
);


--
-- Name: memberships_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE memberships_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: memberships_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE memberships_id_seq OWNED BY memberships.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE people (
    id integer NOT NULL,
    given_name text,
    surname text,
    email text,
    primary_phone_number text,
    secondary_phone_number text,
    location_in_building text,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    works_monday boolean DEFAULT true,
    works_tuesday boolean DEFAULT true,
    works_wednesday boolean DEFAULT true,
    works_thursday boolean DEFAULT true,
    works_friday boolean DEFAULT true,
    image character varying,
    slug character varying,
    works_saturday boolean DEFAULT false,
    works_sunday boolean DEFAULT false,
    login_count integer DEFAULT 0 NOT NULL,
    last_login_at timestamp without time zone,
    super_admin boolean DEFAULT false,
    building text,
    city text,
    secondary_email text,
    profile_photo_id integer,
    last_reminder_email_at timestamp without time zone,
    current_project character varying,
    pager_number text
);


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE people_id_seq OWNED BY people.id;


--
-- Name: permitted_domains; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE permitted_domains (
    id integer NOT NULL,
    domain character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: permitted_domains_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permitted_domains_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permitted_domains_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permitted_domains_id_seq OWNED BY permitted_domains.id;


--
-- Name: profile_photos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE profile_photos (
    id integer NOT NULL,
    image character varying,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: profile_photos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profile_photos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profile_photos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profile_photos_id_seq OWNED BY profile_photos.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tokens (
    id integer NOT NULL,
    value text,
    user_email text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    spent boolean DEFAULT false
);


--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tokens_id_seq OWNED BY tokens.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE versions (
    id integer NOT NULL,
    item_type text NOT NULL,
    item_id integer NOT NULL,
    event text NOT NULL,
    whodunnit text,
    object text,
    created_at timestamp without time zone,
    object_changes text,
    ip_address character varying,
    user_agent character varying
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE versions_id_seq OWNED BY versions.id;


--
-- Name: delayed_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs ALTER COLUMN id SET DEFAULT nextval('delayed_jobs_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: memberships id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: permitted_domains id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permitted_domains ALTER COLUMN id SET DEFAULT nextval('permitted_domains_id_seq'::regclass);


--
-- Name: profile_photos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_photos ALTER COLUMN id SET DEFAULT nextval('profile_photos_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens ALTER COLUMN id SET DEFAULT nextval('tokens_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: delayed_jobs delayed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delayed_jobs
    ADD CONSTRAINT delayed_jobs_pkey PRIMARY KEY (id);


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: permitted_domains permitted_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY permitted_domains
    ADD CONSTRAINT permitted_domains_pkey PRIMARY KEY (id);


--
-- Name: profile_photos profile_photos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profile_photos
    ADD CONSTRAINT profile_photos_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: delayed_jobs_priority; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX delayed_jobs_priority ON delayed_jobs USING btree (priority, run_at);


--
-- Name: index_groups_on_ancestry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_ancestry ON groups USING btree (ancestry);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_group_id ON memberships USING btree (group_id);


--
-- Name: index_memberships_on_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_memberships_on_person_id ON memberships USING btree (person_id);


--
-- Name: index_people_on_lowercase_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_people_on_lowercase_email ON people USING btree (lower(email));


--
-- Name: index_people_on_slug; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_people_on_slug ON people USING btree (slug);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: memberships fk_rails_092b9b8356; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT fk_rails_092b9b8356 FOREIGN KEY (person_id) REFERENCES people(id);


--
-- Name: memberships fk_rails_aaf389f138; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT fk_rails_aaf389f138 FOREIGN KEY (group_id) REFERENCES groups(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20141014092058');

INSERT INTO schema_migrations (version) VALUES ('20141014092059');

INSERT INTO schema_migrations (version) VALUES ('20141022133535');

INSERT INTO schema_migrations (version) VALUES ('20141030110921');

INSERT INTO schema_migrations (version) VALUES ('20141124125254');

INSERT INTO schema_migrations (version) VALUES ('20150130104922');

INSERT INTO schema_migrations (version) VALUES ('20150213114203');

INSERT INTO schema_migrations (version) VALUES ('20150213114204');

INSERT INTO schema_migrations (version) VALUES ('20150213114205');

INSERT INTO schema_migrations (version) VALUES ('20150213114206');

INSERT INTO schema_migrations (version) VALUES ('20150213114207');

INSERT INTO schema_migrations (version) VALUES ('20150216160126');

INSERT INTO schema_migrations (version) VALUES ('20150225172300');

INSERT INTO schema_migrations (version) VALUES ('20150310110342');

INSERT INTO schema_migrations (version) VALUES ('20150310110343');

INSERT INTO schema_migrations (version) VALUES ('20150310110344');

INSERT INTO schema_migrations (version) VALUES ('20150402143602');

INSERT INTO schema_migrations (version) VALUES ('20150402143603');

INSERT INTO schema_migrations (version) VALUES ('20150402143604');

INSERT INTO schema_migrations (version) VALUES ('20150402143820');

INSERT INTO schema_migrations (version) VALUES ('20150403162416');

INSERT INTO schema_migrations (version) VALUES ('20150407101222');

INSERT INTO schema_migrations (version) VALUES ('20150413101844');

INSERT INTO schema_migrations (version) VALUES ('20150417141735');

INSERT INTO schema_migrations (version) VALUES ('20150420132554');

INSERT INTO schema_migrations (version) VALUES ('20150420132854');

INSERT INTO schema_migrations (version) VALUES ('20150604110007');

INSERT INTO schema_migrations (version) VALUES ('20150604110654');

INSERT INTO schema_migrations (version) VALUES ('20151217094046');

INSERT INTO schema_migrations (version) VALUES ('20160304155510');

INSERT INTO schema_migrations (version) VALUES ('20160308105233');

INSERT INTO schema_migrations (version) VALUES ('20160407145602');

INSERT INTO schema_migrations (version) VALUES ('20160411134824');

INSERT INTO schema_migrations (version) VALUES ('20160418124145');

INSERT INTO schema_migrations (version) VALUES ('20160419131143');

INSERT INTO schema_migrations (version) VALUES ('20160719084601');

