CREATE PROCEDURE tSQLtHelper.ConvertIntoInserts
(
	@TableName NVARCHAR(MAX),
	@Query NVARCHAR(MAX),
	@Result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	-- Prepare
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..##rows') IS NOT NULL
	BEGIN
		DROP TABLE ##rows;
	END

	IF OBJECT_ID('tempdb..#rows') IS NOT NULL
	BEGIN
		DROP TABLE #rows;
	END

	IF OBJECT_ID('tempdb..#cols') IS NOT NULL
	BEGIN
		DROP TABLE #cols;
	END

	DECLARE @command NVARCHAR(MAX) = 'SELECT * INTO ##rows FROM (' + @Query + ') a';
	EXEC sp_executesql @command;

	SELECT * INTO #cols
	FROM tempdb.INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME = '##rows';
	SELECT RowNumber = ROW_NUMBER() OVER(ORDER BY (SELECT 1)), * INTO #rows FROM ##rows;

	DECLARE @cols INT = (SELECT COUNT(1) FROM #cols);
	DECLARE @rows INT = (SELECT COUNT(1) FROM #rows);

	--select * FROM #rowData
	DECLARE @columns NVARCHAR(MAX) = '';
	DECLARE @rowData NVARCHAR(MAX) = '';
	DECLARE @idx INT = 0;
	DECLARE @idc INT = 0;
	DECLARE @cell NVARCHAR(MAX) = '';

	-- Columns
	SELECT @columns = LTRIM(STUFF((SELECT ', ' + COLUMN_NAME FROM #cols for XML PATH('')), 1, 1,''));
	UPDATE #cols SET CHARACTER_MAXIMUM_LENGTH = 0;

	-- RowData
	SET @idx = 0;
	while @idx < @rows
	BEGIN
		SET @idx = @idx + 1;
		SET @idc = 0;
		while @idc < @cols
		BEGIN
			SET @idc = @idc + 1;
			SET @cell = '';
			EXEC tSQLtHelper.Private_FormatCell @idx, @idc, @cell OUTPUT;
			UPDATE #cols SET CHARACTER_MAXIMUM_LENGTH = len(@cell)
			WHERE ORDINAL_POSITION = @idc AND CHARACTER_MAXIMUM_LENGTH < len(@cell);
		END
	END

	SET @rowData = '';
	SET @idx = 0;
	WHILE @idx < @rows
	BEGIN
		SET @idx = @idx + 1;

		SET @rowData = @rowData + NCHAR(10) + '    (';

		SET @idc = 0;
		WHILE @idc < @cols
		BEGIN
			SET @idc = @idc + 1;

			SET @cell = '';
			EXEC tSQLtHelper.Private_FormatCell @idx, @idc, @cell OUTPUT;

			DECLARE @colLength INT = (SELECT CHARACTER_MAXIMUM_LENGTH FROM #cols WHERE ORDINAL_POSITION = @idc);

			IF @idc < @cols
			BEGIN
				SET @rowData = @rowData + RIGHT('                                                                                         ' + @cell, @colLength);
				SET @rowData = @rowData + ', '
			END
			ELSE
			BEGIN
				SET @rowData = @rowData + @cell;
			END
		END

		IF @idx < @rows
		BEGIN
			SET @rowData = @rowData + '),'
		END
		ELSE
		BEGIN
			SET @rowData = @rowData + ');'
		END
	END

	SET @Result = '';
	SET @Result = @Result + 'INSERT INTO ' + @TableName + ' ('
	SET @Result = @Result + @columns
	SET @Result = @Result + ') VALUES';
	SET @Result = @Result + @rowData;
END;
GO
