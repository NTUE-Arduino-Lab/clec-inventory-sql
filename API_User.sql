IF SCHEMA_ID('web') IS NULL THEN
	EXECUTE('CREATE SCHEMA web');
END IF


IF USER_ID('clec') IS NULL THEN
	CREATE USER 'clec'@'%' IDENTIFIED BY 'jCLP4x';
END IF

/*
	Grant execute permission to created users
*/
GRANT ALL PRIVILEGES ON web.* TO 'clec'@'%';
GRANT ALL PRIVILEGES ON inventory.* TO 'clec'@'%';
GO

create DATABASE inventory;