USE [LSALiveNEW]
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransactionForNewstarEnterpriseFlatted
(
	@ProjectID VARCHAR(10),
	@FromDate DATE,
	@ToDate DATE
)
RETURNS @t TABLE 
		(
			--OperatingUnit				VARCHAR(30),
			Project						VARCHAR(50),
			Lot							VARCHAR(100), 
			Model						VARCHAR(30), 
			Elevation					VARCHAR(20), 
			ContractDate				CHAR(10),
			FinalSaleDate				CHAR(10),
			BaseModel					INT,
			InvestmentCheckbox			CHAR(1),
			HomePhone					VARCHAR(20), 
			eEmail						VARCHAR(50), 
			FirstName					VARCHAR(30),
			LastName					VARCHAR(50),
			FirstTentativeClosingDate	CHAR(10),
			MortgageCompanyCode			VARCHAR(50),
			MortgageReceivedDate		CHAR(10),
			MortgageAmount				INT,
			Notes						VARCHAR(100),	
			AgentName					VARCHAR(50),
			AgentEmail					VARCHAR(50),
			AgentCommission				NUMERIC(4,2),
			AgentPhone					VARCHAR(20),
			DepositDueDates				VARCHAR(1000), 
			DepositAmounts				VARCHAR(1000),
			DepositMemos				VARCHAR(1000),
			PaymentMemos				VARCHAR(1000),
			CoBuyerFirstNames			VARCHAR(1000),
			CoBuyerLastNames			VARCHAR(1000),
			CoBuyerEmails				VARCHAR(1000)
		)
AS
BEGIN

;
WITH Transactions AS
(
SELECT	-- 'HB' AS OperatingUnit, 
		[NewStarCommunityID] AS Project, NewStarLotNo AS Lot, NewStarModelCode AS Model, [t].[Elevation]--, NULL AS CustomerCode
		, FORMAT([t].[TransactionDate], 'MM/dd/yyyy', 'en-us') AS ContractDate
		, FORMAT([t].IrrevocableDate, 'MM/dd/yyyy', 'en-us') AS FinalSaleDate
		, t.[BasePrice] AS BaseModel, IIF([t].[IsInvestor]=1, 'Y', 'N') AS InvestmentCheckbox
		, IIF(t.[PurchaserHomePhone]='' OR t.[PurchaserHomePhone] IS NULL, t.PurchaserMobile, [PurchaserHomePhone]) AS HomePhone
		, [t].PurchaserEMail AS EMail, t.PurchaserFirstName AS FirstName, t.PurchaserLastName AS LastName
		, FORMAT([t].[ClosingDate], 'MM/dd/yyyy', 'en-us') AS FirstTentativeClosingDate
		, IIF(t.LendingInstitue='0', NULL, LendingInstitue) AS MortgageCompanyCode
		, FORMAT(t.MortgageApproveDate, 'MM/dd/yyyy', 'en-us') AS MortgageReceivedDate
		, IIF(t.MortgageAmount=0, NULL, [t].[MortgageAmount]) AS MortgageAmount
		, t.[SalesNote] AS Notes
		, AgentName, [AgentEmail], [AgentCommission], [AgentPhone]
		, t.[TransactionID]
FROM [NewStar].fnGetSalesTransactionNotFirm(@ProjectID, @FromDate, @ToDate, 1) AS t
)

, Deposits AS 
(
SELECT [TransactionID]
	, STRING_AGG(FORMAT(CAST(s.date AS DATE), 'MM/dd/yyyy', 'en-US') , ';') WITHIN GROUP (ORDER BY s.date) AS DepositDueDates
	, STRING_AGG(s.[Amount] , ';') WITHIN GROUP (ORDER BY s.date) AS DepositAmounts
	, STRING_AGG(s.[Note], ';') WITHIN GROUP (ORDER BY s.date) AS DepositMemos
	, STRING_AGG(s.[DepositNoe], ';') WITHIN GROUP (ORDER BY s.date) AS PaymentMemos
FROM Transactions AS t
	CROSS APPLY [NewStar].[fnGetPaymentSchedule](t.[TransactionID]) AS s
GROUP BY [TransactionID]
)

, CoBuyers AS
(
SELECT t.[TransactionID]
	, STRING_AGG(s.[EMail] , ';') AS eMails, STRING_AGG(s.FirstName , ';') AS FirstNames, STRING_AGG(s.[LastName] , ';') AS LastNames
FROM Transactions AS t
	CROSS APPLY [NewStar].[fnGetCoBuyers](t.[TransactionID], t.[EMail], t.FirstName) AS s
GROUP BY t.[TransactionID]
)

/*
SELECT t.[TransactionID], LotNo
	, STRING_AGG(opt.[option_description], ';') AS Options
	INTO #Options
FROM #Sales AS t
	LEFT JOIN [dbo].[ASG_TRANSACTION_EXTRA] AS x ON x.[transaction_id] = t.[TransactionID]
	LEFT JOIN [ASG_OPTION] AS opt ON opt.[option_id] = x.[item_no]-- AND x.[is_option] = 1
GROUP BY t.[TransactionID], LotNo
*/

INSERT INTO @t 
		(	--OperatingUnit				VARCHAR(30),
			Project, Lot, Model, Elevation, ContractDate, FinalSaleDate, BaseModel, InvestmentCheckbox, 
			HomePhone, eEmail, FirstName, LastName, FirstTentativeClosingDate, 
			MortgageCompanyCode, MortgageReceivedDate, MortgageAmount, Notes, 
			AgentName, AgentEmail, AgentCommission, AgentPhone,
			DepositDueDates, DepositAmounts, DepositMemos, PaymentMemos, 
			CoBuyerFirstNames, CoBuyerLastNames, CoBuyerEmails				
		)

SELECT Project, Lot, Model, Elevation, ContractDate, FinalSaleDate, BaseModel, InvestmentCheckbox
	, HomePhone, eMail, FirstName, LastName, FirstTentativeClosingDate
	, MortgageCompanyCode, MortgageReceivedDate, MortgageAmount, Notes
	, AgentName, AgentEmail, AgentCommission, AgentPhone
	, d.[DepositDueDates], d.[DepositAmounts], d.[DepositMemos], d.[PaymentMemos]
	, c.[FirstNames], c.[LastNames], c.[eMails]
	--, o.Options
FROM Transactions AS t
	LEFT JOIN Deposits AS d ON d.[TransactionID] = t.[TransactionID]
	LEFT JOIN CoBuyers AS c ON c.[TransactionID] = t.[TransactionID]
  --LEFT JOIN #Options  AS o ON o.[TransactionID] = t.[TransactionID]
ORDER BY Lot

RETURN
END

GO

SELECT * 
FROM NewStar.fnGetSalesTransactionForNewstarEnterpriseFlatted('A0490', '01-01-2022', '12-30-2023')
ORDER BY CAST(ContractDate AS DATE)
