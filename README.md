# tSQLtHelper
Helpers for tSQLt framework.

## ConvertIntoInserts

This procedure converts ```@Query``` for given table into single insert command with many lines of values.

### Usage
```SQL
DECLARE @insertsCommand NVARCHAR(max);

EXEC tSQLtHelper.ConvertIntoInserts
    @TableName = 'dbo.invoice',
    @Query = 'SELECT inv_id, inv_type, inv_cust_id, inv_amount, inv_error FROM dbo.invoice',
    @Result = @insertCommand OUTPUT;

EXEC sp_executesql @insertsCommand;
```

where ```@insertsCommand``` is nicely formatted SQL command, which can be used inside tSQLt test.
```SQL
INSERT INTO dbo.invoice (inv_id, inv_type, inv_cust_id, inv_amount, inv_date, inv_error) VALUES
    (1, 'FV ',          'ABCDE12345',  100.00, '2021-11-27', NULL),
    (2, 'FV1',   'Zażółć gęślą jaźń',   -1.00, '2021-11-28', NULL),
    (3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56, '2021-11-29', '?'),
    (4, 'A  ',          'ABCDE12345',    0.00,         NULL, 'An ERROR occurred');
```