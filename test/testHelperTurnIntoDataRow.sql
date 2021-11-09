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
    int_amount money not null
);
go
insert into stt.invoice (inv_id, inv_type, inv_cust_id, int_amount) values
(1,  'FV',          'ABCDE12345',  100.00),
(2, 'FV1',   'Zazółć gęślą jaźn',   -1.00),
(3, 'FV2', 'qwerty asdfgh zxcvb', 1234.56),
(4,   'A',          'ABCDE12345',    0.00);
go
select inv_id, inv_type, inv_cust_id, int_amount
from stt.invoice;
go