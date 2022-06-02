CREATE SCHEMA testConvertIntoInserts;
GO

CREATE PROCEDURE testConvertIntoInserts.test1
AS
BEGIN
--- Arrange
    CREATE TABLE #invoice
    (
        inv_id INT NOT NULL,
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
	DECLARE @Expected NVARCHAR(MAX) = CONCAT_WS
    (
        NCHAR(10),
        'INSERT INTO dbo.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) VALUES',
        '    (1, ''FV '',          ''ABCDE12345'',  100.00, ''2021-11-27'', NULL),',
        '    (2, ''FV1'',   ''Zażółć gęślą jaźń'',   -1.00, ''2021-11-28'', NULL),',
        '    (3, ''FV2'', ''qwerty asdfgh zxcvb'', 1234.56, ''2021-11-29'', ''?''),',
        '    (4, ''A  '',          ''ABCDE12345'',    0.00,         NULL, ''An ERROR occurred'');'
    );

    EXEC tSQLt.AssertEqualsString @Expected, @Actual;
END;
GO