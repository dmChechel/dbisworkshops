CREATE TABLE users
(
  id    NUMBER PRIMARY KEY,
  name  VARCHAR(30) NOT NULL,
  email VARCHAR(30) NOT NULL,
  password VARCHAR(30) NOT NULL CHECK(length(password) > 8)

);

CREATE TABLE migration_requests
(
  id        NUMBER PRIMARY KEY NOT NULL,
  user_id   NUMBER             NOT NULL,
  timestamp TIMESTAMP          NOT NULL
);

CREATE TABLE migration_files
(
  id        NUMBER PRIMARY KEY NOT NULL,
  file_size NUMBER             NOT NULL CHECK (file_size < 10000000 AND file_size > 0),
  link      VARCHAR(255)       NOT NULL,
  db_name   VARCHAR2(30) CHECK (db_name in ('mysql', 'postgresql'))
);

CREATE TABLE requests_files
(
  request_id NUMBER(11) NOT NULL,
  file_id    NUMBER(11) NOT NULL
);


CREATE SEQUENCE users_seq
START WITH 1;
CREATE OR REPLACE TRIGGER users_tr
BEFORE INSERT
  ON users
FOR EACH ROW
BEGIN
SELECT users_seq.nextval
INTO :NEW.id
FROM dual;
end;

CREATE SEQUENCE migration_requests_seq
START WITH 1;
CREATE OR REPLACE TRIGGER migration_requests_tr
BEFORE INSERT
  ON migration_requests
FOR EACH ROW
BEGIN
SELECT migration_requests._seq.nextval
INTO :NEW.id
FROM dual;
end;

CREATE SEQUENCE migration_files_seq
START WITH 1;
CREATE OR REPLACE TRIGGER migration_files_tr
BEFORE INSERT
  ON migration_files
FOR EACH ROW
BEGIN
SELECT migration_files._seq.nextval
INTO :NEW.id
FROM dual;
end;
