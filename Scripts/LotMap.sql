USE LSALiveNEW
GO


select left(Unit_No, 3), * from NewStar.Lot where left(unit_no, 1) = '0' and Unit_No is not NULL

select * from ASG_LOT where PROJECT_ID='A0509' ORDER BY LOT_NUMBER 

SELECT * FROM LSALiveNEW..Asg_PROJECT WHERE project_name LIKE '%post%'

SELECT * FROM NewStar.LotMap

SELECT ISNUMERIC(SUBSTRING(Unit_No, 2, 2) ), SUBSTRING(Unit_No, 2, 2), * FROM newstar.lot ORDER BY unit_no


;
with x as (
select LOT_ID AS SalefishLotID, LOT_NUMBER AS NewStarLotNo, LOT_NUMBER AS SalefishLotNo --, *
from   ASG_LOT 
where PROJECT_ID='A0509' 
)
insert into NewStar.LotMap(SalefishLotNo, SalefishLotID, NewStarLotNo, SalefishProject)
select SalefishLotNo, SalefishLotID, NewStarLotNo, 'A0509'  
FROM x 
WHERE SalefishLotID not in (select salefishlotid from newstar.lotmap)



;
with x as (
select LOT_ID AS SalefishLotID, w.[Lot number] AS NewStarLotNo, LOT_NUMBER AS SalefishLotNo --, *
from  [NewStar].WestAndPost as w
	full join ASG_LOT as l on cast(substring(w.[Lot number], 1, 3) as smallint) = cast(LOT_NUMBER as smallint)
where PROJECT_ID='A0506' 
)
insert into NewStar.LotMap(SalefishLotNo, SalefishLotID, NewStarLotNo, SalefishProject)
select SalefishLotNo, SalefishLotID, NewStarLotNo, 'A0506'  
FROM x 
WHERE SalefishLotID not in (select salefishlotid from newstar.lotmap)


with x as (
select nsl.Unit_no, sfl.LOT_NUMBER, sfl.LOT_ID--, sfl.
from  [NewStar].[QueenslaneLots] as nsl
	full join .ASG_LOT  as sfl on cast(substring(nsl.Unit_No, 2, 2) as smallint) = cast(MKG_LOT_NO as smallint)
	/*(cast(left(nsl.Unit_No, 3) as smallint) = cast(MKG_LOT_NO as smallint) and ISNUMERIC(left(nsl.Unit_No, 3)) = 1) 						or 
									*/
where ISNUMERIC(substring(nsl.Unit_No, 2, 2)) = 1 and  Unit_No is not null and PROJECT_ID='A0369' 
)
/*
select m.NewStarLotNo, x.Unit_No, x.LOT_NUMBER from NewStar.LotMap as m
inner join x on m.SalefishLotID = x.LOT_ID
where x.Unit_No <> m.NewStarLotNo
*/
update NewStar.LotMap
set NewStarLotNo = (select Unit_No from x where NewStar.LotMap.SalefishLotID = x.LOT_ID)
where SalefishProject = 'A0369'



;
with x as
(
select count(*) as count, MKG_LOT_NO, PROJECT_ID from .ASG_LOT 
group by MKG_LOT_NO, PROJECT_ID
having COUNT(*) > 1
--order by LOT_NUMBER
)
select *
from .ASG_LOT as l
	inner join x on l.MKG_LOT_NO = x.MKG_LOT_NO and l.PROJECT_ID = x.PROJECT_ID
order by LOT_NUMBER


-- CW-Simcoe Landing --> Country Wide Homes at Keswick Inc. (PH1)	  
INSERT INTO LsaLiveNew.NewStar.[LotMap] ([SalefishLotNo], [NewStarLotNo], [SalefishLotID], [SalefishProject])
SELECT [LOT_NUMBER], CONCAT(REPLICATE('0', 4-LEN([LOT_NUMBER])) AS [NewStarLotNo], [LOT_NUMBER]), [LOT_ID], 'CW-Simcoe Landing'
FROM LsaLiveNew..ASG_LOT 
WHERE PROJECT_ID='A0396' 
ORDER by LOT_NUMBER 

