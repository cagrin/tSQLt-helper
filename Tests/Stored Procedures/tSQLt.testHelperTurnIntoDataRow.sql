create procedure tSQLt.testHelperTurnIntoDataRow
as
begin
--- Arrange
	insert into stt.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_error) values
    (1, 'FV', 'ABCDE12345', 100.00, NULL),
    (2, 'FV1', 'Zazółć gęślą jaźn', -1.00, NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '?'),
    (4, 'A', 'ABCDE12345', 0.00, 'An error occurred');

--- Act
	declare @actual nvarchar(max);

	exec tSQLt.Helper_TurnIntoDataRow
		@TableName = 'stt.invoice',
		@Query = 'select inv_id, inv_type, inv_cust_id, inv_amount, inv_error from stt.invoice',
		@Result = @actual output;

--- Assert
	declare @expected nvarchar(max) = 'insert into stt.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_error) values
    (1, ''FV '',          ''ABCDE12345'',  100.00,                NULL),
    (2, ''FV1'',   ''Zazólc gesla jazn'',   -1.00,                NULL),
    (3, ''FV2'', ''qwerty asdfgh zxcvb'', 1234.56,                 ''?''),
    (4, ''A  '',          ''ABCDE12345'',    0.00, ''An error occurred'');';

    set @expected = replace(@expected, char(13) + char(10), char(10));
    set @actual = replace(@actual, char(13) + char(10), char(10));

	if not((@expected = @actual) or (@actual is null and @expected is null))
    begin
        raiserror('tSQLt.testHelperTurnIntoDataRow', 16, 10);
    end

end;
go