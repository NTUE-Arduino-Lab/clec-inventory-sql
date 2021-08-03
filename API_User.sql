IF SCHEMA_ID('web') IS NULL BEGIN	
	EXECUTE('CREATE SCHEMA web');
END
GO

IF USER_ID('clec') IS NULL BEGIN	
	CREATE USER 'clec'@'%' WITH IDENTIFIED = 'jCLP4x';
END

/*
	Grant execute permission to created users
*/
GRANT ALL PRIVILEGES ON web.* TO 'clec'@'%';
GO