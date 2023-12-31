USE [LSALiveNEW]
GO

CREATE OR ALTER FUNCTION [NewStar].[fnGetNewstarModelCode]
(
	@ProjectID VARCHAR(10),
	@SalefishLotNo VARCHAR(16),
	@SalefishModelCode VARCHAR(20), 
	@SalefishOption VARCHAR(100),
	@SalefishOptionDescription VARCHAR(8000),
	@Elevation VARCHAR(20)
)
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @result VARCHAR(20) = ''

	IF @ProjectID IN ('A0368', 'A0369')
		BEGIN
		IF @SalefishOption IS NULL
			SET @SalefishOption = @SalefishOptionDescription

		SET @result = LEFT(@SalefishModelCode, 4) + RIGHT(@SalefishModelCode, 3) +
			CASE
				WHEN @SalefishOption IN ('OMF/O3F', 'O3F/OMF') 	THEN '5a'
				WHEN @SalefishOption IN ('OMF/O2F', 'O2F/OMF')	THEN '6a'
				WHEN LEFT(@SalefishOption, 3) IN ('AMF', 'OMF') THEN '1a'
				WHEN LEFT(@SalefishOption, 3) IN ('A2F', 'O2F') THEN '2a'
				WHEN LEFT(@SalefishOption, 3) IN ('A3F', 'O3F') THEN '3a'
				WHEN LEFT(@SalefishOption, 3) IN ('OFB')	    THEN '0'
				WHEN @SalefishModelCode='TH20-3301I'			THEN 'b'
				ELSE												''
			END
			+ LEFT(@Elevation, 1)
		END

	ELSE IF @ProjectID = 'A0396'
		SET @result = LEFT(@SalefishModelCode, 4) + '-' + RIGHT(@SalefishModelCode, 1) -- + '-' + @Elevation
	
	ELSE IF @ProjectID = 'A0429'
		SELECT @result = MODEL_NAME 
		FROM dbo.ASG_MODEL 
		WHERE PROJECT_ID = @ProjectID AND MODEL_NUMBER = @SalefishModelCode
	
	ELSE IF @ProjectID = 'A0461'
		BEGIN
		SET @result = REPLACE(@SalefishModelCode, '-', '')

		IF @SalefishLotNo in ('23', '26', '30', '49', '50', '59', '60', '67', '69', '72', '85', '88', '101',
							  '104', '129', '132')
			SET @result += '-' + REPLICATE('0', 3-LEN(@SalefishLotNo)) + @SalefishLotNo
		END

	ELSE IF @ProjectID = 'A0490'
		BEGIN
		SELECT @result = NewStarModelCode
		FROM [NewStar].[ModelMap]
		WHERE SalefishProjectID = @ProjectID AND SalefishModelNo = @SalefishModelCode
		END
	
	ELSE IF @ProjectID = 'A0505'
		IF LEFT(@SalefishModelCode, 5) = 'SD-FS'
			SET @result = 'SD-FS-' + RIGHT(@SalefishModelCode, 2)
		ELSE
			SET @result = @SalefishModelCode
	
	ELSE IF @ProjectID = 'A0506'
		BEGIN
		SET @result = 
			CASE @SalefishModelCode
				WHEN 'TH-01' THEN 'TH2010'	-- Arbourview
				WHEN 'RL-01' THEN 'RL2006'	-- Grand Oak
				WHEN 'RL-03' THEN 'RL2004'	-- West Oak
				WHEN 'RL-02' THEN 'RL2005I'	-- Forest Glen
				WHEN 'RL-04' THEN 'RL2006'	-- Pine Glen
				WHEN 'TH-01' THEN 'TH2010'
				ELSE ''
			END 	
			
		IF CHARINDEX('CNR', @Elevation) > 0
			SET @result += 'C'
		ELSE IF CHARINDEX('END', @Elevation) > 0
			SET @result += 'E'
		ELSE IF CHARINDEX('INT', @Elevation) > 0 AND @SalefishModelCode <> 'RL-02' --AND @SalefishOptionDescription <> 'Standard'
			SET @result += 'I'		

		IF CHARINDEX('2ndFloor', @SalefishOptionDescription) > 0 OR CHARINDEX('2ndFlr', @SalefishOptionDescription) > 0 OR CHARINDEX('3rdFloor', @SalefishOptionDescription) > 0
			IF CHARINDEX('dual primary', @SalefishOptionDescription) > 0 OR (CHARINDEX('lux ens', @SalefishOptionDescription) > 0) 
				SET @result += '2'		
			ELSE 
				IF CHARINDEX('Ground', @SalefishOptionDescription) > 0 
					SET @result += '5'
				ELSE 
					SET @result += '2'
		ELSE 
			IF CHARINDEX('guest', @SalefishOptionDescription) > 0 
				IF CHARINDEX('Ground', @SalefishOptionDescription) > 0 
					SET @result += '0a'
				ELSE
					SET @result += '0'
			ELSE 
				IF CHARINDEX('Ground', @SalefishOptionDescription) > 0
					SET @result += '1a'

		IF	(
				(CHARINDEX('lux ens', @SalefishOptionDescription) > 0) 
				OR 
				(CHARINDEX('dual primary', @SalefishOptionDescription) > 0)
			) 
			AND RIGHT(@result, 1) <> 'a'
			SET @result += 'a'
		ELSE IF CHARINDEX('4 bed', @SalefishOptionDescription) > 0 
			SET @result += 'b'

		SET @result += LEFT(@Elevation, 1)
		END
	
	ELSE IF @ProjectID = 'A0509'
		BEGIN
		DECLARE @ModelName VARCHAR(20)

		SELECT @result = MODEL_NAME, @ModelName = TRIM(MODEL_NAME)
		FROM dbo.ASG_MODEL 
		WHERE PROJECT_ID = @ProjectID and MODEL_NUMBER = @SalefishModelCode	

		IF @ModelName = '20-04'
			IF CHARINDEX('bed', @SalefishOptionDescription) > 0
				SET @result += ' E/O'	
			ELSE 
				SET @result += ' END'	

		
		IF CHARINDEX('opt', @SalefishOptionDescription)  > 0 OR 
		   CHARINDEX('floor', @SalefishOptionDescription) > 0 OR 
		   CHARINDEX('bed', @SalefishOptionDescription) > 0 
			IF @ModelName NOT IN ('20-01', '20-02', '20-03', '20-04') AND LEFT(@ModelName, 2) NOT IN ('36', '43')
				SET @result += ' OPT'	

		IF CHARINDEX('CORN', @Elevation) > 0
				SET @result += ' CORN'	
		IF @Elevation = 'C MOD' 
				SET @result += ' MODC'	
/*
		IF CHARINDEX('END', @Elevation) > 0 AND CHARINDEX('E/O', @result) = 0
				SET @result += ' END'	
*/
		END 

	ELSE    
		SET @result = NULL
			
	RETURN @result
END
GO




-- SELECT * FROM NewStar.fnGetSalesTransactionForNewstarSaleFlatted('A0490', '01-01-2022', '12-30-2023')

SELECT * FROM NewStar.fnGetSalesTransactionForNewstarEnterpriseFlatted('A0490', '01-01-2022', '12-30-2023')
ORDER BY Lot
