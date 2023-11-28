USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetPurchasers
(
	@TransactionID int
)
returns table
--WITH SCHEMABINDING
as
return
SELECT *
FROM   vwPurchaser
WHERE  TransactionID = @TransactionID
go