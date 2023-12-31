USE [LSALiveNEW]
GO

CREATE OR ALTER	FUNCTION dbo.fnGetFrontage
(
	@ProjectID ProjectIdType
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT MODEL_SIZE
	FROM ASG_MODEL
	WHERE [PROJECT_ID] = @ProjectID
GO

SELECT * FROM dbo.fnGetFrontage('A0368')