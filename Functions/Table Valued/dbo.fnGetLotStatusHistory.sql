USE [LSALiveNEW]
GO

CREATE OR ALTER FUNCTION dbo.fnGetLotStatusHistory
(
	@ProjectID ProjectIdType,
	@LotNumber LotNumberType = NULL
)
RETURNS TABLE
AS
RETURN
	SELECT V.LOT_ID AS LotId, V.LOT_NUMBER AS LotNumber, V.LOTFRONTAGE AS LotFrontage
		, A.[Action_Type_Desc] AS Action, CAST(H.[ACTION_DATE] AS DATETIME2(0)) AS ActionTime, S.Lot_status_description as LotStatus
	FROM [dbo].[ASG_HISTORY] AS H
		INNER JOIN dbo.V_LOT AS V ON V.lot_id = H.lot_id
		INNER JOIN [dbo].[ASG_LU_Action_Type] AS A ON A.[Action_type_id] = H.[ACTION_TYPE]
		INNER JOIN [ASG_LU_Lot_Status_Type] AS S ON S.LotStatus_id = A.status_after
	WHERE V.PROJECT_ID = @ProjectID AND 
		(V.LOT_NUMBER = @LotNumber OR @LotNumber IS NULL)
GO

SELECT * FROM dbo.fnGetLotStatusHistory('A0548', NULL)
ORDER BY LotNumber ASC, ActionTime DESC
