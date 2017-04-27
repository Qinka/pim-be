-- Initialize the database

-- For the appointment

-- Drop SEQUENCE appointment_id_seq;
CREATE SEQUENCE appointment_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 1
  CACHE 1;
ALTER TABLE appointment_id_seq
  OWNER TO postgres;
-- DROP TABLE appointment;
CREATE TABLE appointment
(
  id      bigint            NOT NULL DEFAULT nextval('appointment_id_seq'::regclass),
  date    date              NOT NULL,
  context character varying NOT NULL,
  own     character varying NOT NULL,
  priority character varying NOT NULL,
  CONSTRAINT appointment_pkey PRIMARY KEY (id)
);
ALTER TABLE appointment
  OWNER TO postgres;

-- For the contact

-- DROP SEQUENCE contact_id_seq;
CREATE SEQUENCE contact_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 6
  CACHE 1;
ALTER TABLE contact_id_seq
  OWNER TO postgres;
-- DROP TABLE contact;
CREATE TABLE contact
(
  id      bigint            NOT NULL DEFAULT nextval('contact_id_seq'::regclass),
  fname   character varying NOT NULL,
  lname   character varying NOT NULL,
  email   character varying NOT NULL,
  own     character varying NOT NULL,
  priority character varying NOT NULL,
  CONSTRAINT contact_pkey PRIMARY KEY (id)
);
ALTER TABLE contact
  OWNER TO postgres;

-- For the note

-- DROP SEQUENCE note_id_seq;
CREATE SEQUENCE note_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 5
  CACHE 1;
ALTER TABLE note_id_seq
  OWNER TO postgres;
-- DROP TABLE note;
CREATE TABLE note
(
  id      bigint            NOT NULL DEFAULT nextval('note_id_seq'::regclass),
  context character varying NOT NULL,
  own     character varying NOT NULL,
  priority character varying NOT NULL,
  CONSTRAINT note_pkey PRIMARY KEY (id)
);
ALTER TABLE note
  OWNER TO postgres;

-- For the todo

-- DROP SEQUENCE todo_id_seq;
CREATE SEQUENCE todo_id_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 2
  CACHE 1;
ALTER TABLE todo_id_seq
  OWNER TO postgres;
-- DROP TABLE todo;
CREATE TABLE todo
(
  id      bigint            NOT NULL DEFAULT nextval('todo_id_seq'::regclass),
  date    date              NOT NULL,
  context character varying NOT NULL,
  own     character varying NOT NULL,
  priority character varying NOT NULL,
  CONSTRAINT todo_pkey PRIMARY KEY (id)
);
ALTER TABLE public.todo
  OWNER TO postgres;
