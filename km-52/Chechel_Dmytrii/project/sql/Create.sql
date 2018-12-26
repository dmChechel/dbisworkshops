-- auto-generated definition
CREATE TABLE users
(
  name  VARCHAR2(30) NOT NULL,
  email VARCHAR2(30) NOT NULL
    PRIMARY KEY
)
 ;

-- auto-generated definition
CREATE TABLE migration_statuses
(
  id          NUMBER(10)
    PRIMARY KEY,
  status_name VARCHAR2(30) NOT NULL,
  CONSTRAINT migration_st_stat_name_uindex
  UNIQUE (status_name)
)
 ;

-- Generate ID using sequence and trigger
CREATE SEQUENCE migration_statuses_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER migration_statuses_seq_tr
 BEFORE INSERT ON migration_statuses FOR EACH ROW
 WHEN (NEW.id IS NULL)
BEGIN
 SELECT migration_statuses_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;


  -- auto-generated definition
CREATE TABLE databases
(
  id   NUMBER(10)
    PRIMARY KEY,
  name VARCHAR2(30) NOT NULL,
  CONSTRAINT databases_name_uindex
  UNIQUE (name)
)
 ;

-- Generate ID using sequence and trigger
CREATE SEQUENCE databases_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER databases_seq_tr
 BEFORE INSERT ON databases FOR EACH ROW
 WHEN (NEW.id IS NULL)
BEGIN
 SELECT databases_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;

-- auto-generated definition
CREATE TABLE migration_requests
(
  id          NUMBER(10)
    PRIMARY KEY,
  user_email  VARCHAR2(30) NOT NULL,
  timestamp   TIMESTAMP(0)    NOT NULL,
  database_id NUMBER(10) NOT NULL,
  CONSTRAINT migration_req_us_id_fk
  FOREIGN KEY (user_email) REFERENCES users (email)
    ON DELETE CASCADE,
  CONSTRAINT migration_req_dbs_id_fk
  FOREIGN KEY (database_id) REFERENCES databases (id)
    ON DELETE CASCADE
);

-- Generate ID using sequence and trigger
CREATE SEQUENCE migration_requests_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE TRIGGER migration_requests_seq_tr
 BEFORE INSERT ON migration_requests FOR EACH ROW
 WHEN (NEW.id IS NULL)
BEGIN
 SELECT migration_requests_seq.NEXTVAL INTO :NEW.id FROM DUAL;
END;
/

CREATE INDEX migration_req_us_id_fk
  ON migration_requests (user_email);

CREATE INDEX migration_req_db_id_fk
  ON migration_requests (database_id);

-- auto-generated definition
CREATE TABLE migration_status
(
  migration_id        NUMBER(10)                            NOT NULL,
  migration_status_id NUMBER(10)                                NOT NULL,
  timestamp           TIMESTAMP(0) DEFAULT SYSTIMESTAMP NOT NULL,
  CONSTRAINT migration_stat_migr_req_id_fk
  FOREIGN KEY (migration_id) REFERENCES migration_requests (id)
    ON DELETE CASCADE,
  CONSTRAINT migration_stat_migr_st_id_fk
  FOREIGN KEY (migration_status_id) REFERENCES migration_statuses (id)
    ON DELETE CASCADE
)
 ;

CREATE INDEX migration_stat_migr_req_id_fk
  ON migration_status (migration_id);

CREATE INDEX migration_stat_migr_sta_id_fk
  ON migration_status (migration_status_id);

-- auto-generated definition
CREATE TABLE migration_files
(
  "size"         NUMBER(19) CHECK ("size" > 0)                    NOT NULL,
  link         VARCHAR2(255)                       NOT NULL,
  migration_id NUMBER(10)                            NOT NULL,
  timestamp    TIMESTAMP(0) DEFAULT SYSTIMESTAMP NULL,
  CONSTRAINT migration_files_migr_req_id_fk
  FOREIGN KEY (migration_id) REFERENCES migration_requests (id)
    ON DELETE CASCADE
);

CREATE INDEX migration_files_migr_req_id_fk
  ON migration_files (migration_id);

ALTER TABLE users
ADD CONSTRAINT check_email
CHECK ( REGEXP_LIKE (email, '[A-Z0-9._]+@[A-Z0-9._]+\.[A-Z]{2,4}'));

ALTER TABLE users
ADD CONSTRAINT check_name
CHECK ( REGEXP_LIKE (name, '[A-Za-z1-9]+'));

ALTER TABLE migration_statuses
ADD CONSTRAINT check_status_name
CHECK ( REGEXP_LIKE (status_name, '[A-Za-z]+'));

ALTER TABLE databases
ADD CONSTRAINT check_name
CHECK ( REGEXP_LIKE (name, '[A-Za-z1-9]+'));

ALTER TABLE migration_statuses
ADD CONSTRAINT check_status_name
CHECK ( REGEXP_LIKE (status_name, '[A-Za-z]+'));

ALTER TABLE migration_statuses
ADD CONSTRAINT check_status_name
CHECK ( REGEXP_LIKE (status_name, '[A-Za-z]+'));

ALTER TABLE migration_files
ADD CONSTRAINT check_link
CHECK ( REGEXP_LIKE (link, '(http[s]?:\/\/){1}[A-Z0-9\-]+\.[A-Z]+'));

alter table MIGRATION_FILES
  drop column "size"
ALTER TABLE MIGRATION_FILES ADD file_size NUMBER NULL;

ALTER TABLE MIGRATION_FILES RENAME COLUMN TIMESTAMP TO UPLOAD_TIMESTAMP;

ALTER TABLE MIGRATION_REQUESTS RENAME COLUMN TIMESTAMP TO UPLOAD_TIMESTAMP;

ALTER TABLE MIGRATION_STATUS RENAME COLUMN TIMESTAMP TO UPLOAD_TIMESTAMP;

ALTER TABLE USERS ADD PASSWORD VARCHAR2(30) DEFAULT 'aaaa' NOT NULL;

select * from migration_files
