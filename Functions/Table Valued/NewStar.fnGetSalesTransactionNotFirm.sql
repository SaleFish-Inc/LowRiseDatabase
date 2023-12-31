USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransactionNotFirm
(
    @ProjectCode VARCHAR(10),
	@FromDate DATE = NULL, 
	@ToDate DATE = NULL, 
	@IncudePrev BIT = 0
)
RETURNS TABLE
AS
RETURN
	WITH Options AS 
	(
	SELECT ex.transaction_id, op.option_description
	FROM dbo.ASG_TRANSACTION_EXTRA AS ex
		INNER JOIN dbo.ASG_OPTION AS op ON ex.item_no = op.option_id 
	WHERE /*is_option = 1 AND */ CAST(ex.trdate AS DATE) BETWEEN @FromDate AND @ToDate
	
	EXCEPT
	
	SELECT transaction_id, 'Standard'
	FROM dbo.ASG_TRANSACTION_EXTRA AS ex
		INNER JOIN dbo.ASG_OPTION AS op ON ex.item_no = op.option_id 
	WHERE /*is_option = 1 AND */ CAST(ex.trdate AS DATE) BETWEEN @FromDate AND @ToDate 
						AND transaction_id IN (
								SELECT transaction_id 
								FROM dbo.ASG_TRANSACTION_EXTRA 
								GROUP BY transaction_id
								HAVING COUNT(*) > 1
								) 
	)
	, Base AS	
	(
		SELECT	prj.project_name AS ProjectName, cm.NewStarProjectCode, cm.NewStarCommunityName, cm.NewStarCommunityID
				, SalefishLotNo, NewStarLotNo 
				, vt.MODEL_NUMBER AS SalefishModelNo, vt.MODEL_NAME AS SalefishModelName, t.[ELEVATION] AS Elevation
				, ISNULL(p.FirstName, '') AS PurchaserFirstName, ISNULL(p.[LastName], '') AS PurchaserLastName, p.[BirthDay], ISNULL(p.eMail, '') AS PurchaserEMail
				, p.[CountryName], p.[StateCode], p.[CityName], p.[Address], p.[Zip]
				, IIF(LEFT(p.[HomePhone], 1) = '+', SUBSTRING([p].[HomePhone], 4, LEN([p].[HomePhone])), [p].[HomePhone]) AS PurchaserHomePhone
				, IIF(LEFT(p.[Mobile], 1) = '+', SUBSTRING([p].[Mobile], 4, LEN([p].[Mobile])), [p].[Mobile]) AS PurchaserMobile
				, t.currentmodelprice AS UnitPrice, t.lot_price_prem AS UnitPremium
				, t.Baseprice AS BasePrice, t.currentmodelprice AS ModelPrice, t.TotalPrice
				, CAST(t.[TotalPrice] - [t].[currentmodelprice] - t. [lot_price_prem] - [t].[grading_price] - t.[upgrade_price] AS INT) AS OptionPrice
				, t.transaction_id AS TransactionID, t.transaction_date AS TransactionDate
				, ISNULL(t.closeingdate, '01-01-1900') AS ClosingDate, ISNULL(t.irrevocabledate, '01-01-1900') AS IrrevocableDate
				, ISNULL(t.target_date, '01-01-1900') AS TargetDate, ISNULL(t.expire_date, '01-01-1900') AS ExpiryDate
				, t.repersentative AS Representive
				, t.salesnote AS SalesNote, IsInvestor
				, fullname AS AgentName, AgentEmail, AgentPhone, AgentCommission
				, t.[lending_institute] AS LendingInstitue, t.[mortgage_value] AS MortgageAmount, t.[mortgage_approv_date] AS MortgageApproveDate, t.[Institution_Number]
		FROM dbo.transaction_queued_Q(NULL, NULL, 1, NULL, NULL, @ProjectCode, NULL) t
			   CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) AS p 
			   INNER JOIN dbo.V_LOT as vl on t.lot_id = vl.LOT_ID
			   LEFT JOIN dbo.ASG_PROJECT prj ON t.Prj = prj.PROJECT_ID
			   LEFT JOIN NewStar.ProjctToCommunityMap AS cm ON cm.SalefishProjectID = prj.PROJECT_ID
			   LEFT JOIN NewStar.LotMap AS l ON l.SalefishLotID = t.lot_id
			   LEFT JOIN dbo.[V_TEMPLATE] AS vt ON vt.[TEMPLATE_ID] = t.[template_id] 

		WHERE (CAST(t.transaction_date AS DATE) >= @FromDate OR @FromDate IS NULL) AND 
		      (CAST(t.transaction_date AS DATE) <= @ToDate   OR @ToDate   IS NULL) AND 
			  ( 
				t.transaction_id NOT IN (SELECT TransactionID FROM NewStar.TransferLog WHERE IsRollBacked = 0) 
				OR 
				@IncudePrev = 1
			  )
			AND vl.LOT_STATUS IN (3, 12) -- Sold, Override to sold
	)
	, CombinedOptions AS
	(
	SELECT TransactionID, STRING_AGG(LEFT(option_description, 3), '/') AS Options, STRING_AGG([option_description], ';')  AS Description
	FROM [Base] AS b
		LEFT JOIN Options AS opt ON b.[TransactionID] = opt.[transaction_id] 
	GROUP BY TransactionID
	)

	SELECT DISTINCT o.Options, o.[Description],
		NewStarProjectCode, ProjectName AS SalefishProjectName, NewStarCommunityName, NewStarCommunityID
		, SalefishLotNo, NewStarLotNo, LEFT(Elevation, 1) AS Elevation, SalefishModelNo, SalefishModelName
		, NewStar.fnGetNewstarModelCode(@ProjectCode, SalefishLotNo, SalefishModelNo, o.Options, o.[Description], Elevation) AS NewStarModelCode
		, PurchaserFirstName, PurchaserLastName, PurchaserEMail, PurchaserHomePhone, PurchaserMobile
		, Address, CityName, Zip, CountryName, StateCode, BirthDay
		, UnitPrice, UnitPremium, BasePrice, ModelPrice, TotalPrice, OptionPrice
		, TransactionDate, ClosingDate, TargetDate, ExpiryDate, IrrevocableDate
		, Representive, Base.TransactionID, SalesNote, IsInvestor
		, AgentName, AgentEmail, AgentPhone, AgentCommission
		, LendingInstitue, MortgageAmount, MortgageApproveDate
		
		/*
		--, base.NewStarModelCode as x , base.option_description
		--, base.NewStarModelName, base.SalefishModelName
		, SalefishModelNo, SalefishModelName
		, PurchaserFirstName, PurchaserEMail, LEFT(Elevation, 1) AS Elevation, Representive, TransactionDate, TargetDate, ClosingDate, ExpiryDate, Base.TransactionID, Base.SalesNote
		*/
	FROM Base
		LEFT JOIN CombinedOptions AS o ON o.TransactionID = Base.TransactionID
GO

SELECT *
FROM LSALiveNEW.NewStar.fnGetSalesTransactionNotFirm('A0490', '01-01-2022', '12-30-2023', 1) AS t
--	LEFT JOIN NewStar.WestAndPost AS w ON w.Model = NewStarModelCode
--WHERE NewStarModelCode not IN (SELECT Model FROM NewStar.WestAndPost )
ORDER BY NewStarLotNo

/*

select * from transaction_queued_Q(null, null, 1, null, null, 'A0369', null)  where transaction_date between '3/2/2022' and '3/2/2022' order by firstname

select * from NewStar.Model -- where Description like '%fair%' 
order by Description
select * from V_TEMPLATE where PROJECT_ID = 'A0368' order by MODEL_NAME

*/