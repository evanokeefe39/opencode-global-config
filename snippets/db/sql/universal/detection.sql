-- Universal detection (DB version, database name, current user)
SELECT 
    version() AS db_version,
    current_database() AS database_name,
    current_user AS current_user;