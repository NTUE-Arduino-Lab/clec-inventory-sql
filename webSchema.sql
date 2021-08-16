/*login*/
CREATE PROCEDURE `post_Login`(IN inJson JSON)
BEGIN
	declare InAccount varchar(50);
	declare InPasswd varchar(255);
    
	set InAccount = inJson ->> '$.Account';
    set InPasswd = SHA2(inJson ->> '$.Passwd',224);
    
	IF INPasswd = (SELECT Passwd FROM inventory.userInfo WHERE InPasswd = Passwd AND InAccount = Account)
	THEN
		select JSON_OBJECT('message',True);
	END IF;
END

/*get objects*/
CREATE PROCEDURE `get_Objects`()
BEGIN
SELECT JSON_ARRAYAGG(JSON_OBJECT('id',ObjectId,'year',Year,'appellation',Appellation,'buydate',BuyDate,'source',Source,'unit',Unit,'keeper',Keeper,'status',Status,'note',Note))
FROM inventory.inventory;
END

/*get objects*/
CREATE PROCEDURE `get_instock_Objects`()
BEGIN
SELECT JSON_ARRAYAGG(JSON_OBJECT('id',ObjectId,'year',Year,'appellation',Appellation,'buydate',BuyDate,'source',Source,'unit',Unit,'keeper',Keeper,'status',Status,'note',Note))
FROM inventory.inventory
where Status = 'in stock';
END

/*get object*/
CREATE PROCEDURE `get_Object`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	set InObjectId = inJson ->> '$.id';
	select JSON_OBJECT('id',ObjectId,'year',Year,'appellation',Appellation,'buydate',BuyDate,'source',Source,'unit',Unit,'keeper',Keeper,'status',Status,'note',Note)
	from inventory.inventory
	where ObjectId = InObjectId;
END

/*create object*/
CREATE PROCEDURE `post_Object`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	declare InYear int;
	declare InAppellation varchar(50);
	declare InBuyDate date;
	declare InSource varchar(50);
	declare InUnit varchar(50);
	declare InKeeper varchar(50);
	declare InStatus varchar(9);
	declare InNote varchar(50);
	set InObjectId = inJson ->> '$.id';
	set InYear = inJson ->> '$.year';
	set InAppellation = inJson ->> '$.appellation';
	set InBuyDate = cast(inJson ->> '$.buydate' as date);
	set InSource = inJson ->> '$.source';
	set InUnit = inJson ->> '$.unit';
	set InKeeper = inJson ->> '$.keeper';
	set InStatus = inJson ->> '$.status';
	set InNote = inJson ->> '$.note';
	insert into inventory.inventory(ObjectId,Year,Appellation,BuyDate,Source,Unit,Keeper,Status,Note)
	values(InObjectId,InYear,InAppellation,InBuyDate,InSource,InUnit,InKeeper,InStatus,InNote);
	CALL web.`get_Object`(JSON_OBJECT('id',InObjectId));
END

/*edit object*/
CREATE PROCEDURE `patch_Object`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	declare InYear int;
	declare InAppellation varchar(50);
	declare InBuyDate date;
	declare InSource varchar(50);
	declare InUnit varchar(50);
	declare InKeeper varchar(50);
	declare InNote varchar(50);
	set InObjectId = inJson ->> '$.id';
	set InYear = inJson ->> '$.year';
	set InAppellation = inJson ->> '$.appellation';
	if InBuyDate != null
	then set InBuyDate = cast(inJson ->> '$.buydate' as date);
    end if;
	set InSource = inJson ->> '$.source';
	set InUnit = inJson ->> '$.unit';
	set InKeeper = inJson ->> '$.keeper';
	set InNote = inJson ->> '$.note';
	update inventory.inventory i
	set
	i.Year = COALESCE(InYear,i.Year),
	i.Appellation = COALESCE(InAppellation,i.Appellation),
	i.BuyDate = COALESCE(InBuyDate,i.BuyDate),
	i.Source = COALESCE(InSource,i.Source),
	i.Unit = COALESCE(InUnit,i.Unit),
	i.Keeper = COALESCE(InKeeper,i.Keeper),
	i.note = COALESCE(InNote,i.note)
	where i.ObjectId = InObjectId;
	CALL web.`get_Object`(JSON_OBJECT('id',InObjectId));
END

/*delete object*/
CREATE PROCEDURE `delete_Object`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	set InObjectId = inJson ->> '$.id';
	delete from inventory.inventory where ObjectId = InObjectId;
	select JSON_OBJECT('message','Success');
