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


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: agreements; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE agreements (
    id integer NOT NULL,
    manager_id integer,
    staff_member_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    headcount_responsibilities hstore,
    objectives hstore[],
    responsibilities_signed_off_by_staff_member boolean DEFAULT false NOT NULL,
    responsibilities_signed_off_by_manager boolean DEFAULT false NOT NULL,
    objectives_signed_off_by_staff_member boolean DEFAULT false NOT NULL,
    objectives_signed_off_by_manager boolean DEFAULT false NOT NULL
);


--
-- Name: agreements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE agreements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: agreements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE agreements_id_seq OWNED BY agreements.id;


--
-- Name: budgetary_responsibilities; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE budgetary_responsibilities (
    id integer NOT NULL,
    agreement_id integer,
    budget_type character varying(255),
    value integer,
    description text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: budgetary_responsibilities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE budgetary_responsibilities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: budgetary_responsibilities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE budgetary_responsibilities_id_seq OWNED BY budgetary_responsibilities.id;


--
-- Name: objectives; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE objectives (
    id integer NOT NULL,
    objective_type character varying(255),
    description text,
    deliverables text,
    measurements text,
    agreement_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: objectives_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE objectives_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: objectives_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE objectives_id_seq OWNED BY objectives.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    name text,
    email text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    staff_number character varying(255),
    password_digest character varying(255),
    grade text,
    organisation text,
    password_reset_token character varying(255)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY agreements ALTER COLUMN id SET DEFAULT nextval('agreements_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY budgetary_responsibilities ALTER COLUMN id SET DEFAULT nextval('budgetary_responsibilities_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY objectives ALTER COLUMN id SET DEFAULT nextval('objectives_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: agreements_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY agreements
    ADD CONSTRAINT agreements_pkey PRIMARY KEY (id);


--
-- Name: budgetary_responsibilities_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY budgetary_responsibilities
    ADD CONSTRAINT budgetary_responsibilities_pkey PRIMARY KEY (id);


--
-- Name: objectives_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY objectives
    ADD CONSTRAINT objectives_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_agreements_on_manager_id_and_staff_member_id; Type: INDEX; Schema: public; Owner: -; Tablespace:
--

CREATE INDEX index_agreements_on_manager_id_and_staff_member_id ON agreements USING btree (manager_id, staff_member_id);


--
-- Name: index_budgetary_responsibilities_on_agreement_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_budgetary_responsibilities_on_agreement_id ON budgetary_responsibilities USING btree (agreement_id);


--
-- Name: index_objectives_on_objective_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_objectives_on_objective_type ON objectives USING btree (objective_type);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_password_reset_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_password_reset_token ON users USING btree (password_reset_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20140709110015');

INSERT INTO schema_migrations (version) VALUES ('20140711150506');

INSERT INTO schema_migrations (version) VALUES ('20140715090213');

INSERT INTO schema_migrations (version) VALUES ('20140715134140');

INSERT INTO schema_migrations (version) VALUES ('20140715134303');

INSERT INTO schema_migrations (version) VALUES ('20140715140742');

INSERT INTO schema_migrations (version) VALUES ('20140715150844');

INSERT INTO schema_migrations (version) VALUES ('20140717085456');

INSERT INTO schema_migrations (version) VALUES ('20140717100456');

INSERT INTO schema_migrations (version) VALUES ('20140718133703');

INSERT INTO schema_migrations (version) VALUES ('20140723161243');

INSERT INTO schema_migrations (version) VALUES ('20140724091225');

INSERT INTO schema_migrations (version) VALUES ('20140728095125');

INSERT INTO schema_migrations (version) VALUES ('20140728100246');
