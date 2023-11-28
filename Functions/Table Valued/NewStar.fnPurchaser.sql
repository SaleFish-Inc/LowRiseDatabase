CREATE OR ALTER FUNCTION NewStar.fnPurchaser
(
	@TransactionID int
)
returns table
--WITH SCHEMABINDING
as
return
SELECT [firstname] AS FirstName, [lastname] AS LastName, [birthday] AS BirthDay, [address] AS Address, [city] AS CityName, [postalcode] as Zip, 
	[email] AS eMail, [cell] AS Mobile, [phone] AS Phone,
	c.country_abb AS CountryCode, c.country_name AS CountryName, s.province_abb AS StateCode, s.province_name AS StateName, p.Id
FROM [dbo].ASG_TRANSACTION_PURCHASER AS p
	left join ATI_LU_COUNTRY AS c ON p.country_id=c.country_id
	left join ATI_LU_PROVINCE AS  s ON p.province_id = s.province_id
WHERE /* [p].[firstname] IS NOT NULL AND [p].[lastname] IS NOT NULL AND
	  [p].[firstname] NOT IN ('', '.', '_', '-') AND [p].lastname NOT IN ('', '.', '_', '-')  AND
      [p].[email] IS NOT NULL AND [p].[email] <> '' AND email like '%@%' AND
	  ISNUMERIC([firstname]) = 0 and firstname not like '%[0123456789@\_]%' AND*/
	  transaction_id = @TransactionID
go