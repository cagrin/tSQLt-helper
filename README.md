# tSQLt-helpers
Helpers for tSQLt framework.

## ConvertIntoInserts

Procedure convert select query into inserts command.

Usage
```SQL
declare @insertsCommand nvarchar(max);

exec tSQLt-helpers.ConvertIntoInserts
    @TableName = 'stt.invoice',
    @Query = 'select inv_id, inv_type, inv_cust_id, inv_amount, inv_error from stt.invoice',
    @Result = @insertCommand output;

exec sys.sp_executesql @insertsCommand;
```