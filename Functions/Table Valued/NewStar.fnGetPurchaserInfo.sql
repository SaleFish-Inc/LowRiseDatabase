USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetPurchaserInfo
(
	@TransactionID int,
	@eMail varchar(50)
)
returns table
--WITH SCHEMABINDING
as
return
SELECT top (1) *
FROM  NewStar.vwPurchaser
WHERE TransactionID = @TransactionID and email = @eMail
order by TransactionID DESC
go