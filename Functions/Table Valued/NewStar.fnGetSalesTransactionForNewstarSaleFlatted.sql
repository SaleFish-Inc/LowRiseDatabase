USE [LSALiveNEW]
GO

CREATE OR ALTER FUNCTION NewStar.fnGetSalesTransactionForNewstarSaleFlatted
(
	@ProjectID VARCHAR(10),
	@FromDate DATE,
	@ToDate DATE
)
RETURNS @t TABLE 
		(
		FirstName			VARCHAR(30),
		LastName			VARCHAR(50),
		Address				VARCHAR(100), 
		City				VARCHAR(30), 
		Zip					VARCHAR(20), 
		Country				VARCHAR(20), 
		BirthDate			CHAR(10), 
		HomePhone			VARCHAR(20), 
		CellPhone			VARCHAR(15), 
		HomeEmail			VARCHAR(50), 
		State				VARCHAR(20),
		FirstNames			VARCHAR(1000),
		LastNames			VARCHAR(1000),
		SameAsProspect_1	CHAR(1),
		SameAsProspect_2	CHAR(1),
		SameAsProspect_3	CHAR(1),
		SameAsProspect_4	CHAR(1),
		SameAsProspect_5	CHAR(1),
		SameAsProspect_6	CHAR(1),
		Cities				VARCHAR(200),
		States				VARCHAR(120),
		BirthDates			VARCHAR(1200),
		HomeEmails			VARCHAR(2000),
		HomePhones			VARCHAR(1000),
		CellPhones			VARCHAR(1000),
		SubdivisionName		VARCHAR(50),
		UnitNo				VARCHAR(10),
		ModelName			VARCHAR(50),
		Elevation			VARCHAR(10),
		UnitPrice			NUMERIC(18, 0),
		UnitPremium			NUMERIC(18, 0),
		IncentivesOptions	NUMERIC(18, 0),
		ContractDate		CHAR(10),
		FirstTentativeDate	CHAR(10),
		DepositTypes		VARCHAR(1000), 
		DepositDueDates		VARCHAR(1000), 
		DepositAmounts		VARCHAR(1000)
		)
AS
BEGIN

;
WITH Transactions AS 
(
SELECT PurchaserFirstName AS FirstName, PurchaserLastName AS LastName, Address, CityName AS City, Zip, CountryName AS Country, FORMAT(BirthDay, 'MM/dd/yyyy', 'en-us') AS BirthDate
		, [PurchaserHomePhone] AS HomePhone, [t].[PurchaserMobile] AS CellPhone
		, [PurchaserEMail] AS HomeEmail, StateCode AS State
		, NewStarCommunityName AS SubdivisionName, NewStarLotNo AS UnitNo, NewStarModelCode AS ModelName, [Elevation]
		, UnitPrice, UnitPremium, OptionPrice AS IncentivesOptions
		, FORMAT([TransactionDate], 'MM/dd/yyyy', 'en-us') AS ContractDate, FORMAT(ClosingDate, 'MM/dd/yyyy', 'en-us') AS FirstTentativeDate
		, [TransactionID]
FROM [NewStar].fnGetSalesTransactionNotFirm(@ProjectID, @FromDate, @ToDate, 1) AS t
)

, Deposits AS 
(
SELECT [t].[TransactionID]
	, STRING_AGG(FORMAT(CAST(s.date AS DATE), 'MM/dd/yyyy', 'en-US') , ';') WITHIN GROUP (ORDER BY s.date) AS DepositDueDates
	, STRING_AGG(CAST(s.[Amount] AS INT), ';')  WITHIN GROUP (ORDER BY s.date) AS DepositAmounts
	, STRING_AGG(ScheduleType, ';')  WITHIN GROUP (ORDER BY s.date) AS DepositTypes
FROM Transactions AS t
	CROSS APPLY [NewStar].[fnGetPaymentSchedule](t.[TransactionID]) AS s
GROUP BY [t].[TransactionID]
)

, CoBuyers AS
(
SELECT t.[TransactionID]
	, STRING_AGG(s.FirstName , ';') AS FirstNames, STRING_AGG(s.[LastName] , ';') AS LastNames
	, STRING_AGG(s.[CityName] , ';') AS Cities, STRING_AGG(s.[StateCode] , ';') AS [States]
	, STRING_AGG(FORMAT(s.[BirthDay], 'MM/dd/yyyy', 'en-us') , ';') AS [BirthDates]
	, STRING_AGG(s.[eMail] , ';') AS [HomeEmails]
	, STRING_AGG(TRIM(s.[HomePhone]) , ';') AS [HomePhones], STRING_AGG(TRIM(s.[Mobile]) , ';') AS [CellPhones]
FROM Transactions AS t
	CROSS APPLY [NewStar].[fnGetCoBuyers](t.[TransactionID], t.[HomeEmail], t.FirstName) AS s
GROUP BY t.[TransactionID]
)

INSERT INTO @t
		(
			FirstName,
			LastName,
			Address, 
			City, 
			Zip, 
			Country, 
			BirthDate, 
			HomePhone, 
			CellPhone, 
			HomeEmail,
			State,
			FirstNames,
			LastNames,
			SameAsProspect_1,
			SameAsProspect_2,
			SameAsProspect_3,
			SameAsProspect_4,
			SameAsProspect_5,
			SameAsProspect_6,
			Cities,
			States,
			BirthDates,
			HomeEmails,
			HomePhones,
			CellPhones,
			SubdivisionName,
			UnitNo,
			ModelName,
			Elevation,
			UnitPrice,
			UnitPremium	,
			IncentivesOptions,
			ContractDate,
			FirstTentativeDate,
			DepositTypes, 
			DepositDueDates, 
			DepositAmounts	
		)
SELECT t.[FirstName], t.[LastName], t.[Address], t.[City], t.zip, t.[Country], t.[BirthDate], t.[HomePhone], t.[CellPhone], t.[HomeEmail], t.[State]
	, c.[FirstNames], c.[LastNames], 'N', 'N','N','N','N','N', c.[Cities], c.[States], c.[BirthDates], c.[HomeEmails], c.[HomePhones], c.CellPhones
	, t.[SubdivisionName], t.[UnitNo], t.[ModelName], t.Elevation, t.[UnitPrice], t.[UnitPremium], t.[IncentivesOptions], t.[ContractDate], t.[FirstTentativeDate]
	, d.DepositTypes, d.[DepositDueDates], d.[DepositAmounts]
FROM Transactions AS t
	LEFT JOIN Deposits AS d ON d.[TransactionID] = t.[TransactionID]
	LEFT JOIN CoBuyers AS c ON c.[TransactionID] = t.[TransactionID]
ORDER BY t.[UnitNo]

RETURN
END

GO


SELECT * FROM NewStar.fnGetSalesTransactionForNewstarSaleFlatted('A0509', '01-01-2023', '12-30-2023')



