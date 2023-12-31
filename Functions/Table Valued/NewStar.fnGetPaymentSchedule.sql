USE [LSALiveNEW]
GO
/****** Object:  UserDefinedFunction [NewStar].[fnGetPaymentSchedule]    Script Date: 4/14/2022 12:41:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER   FUNCTION [NewStar].[fnGetPaymentSchedule]
(
	@TransactionID int
)
returns table
return
	select Depositd as Date, Depositm as Amount, Deposittext as Note, isnull(PaidDate, '01/01/1900') as PaidDate, isnull(PaidAmount, -1) as PaidAmount, isnull(Deposit_note, '') as DepositNoe
		, IIF(CAST([s].[Depositd] AS DATE) = CAST(t.transaction_date AS DATE), 'Earnest', 'Scheduled') AS ScheduleType
	from ASG_TRANSACTION_PAYMENT_SCHEDULE as s
		INNER JOIN [dbo].[ASG_TRANSACTION] AS t ON t.[transaction_id] = s.[transaction_id]
	where s.transaction_id = @TransactionID
go

select * from [NewStar].[fnGetPaymentSchedule](175505)