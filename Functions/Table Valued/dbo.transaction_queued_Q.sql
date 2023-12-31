USE [LSALiveNEW]
GO

/**********************************************************************************************************

	 Last Updated           Done By			Description
	--------------------    ---------		---------------
	2020-12-09   12:00	    Deon B.			Added Transit_Number, Institution_Number, Account_Number & Account_Holder
	2021-02-08	 11:43		Maryam Z.		Add TimeZone related changes
	2021-02-11	 01:35		Maryam Z.		Add conditional_date
	2021-03-03   09:00		Deon B.			Added Missing fields  & Lawyer_Province_name & Lawyer_country_name  to give name instead of id
	2021-04-15	 10:35		Maryam Z.		Add target_date & extension_date
	2021-05-13	 06:02		Maziar C.		Change dbo.ASG_TRANSACTION to LowRise.V_ASG_TRANSACTION
	2022-09-21	 12:24		Maziar C.		Add four new column to select liset: IsInvestor, IsFirstTimeBuyer, IsForeignBuyer, Purchase_Purpose as PurchasePurpose 
	2023-04-08	 12:24		Maziar C.		Use "Trim" for agent's full name: 'fullname' column
	2023-09-20	 09:00		Maryam Z.		Add "project_id"
	2023-09-28	 13:00		Maziar C.		Using "ISNULL" for "TotalCommissionPaid"
	2023-10-13	 08:21		Maryam Z.		Added IsAgent_CommissionFixed
	2023-11-16	 17:10		Maziar C.		Remove "13" from status list, because there is no such a status.

***********************************************************************************************************/

CREATE OR ALTER FUNCTION [dbo].[transaction_queued_Q]
(
	@transaction_id int,
	@lot_id int,
	@transaction_type_id int,
	@worksheetprintno int,
	@apsprintno int,
	@project_id varchar(10),
	@companyId int=null
)
RETURNS TABLE 
AS
RETURN 
SELECT
		dbo.[IsAgent_CommissionFixed](a.transaction_id) as IsAgentCommissionFixed
			, a.transaction_id
			, a.transaction_type_id
			, dbo.GetTimeByTimeZone (a.transaction_date, @project_id) transaction_date--a.transaction_date
			, a.target_date
			, a.extension_date
			, a.conditional_date
			, a.user_id
			, ISNULL(a.purchaser_id, 0) AS purchaser_id
			, a.lot_id
			, CASE WHEN dbo.ASG_LOT.lot_Number <> dbo.ASG_LOT.MKG_LOT_NO THEN dbo.ASG_LOT.MKG_LOT_NO 
				   ELSE dbo.ASG_LOT.lot_Number 
			  END AS lot_Number
			, a.template_id
			, a.assignment
			, a.expire_date
			, a.brokerage_id
			, a.note
			, a.brockerage
			, a.contact
			, ISNULL(a.discount,0) AS Deal_Discount
			, ISNULL(a.lot_price_prem, 0) AS lot_price_prem
			, ISNULL(a.upgrade_price, 0) AS upgrade_price
			, ISNULL(a.grading_price, 0) AS grading_price
			, ISNULL(a.modelonbiglotprice, 0) AS modelonbiglotprice
			, ISNULL(a.currentmodelprice, 0) AS currentmodelprice
			, a.price
			, a.Baseprice
			, a.TotalPrice
			, a.purchaser_group_id
			, p.province_name  as purchaserProvName --Purchaser’s Province
			, a.repersentative
			, a.worksheetprintno
			, a.apsprintno
			, a.agentname
			, b.firstname
			, b.lastname
			, b.email
			, b.profession
			, a.closeingdate
			, a.irrevocabledate
			, dbo.ASG_LOT.MKG_LOT_NO
			, dbo.ASG_LOT.LEGAL_NAME
			, dbo.ASG_LOT.PHASE_NO
			, dbo.ASG_LOT.PROJECT_ID AS Prj
			, ISNULL(dbo.ASG_LOT.STATUS2, 0) AS status2
			, TRIM(ISNULL(d.name, '')) + ' ' + TRIM(ISNULL(d.lastname, '')) AS fullname --Agent
			, ISNULL( a.commission,
				ISNULL( d.commission,
					ISNULL( e.AgentComission,0)))				as AgentCommission  --Agent Commission amount
			-- The 3 following lines added to compute TotalCommissionPaid to be used by Maziar in web services
			, ISNULL(dbo.BASEPRICE_NET_HST(a.TotalPrice) * 
				([dbo].[Agent_Commission](a.transaction_id, a.agent_id, ASG_LOT.PROJECT_ID))/100, 0) 
			as TotalCommissionPaid
			-- The 3 above lines added to compute TotalCommissionPaid to be used by Maziar in web services
			, d.email											as AgentEmail	    --Agent Email
			, d.tel												as AgentPhone	    --Agent Phone number
			, a.salesnote
			, a.signed
			, a.booking_purchase_id
			, a.bookingporposed_date
			, a.bookingporposed_time
			, dbo.ASG_LOT.UPGRADE
			, dbo.ASG_LOT.LOT_GRADING
			, isnull(m.HighRiseCompanyId,dbo.ASG_LOT.COMPANY_ID) as COMPANY_ID
			, ASG_COMPANY_1.name AS buildername
			, a.token
			, a.CookieId 
			, ISNULL(a.mortgage_letter, 0) AS mortgage_letter
			, ISNULL(a.lending_institute, 0) AS lending_institute
			, ISNULL(a.mortgage_value, 0) AS mortgage_value
			, b.phone
			, isnull(dbo.ASG_COMPANY.name		,'') as brokeragename
			, isnull(dbo.ASG_COMPANY.address   ,'') as brokerageAddress		--Brokerage Address
			, isnull(dbo.ASG_COMPANY.address   ,'') as brokerageCity		--Brokerage City   does not exist 
			, isnull(dbo.ASG_COMPANY.postalcode,'') as brokeragePostalCode	--Brokerage Postal Code
			,isnull(a.salesstatus,0) as salesstatus
			,isnull(a.binder,0) as binder
			, a.agent_id
			,v.MODEL_NAME
			,v.ELEVATION
			,a.commission_value
			,a.commission
			,a.paypal_transaction
			--,dbo.ASG_LOT.project_id
			
			, a.mortgage_approv_date
			, ISNULL(time_slot_id , 0) AS time_slot_id 
			, ISNULL(a.Lawyer_Company_name, '') AS Lawyer_Company_name
			, ISNULL(a.Lawyer_FirstName, '') AS Lawyer_FirstName
			, ISNULL(a.Lawyer_LastName, '') AS Lawyer_LastName
			, ISNULL(a.Lawyer_Phone, '') AS Lawyer_Phone
			, ISNULL(a.Lawyer_Email, '') AS Lawyer_Email
			, ISNULL(a.Lawyer_address, '') AS Lawyer_address
			, ISNULL(a.Lawyer_fax, '') AS Lawyer_fax
			, ISNULL(a.Lawyer_City, '') AS Lawyer_City
			, ISNULL(a.Lawyer_Province, 0) AS Lawyer_Province			 
			, ISNULL(a.Lawyer_country, 0) AS Lawyer_country
			, ISNULL(lp.province_name , '') AS Lawyer_Province_Name 
			, ISNULL(lc.country_name  , '') AS Lawyer_country_Name	
			, ISNULL(a.Lawyer_postalcode, '') AS Lawyer_postalcode
			, ISNULL(a.Lawyer_Reference, '') AS Lawyer_Reference

			, ISNULL(a.Account_Holder	  , '') AS Account_Holder
			, ISNULL(a.Transit_Number	  , '') AS Transit_Number	  
			, ISNULL(a.Institution_Number , '') AS Institution_Number 
			, ISNULL(a.Account_Number	  , '') AS Account_Number	

			, IsInvestor
			, IsFirstTimeBuyer
			, IsForeignBuyer
			, Purchase_Purpose as PurchasePurpose 
			, asg_lot.PROJECT_ID

