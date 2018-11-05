UPDATE migration_requests SET timestamp = '2018-04-04 18:18:23' 
WHERE id IN (
    SELECT id from migration_requests mr 
    LEFT JOIN requests_files rf ON mr.id = rf.request_id 
    WHERE rf.request_id IS NULL
    );
