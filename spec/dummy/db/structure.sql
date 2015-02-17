--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: communities; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE communities (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: communities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE communities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: communities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE communities_id_seq OWNED BY communities.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE groups (
    id integer NOT NULL,
    name text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    slug character varying(255),
    description text,
    ancestry text,
    ancestry_depth integer DEFAULT 0 NOT NULL,
    team_email_address text
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
-- Name: information_requests; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE information_requests (
    id integer NOT NULL,
    recipient_id integer,
    sender_email character varying(255),
    message text,
    type character varying(255)
);


--
-- Name: information_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE information_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: information_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE information_requests_id_seq OWNED BY information_requests.id;


--
-- Name: memberships; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE memberships (
    id integer NOT NULL,
    group_id integer,
    person_id integer,
    role text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    leader boolean DEFAULT false
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
-- Name: people; Type: TABLE; Schema: public; Owner: -; Tablespace:
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
    image character varying(255),
    slug character varying(255),
    works_saturday boolean DEFAULT false,
    works_sunday boolean DEFAULT false,
    tags text,
    community_id integer,
    login_count integer DEFAULT 0 NOT NULL,
    last_login_at timestamp without time zone,
    super_admin boolean DEFAULT false,
    building text,
    city text
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
-- Name: peoplefinder_taggings; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE peoplefinder_taggings (
    id integer NOT NULL,
    tag_id integer,
    article_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: peoplefinder_taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE peoplefinder_taggings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: peoplefinder_taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE peoplefinder_taggings_id_seq OWNED BY peoplefinder_taggings.id;


--
-- Name: reported_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE reported_profiles (
    id integer NOT NULL,
    notifier_id integer,
    subject_id integer,
    recipient_email character varying(255),
    reason_for_reporting text,
    additional_details text
);


--
-- Name: reported_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reported_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reported_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reported_profiles_id_seq OWNED BY reported_profiles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE tokens (
    id integer NOT NULL,
    value text,
    user_email text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
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
-- Name: versions; Type: TABLE; Schema: public; Owner: -; Tablespace:
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
    ip_address character varying(255),
    user_agent character varying(255)
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY communities ALTER COLUMN id SET DEFAULT nextval('communities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY groups ALTER COLUMN id SET DEFAULT nextval('groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY information_requests ALTER COLUMN id SET DEFAULT nextval('information_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY memberships ALTER COLUMN id SET DEFAULT nextval('memberships_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY people ALTER COLUMN id SET DEFAULT nextval('people_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY peoplefinder_taggings ALTER COLUMN id SET DEFAULT nextval('peoplefinder_taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reported_profiles ALTER COLUMN id SET DEFAULT nextval('reported_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tokens ALTER COLUMN id SET DEFAULT nextval('tokens_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY versions ALTER COLUMN id SET DEFAULT nextval('versions_id_seq'::regclass);


--
-- Name: communities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY communities
    ADD CONSTRAINT communities_pkey PRIMARY KEY (id);


--
-- Name: groups_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY groups
    ADD CONSTRAINT groups_pkey PRIMARY KEY (id);


--
-- Name: information_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY information_requests
    ADD CONSTRAINT information_requests_pkey PRIMARY KEY (id);


--
-- Name: memberships_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (id);


--
-- Name: people_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: peoplefinder_taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY peoplefinder_taggings
    ADD CONSTRAINT peoplefinder_taggings_pkey PRIMARY KEY (id);


--
-- Name: reported_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY reported_profiles
    ADD CONSTRAINT reported_profiles_pkey PRIMARY KEY (id);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace:
--

ALTER TABLE ONLY versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: index_groups_on_ancestry; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_groups_on_ancestry ON groups USING btree (ancestry);


--
-- Name: index_groups_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_groups_on_slug ON groups USING btree (slug);


--
-- Name: index_information_requests_on_sender_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_information_requests_on_sender_email ON information_requests USING btree (sender_email);


--
-- Name: index_information_requests_on_type; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_information_requests_on_type ON information_requests USING btree (type);


--
-- Name: index_memberships_on_group_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_memberships_on_group_id ON memberships USING btree (group_id);


--
-- Name: index_memberships_on_person_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_memberships_on_person_id ON memberships USING btree (person_id);


--
-- Name: index_people_on_lowercase_email; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_people_on_lowercase_email ON people USING btree (lower(email));


--
-- Name: index_people_on_slug; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX index_people_on_slug ON people USING btree (slug);


--
-- Name: index_peoplefinder_taggings_on_article_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_peoplefinder_taggings_on_article_id ON peoplefinder_taggings USING btree (article_id);


--
-- Name: index_peoplefinder_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_peoplefinder_taggings_on_tag_id ON peoplefinder_taggings USING btree (tag_id);


--
-- Name: index_versions_on_item_type_and_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_versions_on_item_type_and_item_id ON versions USING btree (item_type, item_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20141010090623');

INSERT INTO schema_migrations (version) VALUES ('20141010090624');

INSERT INTO schema_migrations (version) VALUES ('20141016102351');

INSERT INTO schema_migrations (version) VALUES ('20141029113248');

INSERT INTO schema_migrations (version) VALUES ('20141112170526');

INSERT INTO schema_migrations (version) VALUES ('20150129121619');

INSERT INTO schema_migrations (version) VALUES ('20150210115300');

INSERT INTO schema_migrations (version) VALUES ('20150211153741');

INSERT INTO schema_migrations (version) VALUES ('20150211164821');

INSERT INTO schema_migrations (version) VALUES ('20150212132353');

INSERT INTO schema_migrations (version) VALUES ('20150212153220');

INSERT INTO schema_migrations (version) VALUES ('20150213103214');

INSERT INTO schema_migrations (version) VALUES ('20150217105036');
