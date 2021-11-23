create table stt.invoice
(
    inv_id int not null,
    inv_type char(3) not null,
    inv_cust_id varchar(100) null,
    inv_amount money not null,
    inv_error nvarchar(max) null
);
go