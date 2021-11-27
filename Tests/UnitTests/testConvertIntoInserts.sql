create schema testConvertIntoInserts;
go

create procedure testConvertIntoInserts.test1
as
begin
    SET NOCOUNT ON;
--- Arrange
	IF OBJECT_ID('tempdb..#invoice') IS NOT NULL
	BEGIN
		DROP TABLE #invoice;
	END

    create table #invoice
    (
        inv_id int not null,
        inv_type char(3) not null,
        inv_cust_id varchar(100) null,
        inv_amount money not null,
        inv_date date null,
        inv_error nvarchar(max) null
    );

	insert into #invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) values
    (1, 'FV', 'ABCDE12345', 100.00, '2021-11-27', NULL),
    (2, 'FV1', 'Zażółć gęślą jaźń', -1.00, '2021-11-28', NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '2021-11-29', '?'),
    (4, 'A', 'ABCDE12345', 0.00, NULL, 'An error occurred');

--- Act
	declare @Actual nvarchar(max);

	exec tSQLtHelper.ConvertIntoInserts
		@TableName = 'dbo.invoice',
		@Query = 'select inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error from #invoice',
		@Result = @Actual output;

--- Assert
	declare @expected nvarchar(max) = 'insert into dbo.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) values
    (1, ''FV '',          ''ABCDE12345'',  100.00, ''2021-11-27'', NULL),
    (2, ''FV1'',   ''Zażółć gęślą jaźń'',   -1.00, ''2021-11-28'', NULL),
    (3, ''FV2'', ''qwerty asdfgh zxcvb'', 1234.56, ''2021-11-29'', ''?''),
    (4, ''A  '',          ''ABCDE12345'',    0.00,         NULL, ''An error occurred'');';

    set @expected = replace(@expected, char(13) + char(10), char(10));
    set @Actual = replace(@Actual, char(13) + char(10), char(10));

	if not((@expected = @Actual) or (@Actual is null and @expected is null))
    begin
        DECLARE @Msg NVARCHAR(MAX) = CHAR(13)+CHAR(10)+
                  'Expected: ' + ISNULL('<'+@Expected+'>', 'NULL') +
                  CHAR(13)+CHAR(10)+
                  'but was : ' + ISNULL('<'+@Actual+'>', 'NULL');
        PRINT @Msg;
        RAISERROR('testConvertIntoInserts.test1 - failed!', 16, 10);
    end
    else
    begin
        print 'testConvertIntoInserts.test1 - passed'
    end
end;
go