USE [LSALiveNEW]
GO
/****** Object:  StoredProcedure [NewStar].[spCombineOptions]    Script Date: 5/16/2022 7:06:29 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select SalefishModelNo, NewStar.fnGetNewstarModelCode(SalefishModelNo, SalefishOption, Elevation), NewStarModelCode, *  from NewStar.Modelmap 
where  NewStar.fnGetNewstarModelCode(SalefishModelNo, SalefishOption,Elevation) <> NewStarModelCode
GO
*/

CREATE FUNCTION [NewStar].[fnCombineOptions]
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
		select transaction_id
		from NewStar.fnGetSalesTransaction(@ProjectCopde, @FromDate, @ToDate)
		group by transaction_id
		having count(*) > 1
	)
	, OrderedOptions as
	(
		select transaction_id, LEFT(option_description, 3) as DescAbbr
		from NewStar.fnGetSalesTransaction(@ProjectCopde, @FromDate, @ToDate)
		where transaction_id in (select transaction_id from Options)

	)
	insert into @reuslt
	select transaction_id, STRING_AGG(DescAbbr, '/') 
	from OrderedOptions
	where transaction_id in (select transaction_id from Options)
	GROUP BY transaction_id

	return 
END
go

select * from  [NewStar].[fnCombineOptions] ('A0369', '05/1/2022', '05/30/2022')
