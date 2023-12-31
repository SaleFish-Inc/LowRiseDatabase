USE [LSALiveNEW]
GO
/****** Object:  StoredProcedure [NewStar].[spCombineOptions]    Script Date: 08/04/1402 01:39:04 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
select SalefishModelNo, NewStar.fnGetNewstarModelCode(SalefishModelNo, SalefishOption, Elevation), NewStarModelCode, *  from NewStar.Modelmap 
where  NewStar.fnGetNewstarModelCode(SalefishModelNo, SalefishOption,Elevation) <> NewStarModelCode
GO
*/

ALTER PROC [NewStar].[spCombineOptions]
(
    @ProjectCopde VARCHAR(10),
	@FromDate Date = null, 
	@ToDate Date = null
)
AS
BEGIN
	select * into #T
	from NewStar.fnGetSalesTransaction(@ProjectCopde, @FromDate, @ToDate)

	declare @optionString varchar(100) --=''

	;
	with Options as
	(
	select transaction_id
	from #T
	group by transaction_id
	having count(*) > 1
	)
	, OrderedOptions as
	(
	select TOP (100) PERCENT transaction_id, LEFT(option_description, 3) as DescAbbr
	from #t
	where transaction_id in (select transaction_id from Options)
	order by DescAbbr DESC
	)
	select transaction_id, STRING_AGG(DescAbbr, '/') 
	from OrderedOptions
	where transaction_id in (select transaction_id from Options)
	GROUP BY transaction_id

	SELECT @optionString

END