-- Pine Valley Phase 2 --> Gold Park Homes: Pine Valley Forevergreen - Ph 2	  
INSERT INTO LsaLiveNew.NewStar.[LotMap] ([SalefishLotNo], [NewStarLotNo], [SalefishLotID], [SalefishProject])
SELECT [LOT_NUMBER], CONCAT(REPLICATE('0', 4-LEN([LOT_NUMBER])), [LOT_NUMBER]) AS [NewStarLotNo], [LOT_ID], 'Pine Valley Phase 2'
FROM LsaLiveNew.dbo.ASG_LOT 
WHERE PROJECT_ID='A0461' 
ORDER by [NewStarLotNo] 

/*************************************************************************/

use LSALiveNEW
go

select * from project_Q(null) where CLIENT_NAME like '%branth%'

select * from ASG_OPTION where (option_description like '%o_f%' or option_description like '%a_f%') and project_id in ('A0368', 'A0369')  order by option_description
select * from ASG_MODEL where /*PROJECT_ID = 'A0369' and*/ MODEL_NAME like '%Devon%' and project_id in ('A0368', 'A0369')
--select * from NewStar.ModelMap where SalefishModelName like '%KNIGHTSBRIDGE%' and NewStarModelCode not in (select model from NewStar.Model)  order by SalefishModelName
select * from NewStar.Model where model not in (select NewStarModelCode from NewStar.ModelMap) and Description like '%Devon%' order by Description
select * from NewStar.ModelMap where SalefishModelName like '%Devon%'

select * from ASG_TEMPLATE_Option where /* mapcode is not null and*/ template_id in (select template_id from V_TEMPLATE where PROJECT_ID='A0369')



select * 
from ASG_TRANSACTION_EXTRA as ex
	inner join ASG_OPTION as op on ex.item_no = op.option_id 
where is_option = 1  and /*op.option_description <> 'Standard' and mapping_code is not null and*/ project_id = 'A0369'-- and  transaction_id in (170705, 171017, 172134)
order by transaction_id

select *
from ASG_TRANSACTION as t 
	left join ASG_TRANSACTION_EXTRA as ex on t.transaction_id = ex.transaction_id


select * from ASG_OPTION where /*option_description = 'OMF/O3F' option_id = 6825 */ project_id = 'A0368'


select count(*), option_description
from ASG_OPTION 
group by option_description, project_id
having count(*) > 1

select * from ASG_TEMPLATE_Option where /* mapcode is not null and*/ template_id in (select template_id from V_TEMPLATE where PROJECT_ID='A0490')




select left(MODEL_NUMBER, 2) + SUBSTRING(MODEL_NUMBER, 6, 5), * from ..V_TEMPLATE where PROJECT_ID = 'A0368'

select * from NewStar.Model

select sf.MODEL_NUMBER, ns.Model, sf.MODEL_NAME, ns.Description, sf.ELEVATION, ns.Elev, sf.TEMPLATE_ID
from V_TEMPLATE as sf
	inner join NewStar.Model as ns on left(sf.MODEL_NUMBER, 2) + SUBSTRING(sf.MODEL_NUMBER, 6, 5) = left(ns.Model, 7) and left(sf.elevation, 1) = ns.Elev
where PROJECT_ID = 'A0368'
order by TEMPLATE_ID



INSERT INTO [NewStar].[ModelMap] (
	SalefishTemplateID, SalefishModelID, [SalefishModelNo], [SalefishModelName], [SalefishOption],
    [NewStarModelCode], [NewStarModelName], [Elevation], [NewStarModelDesc], [SalefishProjectID]
)
SELECT v.[TEMPLATE_ID], v.[MODEL_ID], v.[MODEL_NUMBER], v.[MODEL_NAME], 'Standard', c.[Code], c.[NAME], v.[ELEVATION], NULL, [v].[PROJECT_ID]
FROM [NewStar].CorkAndVine AS c
	left JOIN [dbo].[V_TEMPLATE] AS v ON v.[MODEL_NAME] = SUBSTRING(c.name, 5, LEN(c.Name))
