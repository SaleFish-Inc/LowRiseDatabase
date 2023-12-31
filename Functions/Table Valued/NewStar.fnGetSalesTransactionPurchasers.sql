USE [LSALiveNEW]
GO
/****** Object:  UserDefinedFunction [NewStar].[fnGetSalesTransactionPurchasers]    Script Date: 5/25/2022 12:27:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER FUNCTION [NewStar].[fnGetSalesTransactionPurchasers]
(
    @ProjectCopde VARCHAR(10),
	@FromDate Date = null, 
	@ToDate Date = null
)
RETURNS TABLE
AS
RETURN
    SELECT isnull(p.FirstName, '') as PurchaserFirstName, isnull(p.LastName, '') as PurchaserLastName, isnull(p.BirthDay, '') as PurchaserBirthDay 
		   , isnull(p.CountryCode, '') as PurchaserCountryCode, isnull(p.StateCode, '') as PurchaserStateCode, isnull(p.CityName, '') as PurchaserCityName, isnull(p.Address, '') as PurchaserAddress, isnull(p.Zip, '') as PurchaserZip
		   , isnull(p.Mobile, '') as PurchaserMobile, isnull(p.HomePhone, '') as HomePhone, isnull(p.WorkPhone, '') as WorkPhone
		   , isnull(p.eMail, '') as PurchaserEMail, p.IsCompany, ISNULL(p.DriverLicense, '') AS DriverLicense
    FROM   transaction_queued_Q(null, null, 1, null, null, @ProjectCopde, null) t
           CROSS APPLY NewStar.fnGetPurchaserInfo(t.transaction_id, t.email) as p --/*NewStar.fnGetPurchasers(t.transaction_id)*/ 
		   INNER JOIN dbo.V_LOT as vl on t.lot_id = vl.LOT_ID
	WHERE  (cast(t.transaction_date as date) >= @FromDate or @FromDate is null) and 
		   (cast(t.transaction_date as date) <= @ToDate   or @ToDate   is null)  
		   and vl.LOT_STATUS = 3
GO




select  *
from NewStar.fnGetSalesTransactionPurchasers('A0506', '01-30-2023', '12-31-2023')

