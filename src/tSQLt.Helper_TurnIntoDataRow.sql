-- docker run -e 'ACCEPT_EULA=1' -e 'MSSQL_SA_PASSWORD=StrongP@ssw0rd!' -p 1433:1433 -d mcr.microsoft.com/azure-sql-edge
-- Invoke-Sqlcmd -ServerInstance localhost -Username sa -Password StrongP@ssw0rd! -Verbose -InputFile ./src/tSQLt.Helper_TurnIntoDataRow.sql

if not exists (select 1 from sys.schemas where name = 'tSQLt')
begin
	exec('create schema tSQLt;');
end
go

if not exists (select 1 from sys.objects where type = 'P' and object_id = object_id('tSQLt.Helper_TurnIntoDataRow'))
begin
	exec('create procedure tSQLt.Helper_TurnIntoDataRow as begin set nocount on; end')
end
go

if not exists (select 1 from sys.objects where type = 'P' and object_id = object_id('tSQLt.Private_FormatCell'))
begin
	exec('create procedure tSQLt.Private_FormatCell as begin set nocount on; end')
end
go

alter procedure tSQLt.Private_FormatCell
(
	@RowNumber int,
	@ColumnNumber int,
	@Result nvarchar(max) output
)
as
begin
	declare @colName nvarchar(max) = (select COLUMN_NAME from #cols where ORDINAL_POSITION = @ColumnNumber);

	declare @isQuoted bit = case when exists(
	select 1 from #cols where column_name = @colName
	and data_type in ('char', 'nchar', 'varchar', 'nvarchar', 'uniqueidentifier', 'date', 'datetime', 'datetime2')
	) then 1 else 0 end;

	declare @isDate bit = case when exists(
	select 1 from #cols where column_name = @colName
	and data_type in ('date', 'datetime', 'datetime2')
	) then 1 else 0 end;

	declare @command nvarchar(max) = 'select @Result = convert(nvarchar(max), ' + @colName + ') from #rows where RowNumber = ' + CONVERT(nvarchar(max), @RowNumber);
	if @isDate = 1
	begin
		set @command = 'select @Result = convert(nvarchar(max), ' + @colName + ', 121) from #rows where RowNumber = ' + CONVERT(nvarchar(max), @RowNumber);
	end

	declare @params nvarchar(max) = N'@Result nvarchar(max) output';
	exec sp_executesql @command, @params, @Result = @Result OUTPUT;

	if @isQuoted = 1
	begin
		set @Result = '''' + @Result + ''''
	end

	if @Result is null
	begin
		set @Result = 'NULL'
	end
end;
go
alter procedure tSQLt.Helper_TurnIntoDataRow
(
	@TableName nvarchar(max),
	@Query nvarchar(max),
	@Result nvarchar(max) output
)
as
begin
	-- Prepare
	declare @command nvarchar(max) = 'select * into ##rows from (' + @Query + ') a';
	exec sp_executesql @command;

	select * into #cols
	from tempdb.INFORMATION_SCHEMA.COLUMNS
	where TABLE_SCHEMA = 'dbo'
	and TABLE_NAME = '##rows';
	select RowNumber = row_number() over(order by (select 1)), * into #rows from ##rows;

	declare @cols int = (select count(1) from #cols);
	declare @rows int = (select count(1) from #rows);

	--select * from #rowData
	declare @columns nvarchar(max) = '';
	declare @rowData nvarchar(max) = '';
	declare @idx int = 0;
	declare @idc int = 0;
	declare @cell nvarchar(max) = '';

	-- Columns
	select @columns = ltrim(stuff((select ', ' + COLUMN_NAME from #cols for xml path('')), 1, 1,''));
	update #cols set CHARACTER_MAXIMUM_LENGTH = 0;

	-- RowData
	set @idx = 0;
	while @idx < @rows
	begin
		set @idx = @idx + 1;
		set @idc = 0;
		while @idc < @cols
		begin
			set @idc = @idc + 1;
			set @cell = '';
			exec tSQLt.Private_FormatCell @idx, @idc, @cell output;
			update #cols set CHARACTER_MAXIMUM_LENGTH = len(@cell)
			where ORDINAL_POSITION = @idc and CHARACTER_MAXIMUM_LENGTH < len(@cell);
		end
	end

	set @rowData = '';
	set @idx = 0;
	while @idx < @rows
	begin
		set @idx = @idx + 1;

		set @rowData = @rowData + char(13) + char(10) + '    (';

		set @idc = 0;
		while @idc < @cols
		begin
			set @idc = @idc + 1;

			set @cell = '';
			exec tSQLt.Private_FormatCell @idx, @idc, @cell output;

			declare @colLength int = (select CHARACTER_MAXIMUM_LENGTH from #cols where ORDINAL_POSITION = @idc);

			set @rowData = @rowData + right('                                                                                         ' + @cell, @colLength);

			if @idc < @cols
			begin
				set @rowData = @rowData + ', '
			end
		end

		if @idx < @rows
		begin
			set @rowData = @rowData + '),'
		end
		else
		begin
			set @rowData = @rowData + ');'
		end
	end

	set @Result = '';
	set @Result = @Result + 'insert into ' + @TableName + ' ('
	set @Result = @Result + @columns
	set @Result = @Result + ') values';
	set @Result = @Result + @rowData;
end;
go
