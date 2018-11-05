DELETE FROM migration_files
    WHERE id IN (
        SELECT mf.id FROM migration_files mf
            JOIN requests_files rf ON mf.id = rf.file_id
            JOIN migration_requests mr ON rf.request_id = mr.id
            JOIN users u ON mr.user_id = u.id
            WHERE u.id = 1
    );
