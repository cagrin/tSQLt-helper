create procedure tSQLtHelper.ConvertIntoInserts
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
			exec tSQLtHelper.Private_FormatCell @idx, @idc, @cell output;
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
			exec tSQLtHelper.Private_FormatCell @idx, @idc, @cell output;

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
