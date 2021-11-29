# tSQLtHelper
Helpers for tSQLt framework.

## ConvertIntoInserts

Procedure that converts "select query" into rows of inserts' command.

Usage
```SQL
DECLARE @insertsCommand NVARCHAR(max);

EXEC tSQLtHelper.ConvertIntoInserts
    @TableName = 'stt.invoice',
    @Query = 'SELECT inv_id, inv_type, inv_cust_id, inv_amount, inv_error FROM stt.invoice',
    @Result = @insertCommand OUTPUT;

EXEC sp_executesql @insertsCommand;
```