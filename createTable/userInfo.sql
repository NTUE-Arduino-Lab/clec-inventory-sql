CREATE TABLE inventory.userInfo
(
	Account CHAR(50) PRIMARY KEY NOT NULL UNIQUE,
	Passwd CHAR(255) NOT NULL
);
INSERT INTO inventory.userInfo(Account,Passwd)
VALUES(N'admin',SHA2(jCLP4x))