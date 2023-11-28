use LSALiveNEW
GO

SELECT * FROM asg_project WHERE project_name LIKE '%seaton%'

select DISTINCT option_description from ASG_OPTION 
WHERE project_id = 'A0509' --AND (option_description like '%o_f%' or option_description like '%a_f%') 
AND  (option_description LIKE '% END%' )


SELECT DISTINCT option_description
FROM ASG_TRANSACTION_EXTRA AS ex
	INNER JOIN ASG_OPTION AS op ON ex.item_no = op.option_id 
WHERE project_id = 'A0461'
/*is_option = 1  AND 
op.option_description <> 'Standard' and mapping_code is not null and*/ 

SELECT * FROM ASG_MODEL 
WHERE PROJECT_ID = 'A0461' 
ORDER BY MODEL_NAME

SELECT DISTINCT MODEL_NAME, ELEVATION FROM V_TEMPLATE
WHERE PROJECT_ID = 'A0461' 


SELECT * 
FROM ASG_TRANSACTION_EXTRA AS ex
	INNER JOIN ASG_OPTION AS op ON ex.item_no = op.option_id 
WHERE project_id = 'A0509'
/*is_option = 1  AND op.option_description <> 'Standard' and mapping_code is not null and*/ 
ORDER BY transaction_id

SELECT *
FROM ASG_TRANSACTION AS t 
	LEFT JOIN ASG_TRANSACTION_EXTRA AS ex ON t.transaction_id = ex.transaction_id


SELECT sf.MODEL_NUMBER, ns.Model, sf.MODEL_NAME, ns.Description, sf.ELEVATION, ns.Elev, sf.TEMPLATE_ID
FROM V_TEMPLATE AS sf
	INNER JOIN NewStar.Model AS ns ON LEFT(sf.MODEL_NUMBER, 2) + SUBSTRING(sf.MODEL_NUMBER, 6, 5) = LEFT(ns.Model, 7) AND LEFT(sf.elevation, 1) = ns.Elev
WHERE PROJECT_ID = 'A0368'
order by TEMPLATE_ID

SELECT * FROM NewStar.ProjctToCommunityMap


DROP TABLE #ModelMap

SELECT t.PROJECT_ID AS SalefishProjectID, t.MODEL_ID AS SalefishModelID, t.MODEL_NUMBER AS SalefishModelNo
	, t.MODEL_NAME AS SalefishModelName, t.ELEVATION AS Elevation, t.TEMPLATE_ID AS SalefishTemplateID
	, LEFT(o.option_description, 3) AS SalefishOption, o.option_description AS SalefishDescription
	, [NewStar].[fnGetNewstarModelCode](t.PROJECT_ID, t.MODEL_NUMBER, LEFT(o.option_description, 3), o.option_description, t.ELEVATION) AS NewStarModelCode
	INTO #ModelMap
FROM V_TEMPLATE AS t 
	INNER JOIN ASG_OPTION AS o ON o.project_id = t.PROJECT_ID
WHERE t.project_id = 'A0429'


SELECT PROJECT_ID, STRING_AGG(LEFT(option_description, 3), '/') AS Options, STRING_AGG([option_description], ';')  AS Description
FROM ASG_OPTION AS o
WHERE project_id = 'A0429'
GROUP BY PROJECT_ID


SELECT * FROM #ModelMap WHERE SalefishProjectID = 'A0429' ORDER BY SalefishTemplateID
SELECT * FROM NewStar.ModelMap WHERE SalefishProjectID = 'A0429'

SELECT mm1.SalefishModelID AS SalefishModelID1, mm2.SalefishModelID AS SalefishModelID2
	, mm1.SalefishModelNo AS SalefishModelNo1, mm2.SalefishModelNo AS SalefishModelNo2
	, mm1.SalefishModelName AS SalefishModelName1, mm2.SalefishModelName AS SalefishModelName2
	, mm1.Elevation AS Elevation1, mm2.Elevation AS Elevation2
	, mm1.SalefishOption AS SalefishOption1, mm2.SalefishOption AS SalefishOption2
	, mm1.SalefishDescription AS SalefishDescription1, mm2.NewStarModelName, mm2.NewStarModelDesc AS SalefishDescription2
	, mm1.NewStarModelCode AS NewStarModelCode1, mm2.NewStarModelCode AS NewStarModelCode2
FROM #ModelMap AS mm1
	RIGHT JOIN NewStar.ModelMap AS mm2 ON mm1.SalefishTemplateID = mm2.SalefishTemplateID
WHERE mm2.SalefishProjectID = 'A0429'