FROM   
	LowRise.V_ASG_TRANSACTION 
	AS a INNER JOIN
		dbo.transaction_last2_Q(@transaction_type_id, @project_id) AS c ON a.lot_id = c.lot_id 
		                                             AND c.transaction_date = a.transaction_date 
		INNER JOIN
        dbo.transaction_purchaser_top1_Q(NULL, NULL) AS b ON a.transaction_id = b.transaction_id 
		INNER JOIN
        dbo.ASG_LOT ON dbo.ASG_LOT.LOT_ID = a.lot_id LEFT OUTER JOIN
        dbo.ASG_COMPANY ON a.brokerage_id = dbo.ASG_COMPANY.company_id LEFT OUTER JOIN
        dbo.ASG_COMPANY_AGENT AS d ON d.agent_id = a.agent_id LEFT OUTER JOIN
        dbo.ASG_PROJECT_OTHER AS e ON e.project_id = dbo.ASG_LOT.PROJECT_ID LEFT OUTER JOIN
        dbo.ASG_COMPANY AS ASG_COMPANY_1 ON ASG_COMPANY_1.company_id = dbo.ASG_LOT.COMPANY_ID AND ASG_COMPANY_1.company_type_id = 2 
		left outer join ASG_COMPANY_ID_MAPPING m on m.LowRiseCompanyid=ASG_COMPANY_1.company_id
		left outer join V_TEMPLATE v on v.TEMPLATE_ID=a.template_id
		LEFT OUTER JOIN [HighRiseLive].dbo.ATI_LU_PROVINCE as p  on  p.province_id = b.province_id
		LEFT OUTER JOIN [HighRiseLive].dbo.ATI_LU_PROVINCE as lp on lp.province_id = a.Lawyer_Province
		LEFT OUTER JOIN [HighRiseLive].dbo.ATI_LU_COUNTRY  as lc on  lc.country_id = a.Lawyer_country
where (@transaction_id is null or a.transaction_id=@transaction_id)
 and ( dbo.ASG_LOT.status in (3, 12)  )
 and ( @lot_id is null or  a.lot_id=@lot_id) 
 and ( @transaction_type_id is null or  a.transaction_type_id=@transaction_type_id)
 and ( @worksheetprintno is null or   (worksheetprintno>=1 and @worksheetprintno =1) or   (worksheetprintno=0 and @worksheetprintno =0) )
 and ( @apsprintno is null or   (apsprintno>=1 and @apsprintno =1) or   (apsprintno=0 and @apsprintno =0) )
 and ( @project_id is null or     dbo.ASG_LOT.project_id= @project_id )
 and ( @companyId  is null or  dbo.ASG_LOT.company_id= @companyId)