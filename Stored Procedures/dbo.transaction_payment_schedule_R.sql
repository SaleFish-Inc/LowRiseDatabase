USE [LSALiveNEW]
GO

/**********************************************************************************************************

	Last Updated		Done By			Description
	---------------		---------		---------------
	12-26-2023 16:00	Maziar C.		PaymentMemo added to the output.
	02-22-2021 12:08	Maryam Z.		Apply TimeZone on depositD.

**********************************************************************************************************/

CREATE OR ALTER PROCEDURE [dbo].[transaction_payment_schedule_R]
(
	@transaction_id int,
	@depositindex int = null
)
AS
BEGIN 
	DECLARE @lot_id int, @project_id varchar(10)

	SELECT @lot_id = lot_id 
	FROM ASG_TRANSACTION 
	WHERE transaction_id = @transaction_id -- Need @lot_id to fetch GetTimeByTimeZone
	
	SELECT @project_id = project_id 
	FROM ASG_LOT 
	WHERE LOT_ID = @lot_id  -- Need  @project_id for GetTimeByTimeZone

	SELECT rownumber
       , transaction_id
	   , Depositm
	   , Depositp
	   , dbo.getTimeByTimeZone(Depositd, @project_id) as Depositd
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
	   , payment_status_id 
	   , payment_status_desc, DepositP_Type
	   , ZoomClearedDate
	   , PaymentMemo
	FROM transaction_payment_schedule_Q(@transaction_id ,@depositindex )
	ORDER BY CASE 
				WHEN Depositd is not null THEN depositd 
				ELSE '2092-05-05' 
			 END 

END
GO
