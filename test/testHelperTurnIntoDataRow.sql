drop table stt.invoice;
go
drop schema stt;
go

create schema stt;
go
create table stt.invoice
(
    inv_id int not null,
    inv_type char(3) not null,
    inv_cust_id varchar(100) not null,
    inv_amount money not null,
    inv_error nvarchar(max) null
);
go
insert into stt.invoice
    (inv_id, inv_type, inv_cust_id, inv_amount, inv_error)
values
    (1, 'FV', 'ABCDE12345', 100.00, NULL),
    (2, 'FV1', 'Zazółć gęślą jaźn', -1.00, NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '?'),
    (4, 'A', 'ABCDE12345', 0.00, 'An error occurred');
go

declare @max int = (select count(1) from stt.invoice);
declare @idx int = 0
declare @schema_name varchar(100) = 'stt'
declare @table_name varchar(100) = 'invoice'
declare @column_name varchar(100);
declare @command nvarchar(max) = 'select ''''''''+'
while @idx < @max
begin
    set @idx = @idx + 1;

    select @column_name = COLUMN_NAME
    from INFORMATION_SCHEMA.COLUMNS
    where TABLE_SCHEMA = 'stt'
    and TABLE_NAME = 'invoice'
    and ORDINAL_POSITION = @Idx

    set @command = @command +  ' '''' + convert(varchar, ' + @column_name + ') + '

    if @idx < @max
    begin
        set @command = @command +  ' '''''', '''''' +'
    end
end
set @command = @command +  ' '''''''' from ' + @schema_name + '.' + @table_name
exec sp_executesql @command
go