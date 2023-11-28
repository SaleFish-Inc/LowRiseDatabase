use LSALiveNEW
GO

CREATE TABLE NewStar.TransferLog
(
	ID int identity CONSTRAINT PK_TransferLog PRIMARY KEY,
	TransactionID INT NOT NULL CONSTRAINT FK_TransferLog_ATI_Transaction FOREIGN KEY REFERENCES ASG_Transaction(Transaction_ID),
	TransferDate DATETIME2 CONSTRAINT DF_TransferLog_TransferDate DEFAULT GETDATE(),
	IsRollBacked BIT NOT NULL  CONSTRAINT DF_TransferLog_IsRollBacked DEFAULT (0)
)

go

ALTER TABLE NewStar.TransferLog ADD CONSTRAINT
	UQ_TransferLog_TransactionID_TransferDate UNIQUE NONCLUSTERED 
	(
	TransactionID, TransferDate
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO


select tl.ID, SalefishProjectName AS 'Salefish Project Name', m.NewStarCommunityID AS 'Newstar Project Code',
		LOT_NUMBER AS 'Lot Number', TransferDate AS 'Transfer Date' , IsRollBacked AS 'Must Transfer Again'
from NewStar.TransferLog as tl
	inner join ASG_TRANSACTION as t on t.transaction_id = tl.TransactionID
	inner join ASG_LOT as l on l.LOT_ID = t.lot_id
	inner join NewStar.ProjctToCommunityMap as m on m.SalefishProjectID = l.PROJECT_ID
WHERE  ClientName = 'Branthaven' 
ORDER BY TransferDate, SalefishProjectName

with x as
(
SELECT tl.*, l.LOT_NUMBER, l.PROJECT_ID, m.SalefishProjectName
from NewStar.TransferLog as tl
	inner join ASG_TRANSACTION as t on t.transaction_id = tl.TransactionID
	inner join ASG_LOT as l on l.LOT_ID = t.lot_id
	inner join NewStar.ProjctToCommunityMap as m on m.SalefishProjectID = l.PROJECT_ID
WHERE  LOT_NUMBER in ('33') and SalefishProjectName like '%Queen%'
)
update NewStar.TransferLog
set IsRollBacked = 1
where ID in (select ID from x)


select * 
--delete 
from NewStar.TransferLog where TransactionID = 175505


truncate TABLE NewStar.TransferLog

select distinct top 10 TransferDate
from NewStar.TransferLog
order by TransferDate desc