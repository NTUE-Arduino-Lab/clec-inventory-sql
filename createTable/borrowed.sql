CREATE TABLE inventory.borrowed
(
	ObjectId VARCHAR(18) NOT NULL,
	borrowDate DATE NOT NULL,
	Name VARCHAR(50) NOT NULL,
	Phone VARCHAR(10) NOT NULL,
	borrowDeal VARCHAR(50) NOT NULL,
	returnDate DATE NOT NULL,
	returnDeal VARCHAR(50) NOT NULL,
	PRIMARY KEY (ObjectId, borrowDate),
	FOREIGN KEY(ObjectId) REFERENCES inventory(ObjectId)
);