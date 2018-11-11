INSERT INTO databases (id, name) VALUES (1, 'mysql');
INSERT INTO databases (id, name) VALUES (2, 'postgresql');

INSERT INTO users (name, email) VALUES ('petro', 'petro@petro.com');

INSERT INTO migration_requests (id, user_email, timestamp, database_id) VALUES (1, 'petro@petro.com', '2018-11-11 19:57:20', 1);
INSERT INTO migration_requests (id, user_email, timestamp, database_id) VALUES (2, 'petro@petro.com', '2018-11-11 19:57:23', 2);

INSERT INTO migration_statuses (id, status_name) VALUES (1, 'created');
INSERT INTO migration_statuses (id, status_name) VALUES (2, 'finished');

INSERT INTO migration_status (migration_id, migration_status_id, timestamp) VALUES (1, 1, '2018-11-11 19:58:21');
INSERT INTO migration_status (migration_id, migration_status_id, timestamp) VALUES (2, 2, '2018-11-11 19:58:23');

INSERT INTO migration_files (size, link, migration_id, timestamp) VALUES (12, 'https://sdfsd.com/dfasdsadasd', 2, '2018-11-11 19:59:08');
INSERT INTO migration_files (size, link, migration_id, timestamp) VALUES (123, 'https://sdfsd.com/dsadasd', 1, '2018-11-11 19:59:08');
INSERT INTO migration_files (size, link, migration_id, timestamp) VALUES (42, 'https://sdfsd.com/dssdadadasd', 1, '2018-11-11 19:59:08');
