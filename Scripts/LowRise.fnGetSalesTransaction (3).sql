USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransaction3
(
    @ProjectCode VARCHAR(10),
	@FromDate Date = null, 
	@ToDate Date = null, 
	@IncudePrev bit = 0
)
RETURNS TABLE
AS
RETURN
	with Options as 
	(
	select ex.transaction_id, op.option_description
	from ASG_TRANSACTION_EXTRA as ex
		inner join ASG_OPTION as op on ex.item_no = op.option_id 
	where is_option = 1 and cast(ex.trdate as date) between @FromDate and @ToDate
	
	except
	
	select transaction_id, 'Standard'
	from ASG_TRANSACTION_EXTRA as ex
		inner join ASG_OPTION as op on ex.item_no = op.option_id 
	where is_option = 1	and cast(ex.trdate as date) between @FromDate and @ToDate 
						and transaction_id in (
								select transaction_id 
								from ASG_TRANSACTION_EXTRA 
								group by transaction_id
								having count(*) > 1
								) 
	)
	, Base as
	(
		SELECT	m.NewStarProjectCode, NewStarLotNo --,mm.NewStarModelCode,
				, isnull(p.FirstName, '') as PurchaserFirstName, isnull(p.eMail, '') as PurchaserEMail
				, left(t.ELEVATION, 1) as Elevation --mm.Elevation
				, CONCAT(cmpAgent.name, cmpAgent.lastname) as SalesAgent, t.repersentative as Representive
				, t.Baseprice as BasePrice, t.currentmodelprice as ModelPrice, t.TotalPrice, t.lot_price_prem as PremiumPrice
				, t.transaction_date as TransactionDate, isnull(t.target_date, '01-01-1900') as TargetDate, isnull(t.closeingdate, '01-01-1900') as ClosingDate, 
				isnull(t.expire_date, '01-01-1900') as ExpiryDate
				, t.transaction_id as TransactionID, prj.project_name AS ProjectName
				, m.NewStarCommunityName
				, T.MODEL_NAME, mm.SalefishModelNo, mm.SalefishModelName, t.ELEVATION as elev--, SalefishLotNo, SalefishLotID
				, t.template_id, opt.option_description,/* mm.NewStarModelName,*/ opt.transaction_id, t.salesnote as SalesNote
		FROM transaction_queued_Q(null, null, 1, null, null, @ProjectCode, null) t
			   CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) as p 
			   left join ASG_PROJECT prj on t.Prj = prj.PROJECT_ID
			   left	join ASG_COMPANY cmp on cmp.company_id = t.COMPANY_ID
			   left join ASG_COMPANY_AGENT cmpAgent on cmpAgent.agent_id = t.agent_id
			   left join NewStar.ProjctToCommunityMap as m on m.SalefishProjectID = prj.PROJECT_ID
			   left join Options as opt on t.transaction_id = opt.transaction_id 
			   --left join NewStar.ModelMap as mm on mm.SalefishModelName = T.MODEL_NAME and mm.Elevation = left(t.ELEVATION, 1) and (mm.SalefishOption = opt.option_description) -- or mm.SalefishOption = 'Standard') -- and ex.Description <> 'Standard'))
			   left join NewStar.LotMap as l on l.SalefishLotID = t.lot_id

		where (cast(t.transaction_date as date) >= @FromDate or @FromDate is null) and 
			  (cast(t.transaction_date as date) <= @ToDate   or @ToDate   is null)  
			  and salesstatus = 3
			  and ( t.transaction_id not in (select TransactionID from NewStar.TransferLog) or @IncudePrev = 1)
	)
	, TransactionIDs as
	(
		select TransactionID
		from base
		group by TransactionID
		having count(*) > 1
	)
	, OrderedOptions as
	(
		select TransactionID, LEFT(option_description, 3) as DescAbbr
		from Base
		where TransactionID in (select TransactionID from TransactionIDs)

	)
	, CombinedOptions as
	(
	select TransactionID, STRING_AGG(DescAbbr, '/') as Options 
	from OrderedOptions
	where TransactionID in (select TransactionID from TransactionIDs)
	GROUP BY TransactionID
	)
	select --Base.* 
	distinct
	NewStarProjectCode, NewStarLotNo, NewStar.fnGetNewstarModelCode(SalefishModelNo, isnull(o.Options, Base.option_description), Elevation) as NewStarModelCode
	--, base.NewStarModelCode as x , base.option_description
	--, base.NewStarModelName, base.SalefishModelName, SalefishModelNo
	, PurchaserFirstName, PurchaserEMail, Elevation, Representive, TransactionDate, TargetDate, ClosingDate, ExpiryDate, Base.TransactionID, Base.SalesNote
	from Base
		left join CombinedOptions as o on o.TransactionID = Base.TransactionID
go

select *
from NewStar.fnGetSalesTransaction3('A0368', '3/1/2022', '6/30/2022', 1) --TH1801E0A
order by NewStarLotNo



select distinct
/*
transaction_id as id, option_description, o.Options, --NewStarModelCode, SalefishModelNo, SalefishModelName, NewStarModelName, MODEL_NAME, elev, option_description, 
	  NewStar.fnGetNewstarModelCode(SalefishModelNo, option_description, Elevation) as x
	, NewStar.fnGetNewstarModelCode(SalefishModelNo, o.Options, Elevation) as y
	*/
	 options, t. option_description, NewStarProjectCode, NewStarLotNo, NewStar.fnGetNewstarModelCode(SalefishModelNo, t.option_description, Elevation) as NewStarModelCode, t.NewStarModelCode,
	 PurchaserFirstName, PurchaserEMail, Elevation, Representive, TransactionDate, TargetDate, ClosingDate, ExpiryDate, t.TransactionID 
from NewStar.fnGetSalesTransaction('A0369', '1/1/2022', '5/30/2022') as t
	left join [NewStar].[fnCombineOptions] ('A0369', '01/1/2022', '05/30/2022') as o on o.TransactionID = t.TransactionID
where NewStar.fnGetNewstarModelCode(SalefishModelNo, option_description, Elevation) <> NewStarModelCode
order by t.TransactionID

select * from transaction_queued_Q(null, null, 1, null, null, 'A0369', null)  where transaction_date between '3/2/2022' and '3/2/2022' order by firstname

select * from NewStar.Model -- where Description like '%fair%' 
order by Description
select * from V_TEMPLATE where PROJECT_ID = 'A0368' order by MODEL_NAME


