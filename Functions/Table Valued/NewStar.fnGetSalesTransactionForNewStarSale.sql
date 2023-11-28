USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransactionForNewstarSale
(
    @ProjectCode VARCHAR(10),
	@FromDate DATE = NULL, 
	@ToDate DATE = NULL, 
	@IncudePrev BIT = 0
)
RETURNS TABLE
AS
RETURN
	WITH Base AS
	(
		SELECT	NewStarLotNo -- ,mm.NewStarModelCode, mm.NewStarModelName
				, t.[ELEVATION]
				, ISNULL(p.FirstName, '') AS PurchaserFirstName, ISNULL(p.[LastName], '') AS PurchaserLastName, ISNULL(p.eMail, '') AS PurchaserEMail
				, p.[Address], p.[CityName], p.[Zip], p.[CountryName], p.[StateCode], p.[BirthDay], p.[eMail]
				, IIF(LEFT(p.[HomePhone], 1) = '+', SUBSTRING([p].[HomePhone], 4, LEN([p].[HomePhone])), [p].[HomePhone]) AS PurchaserHomePhone
				, IIF(LEFT(p.[Mobile], 1) = '+', SUBSTRING([p].[Mobile], 4, LEN([p].[Mobile])), [p].[Mobile]) AS PurchaserMobile
				, t.currentmodelprice AS UnitPrice, t.lot_price_prem AS UnitPremium
				, CAST(t.[TotalPrice] - [t].[currentmodelprice] - t. [lot_price_prem] - [t].[grading_price] - t.[upgrade_price] AS INT) AS OptionPrice
				, t.transaction_date AS TransactionDate, ISNULL(t.closeingdate, '01-01-1900') AS ClosingDate
				, t.transaction_id AS TransactionID--, prj.project_name AS ProjectName
				, T.MODEL_NAME AS SalefishModelName, vt.MODEL_NUMBER AS SalefishModelNo 
				, t.template_id, t.salesnote AS SalesNote
				--, t.[IsInvestor]
		FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, @ProjectCode, NULL) t
			   CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) AS p 
			   INNER JOIN dbo.V_LOT as vl on t.lot_id = vl.LOT_ID
			  -- LEFT JOIN ASG_PROJECT prj ON t.Prj = prj.PROJECT_ID
			   LEFT JOIN NewStar.LotMap AS l ON l.SalefishLotID = t.lot_id
			   LEFT JOIN [V_TEMPLATE] AS vt ON vt.[TEMPLATE_ID] = t.[template_id] AND vt.PROJECT_ID = t.[Prj]

		WHERE (CAST(t.transaction_date AS DATE) >= @FromDate OR @FromDate IS NULL) 
			  AND (CAST(t.transaction_date AS DATE) <= @ToDate   OR @ToDate   IS NULL)  
			  AND ( t.transaction_id NOT IN (SELECT TransactionID FROM NewStar.TransferLog WHERE IsRollBacked = 0) OR @IncudePrev = 1)
			  AND vl.LOT_STATUS = 3
	)

	SELECT DISTINCT NewStar.fnGetNewstarModelCodeForNewstarSale(@ProjectCode, SalefishModelNo) AS NewStarModelCode, Base.* 
	FROM Base

GO


--

SELECT * FROM [NewStar].fnGetSalesTransactionForNewStarSale('A0509', '01-01-2023', '12-09-2023', 1) AS t 
--WHERE [t].[NewStarLotNo] = '01'
ORDER BY [t].[NewStarLotNo]

/*
SELECT * FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, 'A0509', NULL) AS t WHERE t.[transaction_date] BETWEEN GETDATE()-90 AND GETDATE()

*/