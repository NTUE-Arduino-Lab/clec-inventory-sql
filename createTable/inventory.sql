CREATE TABLE inventory.inventory
(
	ObjectId VARCHAR(18) PRIMARY KEY NOT NULL UNIQUE,
	Year INT,
	Appellation VARCHAR(50),
	BuyDate DATE,
	Source VARCHAR(50),
	Unit VARCHAR(50),
	Keeper VARCHAR(50),
	Status VARCHAR(9),
	note VARCHAR(50)
);