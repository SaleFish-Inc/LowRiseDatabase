USE [LSALiveNEW]
GO

CREATE OR ALTER FUNCTION [NewStar].[fnCombineOptions]
(
    @ProjectCopde VARCHAR(10),
	@FromDate Date = null, 
	@ToDate Date = null
)
returns @reuslt TABLE 
	(
		TransactionID int,
		Options varchar(20)
	)
AS
BEGIN
	declare @optionString varchar(100) --=''

	;
	with Options as
	(
		select TransactionID
		from NewStar.fnGetSalesTransaction(@ProjectCopde, @FromDate, @ToDate)
		group by TransactionID
		having count(*) > 1
	)
	, OrderedOptions as
	(
		select TransactionID, LEFT(option_description, 3) as DescAbbr
		from NewStar.fnGetSalesTransaction(@ProjectCopde, @FromDate, @ToDate)
		where TransactionID in (select TransactionID from Options)

	)
	insert into @reuslt
	select TransactionID, STRING_AGG(DescAbbr, '/') 
	from OrderedOptions
	where TransactionID in (select TransactionID from Options)
	GROUP BY TransactionID

	return 
END
