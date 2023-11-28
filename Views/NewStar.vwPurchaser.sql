use LSALiveNEW
go

CREATE OR ALTER VIEW NewStar.vwPurchaser
--WITH SCHEMABINDING
as
SELECT [firstname] AS FirstName, [lastname] AS LastName, [birthday] AS BirthDay, [address] AS Address, [city] AS CityName, [postalcode] as Zip, 
	[email] AS eMail, [cell] AS Mobile, [phone] AS HomePhone,
	c.country_abb AS CountryCode, c.country_name AS CountryName, s.province_abb AS StateCode, s.province_name AS StateName
	, IIF(
		(ISNUMERIC(firstname) = 1 and (lastname like '%Inc%' or lastname like  '%Corp%' or lastname like '%Ltd%' or lastname like '%Limited%'))
			or
			(lastname like '%Inc.%' or lastname like  '%Co.%' or lastname like  '%Corp.%' or lastname like '%Ltd.%' )
		, 1, 0) as IsCompany
		, transaction_id as TransactionID, driverlicense as DriverLicense
	, p.phone2 as WorkPhone
FROM [dbo].ASG_TRANSACTION_PURCHASER AS p
	left join ATI_LU_COUNTRY AS c ON p.country_id=c.country_id
	left join ATI_LU_PROVINCE AS  s ON p.province_id = s.province_id
go


select * from NewStar.vwPurchaser where IsCompany = 1 order by lastname desc