ALTER   FUNCTION [NewStar].[fnGetSalesTransactionForNewstarSale_Test]
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
		SELECT	cm.NewStarProjectCode, NewStarLotNo 
				, t.[ELEVATION] AS Elevation
				, ISNULL(p.FirstName, '') AS PurchaserFirstName, ISNULL(p.[LastName], '') AS PurchaserLastName, ISNULL(p.eMail, '') AS PurchaserEMail
				, p.[Address], p.[CityName], p.[Zip], p.[CountryName], p.[StateCode], p.[BirthDay], p.[eMail]
				, IIF(LEFT(p.[HomePhone], 1) = '+', SUBSTRING([p].[HomePhone], 4, LEN([p].[HomePhone])), [p].[HomePhone]) AS PurchaserHomePhone
				, IIF(LEFT(p.[Mobile], 1) = '+', SUBSTRING([p].[Mobile], 4, LEN([p].[Mobile])), [p].[Mobile]) AS PurchaserMobile
				, t.currentmodelprice AS UnitPrice, t.lot_price_prem AS UnitPremium
				, t.Baseprice AS BasePrice, t.currentmodelprice AS ModelPrice, t.TotalPrice
				, CAST(t.[TotalPrice] - [t].[currentmodelprice] - t. [lot_price_prem] - [t].[grading_price] - t.[upgrade_price] AS INT) AS OptionPrice
				, t.transaction_date AS TransactionDate, ISNULL(t.closeingdate, '01-01-1900') AS ClosingDate
				, ISNULL(t.target_date, '01-01-1900') AS TargetDate, ISNULL(t.expire_date, '01-01-1900') AS ExpiryDate
				, vt.MODEL_NUMBER AS SalefishModelNo, vt.MODEL_NAME AS SalefishModelName
				, t.repersentative AS Representive
				, t.transaction_id AS TransactionID, prj.project_name AS ProjectName
				, cm.NewStarCommunityName
				, t.salesnote AS SalesNote
		FROM dbo.transaction_queued_Q(NULL, NULL, 1, NULL, NULL, @ProjectCode, NULL) t
			   CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) AS p 
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
			--  AND salesstatus = 3
	)
	, CombinedOptions AS
	(
	SELECT TransactionID, STRING_AGG(LEFT(option_description, 3), '/') AS Options, STRING_AGG([option_description], ';')  AS Description
	FROM [Base] AS b
			   LEFT JOIN Options AS opt ON b.[TransactionID] = opt.[transaction_id] 
	GROUP BY TransactionID
	)

	SELECT DISTINCT 
		NewStarProjectCode, NewStarLotNo--, SalefishLotNo
		, o.Options, o.[Description]
		--, base.NewStarModelCode as x , base.option_description
		--, base.NewStarModelName, base.SalefishModelName
		, SalefishModelNo, SalefishModelName
		, NewStar.fnGetNewstarModelCode(@ProjectCode, SalefishModelNo, o.Options, /*Base.option_description*/ o.[Description], Elevation) AS NewStarModelCode
		, PurchaserFirstName, PurchaserEMail, LEFT(Elevation, 1) AS Elevation, Representive, TransactionDate, TargetDate, ClosingDate, ExpiryDate, Base.TransactionID, Base.SalesNote
	/*
			NewStar.fnGetNewstarModelCodeForNewstarSale(@ProjectCode, SalefishModelNo1) AS NewStarModelCode
			, Base.* 
*/	FROM Base
		LEFT JOIN CombinedOptions AS o ON o.TransactionID = Base.TransactionID

