create procedure tSQLt.Private_FormatCell
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