USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetCoBuyers
(
	@TransactionID int,
	@eMail varchar(50),
	@firstName varchar(50)
)
returns table
--WITH SCHEMABINDING
as
return
SELECT *
FROM  NewStar.vwPurchaser
WHERE TransactionID = @TransactionID and (email <> @eMail or FirstName <> @firstName)
go

select * from NewStar.fnGetPurchaserInfo(175012, 'Ratnavis@yahoo.com')
select * from NewStar.fnGetCoBuyers		(175012, 'Ratnavis@yahoo.com', 'Ratna , R')
select * from NewStar.fnGetPurchasers	(175012)