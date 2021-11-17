drop procedure tSQLt.testHelperTurnIntoDataRow;
go
drop table stt.invoice;
go
drop schema stt;
go
drop table ##rows;
go

create schema stt;
go
create table stt.invoice
(
    inv_id int not null,
    inv_type char(3) not null,
    inv_cust_id varchar(100) null,
    inv_amount money not null,
    inv_error nvarchar(max) null
);
go
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

    print @actual

	if not((@expected = @actual) or (@actual is null and @expected is null))
    begin
        raiserror('tSQLt.testHelperTurnIntoDataRow', 16, 10);
    end

end;
go
exec tSQLt.testHelperTurnIntoDataRow;
go