INSERT INTO users (id, name, email, password) VALUES (1, 'Petro', 'Petro@vasil.com', '1234567781');
INSERT INTO users (id, name, email, password) VALUES (2, 'Vasil', 'vasil@petro.com', '123132123123');

INSERT INTO migration_files (id, size, link, db_name) VALUES (1, 12, 'https://example.com/file1', 'mysql');
INSERT INTO migration_files (id, size, link, db_name) VALUES (2, 51, 'https://example.com/file3', 'mysql');
INSERT INTO migration_files (id, size, link, db_name) VALUES (3, 51, 'https://example.com/file2', 'postgresql');

INSERT INTO migration_requests (id, user_id, timestamp) VALUES (1, 1, '2018-03-02 18:18:18');
INSERT INTO migration_requests (id, user_id, timestamp) VALUES (2, 1, '2018-04-02 18:18:18');
INSERT INTO migration_requests (id, user_id, timestamp) VALUES (3, 2, '2018-03-02 19:18:18');

INSERT INTO requests_files (request_id, file_id) VALUES (1, 1);
INSERT INTO requests_files (request_id, file_id) VALUES (1, 2);
INSERT INTO requests_files (request_id, file_id) VALUES (2, 3);
