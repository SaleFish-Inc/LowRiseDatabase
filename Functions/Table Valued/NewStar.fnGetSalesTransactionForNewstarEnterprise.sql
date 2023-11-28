USE LSALiveNEW
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransactionForNewstarEnterprise
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
	FROM ASG_TRANSACTION_EXTRA AS ex
		INNER JOIN ASG_OPTION AS op ON ex.item_no = op.option_id 
	WHERE is_option = 1 AND CAST(ex.trdate AS DATE) BETWEEN @FromDate AND @ToDate
	
	EXCEPT
	
	SELECT transaction_id, 'Standard'
	FROM ASG_TRANSACTION_EXTRA AS ex
		INNER JOIN ASG_OPTION AS op ON ex.item_no = op.option_id 
	WHERE is_option = 1	AND CAST(ex.trdate AS DATE) BETWEEN @FromDate AND @ToDate 
						AND transaction_id IN (
								SELECT transaction_id 
								FROM ASG_TRANSACTION_EXTRA 
								GROUP BY transaction_id
								HAVING COUNT(*) > 1
								) 
	)
	, Base AS
	(
		SELECT	m.[NewStarCommunityID], NewStarLotNo, m.NewStarCommunityName
				, p.[FirstName], p.[LastName], ISNULL(p.eMail, '') AS eMail
				, IIF(LEFT(p.[HomePhone], 1) = '+', SUBSTRING([p].[HomePhone], 4, LEN([p].[HomePhone])), [p].[HomePhone]) AS PurchaserHomePhone
				, IIF(LEFT(p.[Mobile], 1) = '+', SUBSTRING([p].[Mobile], 4, LEN([p].[Mobile])), [p].[Mobile]) AS PurchaserMobile
				, t.[IsInvestor], LEFT(t.ELEVATION, 1) AS Elevation 
				, t.Baseprice AS BasePrice--, t.currentmodelprice AS ModelPrice, t.TotalPrice, t.lot_price_prem AS PremiumPrice
				, t.transaction_date AS TransactionDate, t.[irrevocabledate] AS [IrrecoverableDate], t.closeingdate AS ClosingDate--, ISNULL(t.expire_date, '01-01-1900') AS ExpiryDate
				--, prj.project_name AS ProjectName
				, t.transaction_id AS TransactionID
				, vt.[MODEL_NAME] AS SalefishModelName, MODEL_NUMBER AS SalefishModelNo, mm.[NewStarModelCode], mm.[NewStarModelName]
				, t.template_id, opt.option_description, t.salesnote AS SalesNote
				, t.[lending_institute] AS LendingInstitue, t.[mortgage_value] AS MortgageAmount, t.[mortgage_approv_date] AS MortageApproveDate, t.[Institution_Number]
				, t.fullname AS AgentName, t.[AgentCommission], t.[AgentEmail], t.[AgentPhone], t.[agent_id]
		FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, @ProjectCode, NULL) t
			LEFT JOIN [NewStar].[ModelMap] AS mm ON mm.[SalefishTemplateID] = t.[template_id]
			CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) AS p 
			   --LEFT JOIN ASG_PROJECT prj ON t.Prj = prj.PROJECT_ID
			LEFT JOIN NewStar.ProjctToCommunityMap AS m ON m.SalefishProjectID = t.[Prj]
			LEFT JOIN Options AS opt ON t.transaction_id = opt.transaction_id 
			LEFT JOIN NewStar.LotMap AS l ON l.SalefishLotID = t.lot_id
			LEFT JOIN [V_TEMPLATE] AS vt ON vt.[TEMPLATE_ID] = t.[template_id] AND vt.PROJECT_ID = t.[Prj]

		WHERE (CAST(t.transaction_date AS DATE) >= @FromDate OR @FromDate IS NULL) AND 
			  (CAST(t.transaction_date AS DATE) <= @ToDate   OR @ToDate   IS NULL)  
--			  and salesstatus = 3
			  AND ( t.transaction_id NOT IN (SELECT TransactionID FROM NewStar.TransferLog WHERE IsRollBacked = 0) OR @IncudePrev = 1)
	)
	, TransactionIDs AS
	(
		SELECT TransactionID
		FROM base
		GROUP BY TransactionID
		HAVING COUNT(*) > 1
	)
	, OrderedOptions AS
	(
		SELECT TransactionID, LEFT(option_description, 3) AS DescAbbr
		FROM Base
		WHERE TransactionID IN (SELECT TransactionID FROM TransactionIDs)

	)
	, CombinedOptions AS
	(
	SELECT TransactionID, STRING_AGG(DescAbbr, '/') AS Options 
	FROM OrderedOptions
	WHERE TransactionID IN (SELECT TransactionID FROM TransactionIDs)
	GROUP BY TransactionID
	)
	SELECT Base.*, o.[Options]
	/*
	DISTINCT
	NewStarProjectCode, NewStarLotNo
	--, base.NewStarModelCode as x , base.option_description
	, /*base.NewStarModelName, */base.SalefishModelName
	, SalefishModelNo, NewStar.fnGetNewstarModelCode(SalefishModelNo, ISNULL(o.Options, Base.option_description), Elevation) AS NewStarModelCode
	, PurchaserFirstName, PurchaserLastName, [Base].[HomePhone] AS PurchaserHomePhone, base.[Mobile] AS PurchaserMobile, PurchaserEMail, Elevation, Representive, TransactionDate, TargetDate, ClosingDate, ExpiryDate, Base.TransactionID, Base.SalesNote
	, [Base].[BasePrice], IIF([Base].[IsInvestor]=1, 'Y', 'N') AS IsInvestor
	, base.[LendingInstitue], base.[MortgageAmount], base.[MortageApproveDate]
	, [agentname] AS AgentName, [AgentCommission], [AgentEmail], [AgentPhone]
	*/
	FROM Base
		LEFT JOIN CombinedOptions AS o ON o.TransactionID = Base.TransactionID
		
GO


SELECT *
FROM [NewStar].fnGetSalesTransactionForNewstarEnterprise('A0490', '01-01-2022', '12-28-2023', 1) AS t
order by NewStarModelCode
/*
SELECT * FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, 'A0368', NULL) AS t WHERE t.[transaction_date] BETWEEN GETDATE()-90 AND GETDATE()

*/