END

/*get borrow*/
CREATE PROCEDURE `get_Borrow`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	set InObjectId = inJson ->> '$.id';
	select JSON_OBJECT('id',ObjectId,'date',borrowDate,'name',Name,'phone',Phone,'borrowDeal',borrowDeal)
	from inventory.borrowing
	where ObjectId = InObjectId;
END

/*create borrow*/
CREATE PROCEDURE `post_Borrow`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	declare InBorrowDate date;
	declare InName varchar(50);
	declare InPhone varchar(10);
	declare InBorrowDeal varchar(50);
	set InObjectId = inJson ->> '$.id';
	set InBorrowDate = cast(inJson ->> '$.date' as date);
	set InName = inJson ->> '$.name';
	set InPhone = inJson ->> '$.phone';
	set InBorrowDeal = inJson ->> '$.borrowdeal';
	insert into inventory.borrowing(ObjectId,borrowDate,Name,Phone,borrowDeal)
	values(InObjectId,InBorrowDate,InName,InPhone,InBorrowDeal);
	update inventory.inventory
	set Status = 'borrowing'
	where ObjectId = InObjectId;
	call web.`get_Borrow`(JSON_OBJECT('id',InObjectId));
END

/*get borrowing*/
CREATE PROCEDURE `get_Borrowing`()
BEGIN
SELECT JSON_ARRAYAGG(JSON_OBJECT('id',i.ObjectId,'appellation',i.Appellation,'date',b.borrowDate,'name',b.Name,'phone',b.phone,'borrowDeal',b.borrowDeal))
FROM inventory.inventory i,inventory.borrowing b
where i.ObjectId = b.ObjectId;
END

/*get return*/
CREATE PROCEDURE `get_Return`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	declare InReturnDate date;
	set InObjectId = inJson ->> '$.id';
	set InReturnDate = cast(inJson ->> '$.date' as date);
	select JSON_OBJECT('id',ObjectId,'borrowdate',borrowDate,'name',Name,'phone',Phone,'borrowDeal',borrowDeal,'returndate',returnDate,'return',returnDeal)
	from inventory.borrowed
	where ObjectId = InObjectId and returnDate = InReturnDate;
END

/*create return*/
CREATE PROCEDURE `post_Return`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	declare InReturnDate date;
	declare InReturnDeal varchar(50);
	set InObjectId = inJson ->> '$.id';
	set InReturnDate = cast(inJson ->> '$.date' as date);
	set InReturnDeal = inJson ->> '$.returndeal';
	insert into inventory.borrowed(ObjectId,borrowDate,Name,Phone,borrowDeal,returnDate,returnDeal)
	select ObjectId,borrowDate,Name,Phone,borrowDeal,InReturnDate,InReturnDeal
	from inventory.borrowing
	where ObjectId = InObjectId;
	delete from inventory.borrowing where ObjectId = InObjectId;
	update inventory.inventory
	set Status = 'in stock'
	where ObjectId = InObjectId;
	call web.`get_Return`(JSON_OBJECT('id',InObjectId,'date',InReturnDate));
END

/*search*/
CREATE PROCEDURE `get_Search`(IN inJson JSON)
BEGIN
	declare Keyword varchar(50);
	set Keyword = inJson ->> '$.keyword';
	SELECT JSON_ARRAYAGG(JSON_OBJECT('id',ObjectId,'year',Year,'appellation',Appellation,'buydate',BuyDate,'source',Source,'unit',Unit,'keeper',Keeper,'status',Status,'note',Note))
	FROM inventory.inventory
	WHERE Appellation LIKE '%'+Keyword+'%'
	OR Keeper LIKE '%'+Keyword+'%'
	OR Unit LIKE '%'+Keyword+'%'
	OR Source LIKE '%'+Keyword+'%';
END

/*get item history*/
CREATE PROCEDURE `get_History`(IN inJson JSON)
BEGIN
	declare InObjectId varchar(18);
	set InObjectId = inJson ->> '$.id';
	SELECT JSON_ARRAYAGG(JSON_OBJECT('id',ObjectId,'appellation',Appellation,'borrowDate',borrowDate,'name',Name,'phone',phone,'borrowDeal',borrowDeal,'returnDate',returnDate,'returnDeal',returnDeal))
	from inventory.borrowed
	where ObjectId = InObjectId;
END