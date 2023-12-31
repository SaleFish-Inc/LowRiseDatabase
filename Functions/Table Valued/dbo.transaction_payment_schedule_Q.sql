USE [LSALiveNEW]
GO
/**********************************************************************************************************

	Last Updated        Done By			Description
	----------------    ---------		---------------
	12-26-2023 16:00	Maziar C.		PaymentMemo added to the output.

**********************************************************************************************************/

CREATE OR ALTER FUNCTION [dbo].[transaction_payment_schedule_Q]
(
	@transaction_id int,
	@depositindex int

)
RETURNS TABLE 
AS
RETURN 
SELECT ROW_NUMBER() Over(order by ISNULL(Depositd,'2092-05-05')) as rownumber
       , transaction_id
	   , Depositm
	   , Depositp
	   , Depositd
	   , Deposittext
	   , Depositdayafter
	   , Depositindex
	   , Account_number
	   , Deposit_note
	   , AFilename
	   , PaidAmount
	   , PaidDate
	   , trupdatedate
	   , userid
	   , ClearedDate
	   , DepositNSF
	   , ISNULL(a.payment_status_id, -1) AS payment_status_id  --a.payment_status_id
	   , ISNULL(ASG_LU_PAYMENT_STATUS.payment_status_desc ,'NOT RECEIVED') AS payment_status_desc
	   , CAST (CASE 
					WHEN a.DepositP_Type IS NOT NULL THEN a.DepositP_Type
					WHEN Depositp > 100 THEN 0  
					ELSE 1 
			   END AS TINYINT) AS DepositP_Type
	   , ZoomClearedDate
	   , [Deposit_note] AS PaymentMemo
	   --, a.DepositP_Type as DepositP_Type
FROM  ASG_TRANSACTION_PAYMENT_SCHEDULE AS a 
	LEFT JOIN ASG_LU_PAYMENT_STATUS ON ASG_LU_PAYMENT_STATUS.payment_status_id = a.payment_status_id
WHERE (@transaction_id IS NULL OR transaction_id = @transaction_id) AND
      (@depositindex IS NULL OR depositindex = @depositindex)
GO

SELECT PaymentMemo, p.* FROM [dbo].[transaction_payment_schedule_Q](NULL, NULL) AS p
	INNER JOIN [dbo].[ASG_TRANSACTION] AS t ON p.transaction_id = t.transaction_id
	INNER JOIN v_lot AS v ON v.lot_id = t.lot_id
WHERE PaymentMemo IS NOT NULL AND PaymentMemo <> '' and v.project_id = 'A0368'