WHERE [PROJECT_ID] = 'A0490' ORDER BY [MODEL_NAME]

SELECT * FROM [dbo].[V_TEMPLATE] WHERE [MODEL_NUMBER] IN (
	SELECT [SalefishModelNo] FROM [NewStar].[ModelMap] WHERE [SalefishModelID] IS NULL 
)

SELECT v.[PROJECT_ID], v.[TEMPLATE_ID], v.[MODEL_NUMBER], v.[MODEL_NAME], v.[ELEVATION], m.[SalefishModelNo], m.[SalefishModelName], m.[Elevation], m.[SalefishOption]
FROM [dbo].[V_TEMPLATE] AS v
INNER  JOIN [NewStar].[ModelMap] AS m ON m.[SalefishModelNo] = v.[MODEL_NUMBER] AND m.[Elevation] <> v.[ELEVATION]

-- update missing information for old manually data entry rows
UPDATE [NewStar].[ModelMap] 
SET [SalefishProjectID] = [PROJECT_ID], [SalefishTemplateID] = [TEMPLATE_ID], [SalefishModelID] = v.[MODEL_ID]
FROM [NewStar].[ModelMap] AS mm
	INNER JOIN [dbo].[V_TEMPLATE] AS v ON v.[MODEL_NUMBER] = mm.[SalefishModelNo] AND v.[MODEL_NAME] = mm.[SalefishModelName]
		AND LEFT(v.[ELEVATION], 1) = mm.[Elevation] 
WHERE v.[TEMPLATE_ID] IS NOT NULL AND mm.[SalefishTemplateID] IS NULL 


SELECT  [MODEL_NUMBER], [PROJECT_ID]
FROM [V_TEMPLATE] 
GROUP BY [MODEL_NUMBER], [PROJECT_ID]
HAVING COUNT(*) > 1
ORDER BY [MODEL_NUMBER], [PROJECT_ID]

SELECT  [MODEL_ID], [TEMPLATE_ID]
FROM [V_TEMPLATE] 
GROUP BY [MODEL_ID], [TEMPLATE_ID]
HAVING COUNT(*) > 1
ORDER BY [MODEL_NUMBER], [PROJECT_ID]

SELECT * FROM [NewStar].[ModelMap]

-- Finding missing models in ModelMap table
select t.[lot_Number], t.[MODEL_NAME], t.[template_id], mm.*
FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, 'A0490', NULL) t
			LEFT JOIN [NewStar].[ModelMap] AS mm ON mm.[SalefishTemplateID] = t.[template_id]
WHERE id IS NULL

select DISTINCT --t.[lot_Number] AS 'Lot Number', 
	v.[MODEL_NUMBER] AS 'Model Code',[t].[MODEL_NAME] AS 'Model Name',  [t].[template_id], [v].[MODEL_ID], [t].[ELEVATION], [v].[ELEVATION]
FROM transaction_queued_Q(NULL, NULL, 1, NULL, NULL, 'A0490', NULL) t
			LEFT JOIN [NewStar].[ModelMap] AS mm ON mm.[SalefishTemplateID] = t.[template_id]
			INNER JOIN [dbo].[V_TEMPLATE] AS v ON v.[TEMPLATE_ID] = t.[template_id]
WHERE id IS NULL
ORDER BY [Model Code]

SELECT * -- COUNT(id), COUNT(*)
FROM [NewStar].[ModelMap] AS mm
	INNER JOIN [dbo].[V_TEMPLATE] AS v ON v.[MODEL_NUMBER] = mm.[SalefishModelNo] AND v.[MODEL_NAME] = mm.[SalefishModelName]
		AND LEFT(v.[ELEVATION], 1) = mm.[Elevation] 
		--AND mm.[SalefishProjectID] = v.[PROJECT_ID]
WHERE v.[TEMPLATE_ID] IS NOT NULL AND mm.[SalefishTemplateID] IS NULL 
ORDER BY [mm].[ID]
