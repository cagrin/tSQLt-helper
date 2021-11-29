CREATE PROCEDURE tSQLtHelper.Private_FormatCell
(
	@RowNumber INT,
	@ColumnNumber INT,
	@Result NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @colName NVARCHAR(MAX) = (SELECT COLUMN_NAME FROM #cols WHERE ORDINAL_POSITION = @ColumnNumber);

	DECLARE @isQuoted BIT = CASE WHEN EXISTS(
	SELECT 1 FROM #cols WHERE column_name = @colName
	AND data_type IN ('char', 'nchar', 'varchar', 'NVARCHAR', 'uniqueidentifier', 'date', 'datetime', 'datetime2')
	) THEN 1 ELSE 0 END;

	DECLARE @isDate BIT = CASE WHEN EXISTS(
	SELECT 1 FROM #cols WHERE column_name = @colName
	AND data_type IN ('date', 'datetime', 'datetime2')
	) THEN 1 ELSE 0 END;

	DECLARE @command NVARCHAR(MAX) = 'SELECT @Result = convert(NVARCHAR(MAX), ' + @colName + ') FROM #rows WHERE RowNumber = ' + CONVERT(NVARCHAR(MAX), @RowNumber);
	IF @isDate = 1
	BEGIN
		SET @command = 'SELECT @Result = convert(NVARCHAR(MAX), ' + @colName + ', 121) FROM #rows WHERE RowNumber = ' + CONVERT(NVARCHAR(MAX), @RowNumber);
	END

	DECLARE @params NVARCHAR(MAX) = N'@Result NVARCHAR(MAX) OUTPUT';
	EXEC sp_executesql @command, @params, @Result = @Result OUTPUT;

	IF @isQuoted = 1
	BEGIN
		SET @Result = '''' + @Result + ''''
	END

	IF @Result IS NULL
	BEGIN
		SET @Result = 'NULL'
	END
END;
GO