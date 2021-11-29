CREATE SCHEMA testConvertIntoInserts;
GO

CREATE PROCEDURE testConvertIntoInserts.test1
AS
BEGIN
    SET NOCOUNT ON;
--- Arrange
	IF OBJECT_ID('tempdb..#invoice') IS NOT NULL
	BEGIN
		DROP TABLE #invoice;
	END

    CREATE TABLE #invoice
    (
        inv_id int NOT NULL,
        inv_type CHAR(3) NOT NULL,
        inv_cust_id VARCHAR(100) NULL,
        inv_amount MONEY NOT NULL,
        inv_date DATE NULL,
        inv_error NVARCHAR(MAX) NULL
    );

	INSERT INTO #invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) VALUES
    (1, 'FV', 'ABCDE12345', 100.00, '2021-11-27', NULL),
    (2, 'FV1', 'Zażółć gęślą jaźń', -1.00, '2021-11-28', NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '2021-11-29', '?'),
    (4, 'A', 'ABCDE12345', 0.00, NULL, 'An ERROR occurred');

--- Act
	DECLARE @Actual NVARCHAR(MAX);

	EXEC tSQLtHelper.ConvertIntoInserts
		@TableName = 'dbo.invoice',
		@Query = 'SELECT inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error FROM #invoice',
		@Result = @Actual OUTPUT;

--- Assert
	DECLARE @expected NVARCHAR(MAX) = 'INSERT INTO dbo.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) VALUES
    (1, ''FV '',          ''ABCDE12345'',  100.00, ''2021-11-27'', NULL),
    (2, ''FV1'',   ''Zażółć gęślą jaźń'',   -1.00, ''2021-11-28'', NULL),
    (3, ''FV2'', ''qwerty asdfgh zxcvb'', 1234.56, ''2021-11-29'', ''?''),
    (4, ''A  '',          ''ABCDE12345'',    0.00,         NULL, ''An ERROR occurred'');';

    SET @expected = REPLACE(@expected, CHAR(13) + CHAR(10), CHAR(10));
    SET @Actual = REPLACE(@Actual, CHAR(13) + CHAR(10), CHAR(10));

	IF NOT((@expected = @Actual) OR (@Actual IS NULL AND @expected IS NULL))
    BEGIN
        DECLARE @Msg NVARCHAR(MAX) = CHAR(13)+CHAR(10)+
                  'Expected: ' + ISNULL('<'+@Expected+'>', 'NULL') +
                  CHAR(13)+CHAR(10)+
                  'but was : ' + ISNULL('<'+@Actual+'>', 'NULL');
        PRINT @Msg;
        RAISERROR('testConvertIntoInserts.test1 - failed!', 16, 10);
    END
    ELSE
    BEGIN
        PRINT 'testConvertIntoInserts.test1 - passed'
    END
END;
GO