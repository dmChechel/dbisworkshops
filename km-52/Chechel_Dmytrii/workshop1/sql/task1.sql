INSERT INTO migration_files (id, size, link, db_name) VALUES (6, 12, 'https://example.com/file1', 'mysql');
INSERT INTO migration_files (id, size, link, db_name) VALUES (7, 51, 'https://example.com/file3', 'mysql');

INSERT INTO migration_requests (id, user_id, timestamp) VALUES (3, 2, '2018-03-01 19:18:18');

INSERT INTO requests_files (request_id, file_id) VALUES (6, 3);
INSERT INTO requests_files (request_id, file_id) VALUES (7, 3);
