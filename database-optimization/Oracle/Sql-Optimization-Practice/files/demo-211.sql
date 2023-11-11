--����������
prompt Dropping TABLE_1...
drop table TABLE_1 cascade constraints;
prompt Dropping TABLE_2...
drop table TABLE_2 cascade constraints;
prompt Creating TABLE_1...
create table TABLE_1
(
  col_1      VARCHAR2(2),
  col_2      VARCHAR2(2),
  col_3      VARCHAR2(2),
  serv_type  VARCHAR2(20),
  valid_date NUMBER
)
tablespace SYSTEM
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

prompt Creating TABLE_2...
create table TABLE_2
(
  b_type   VARCHAR2(20),
  servtype VARCHAR2(20)
)
tablespace SYSTEM
  pctfree 10
  pctused 40
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );

prompt Disabling triggers for TABLE_1...
alter table TABLE_1 disable all triggers;
prompt Disabling triggers for TABLE_2...
alter table TABLE_2 disable all triggers;
prompt Loading TABLE_1...
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '01', 'Linux', 9);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '01', 'Linux', 9);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '01', 'Linux', 8);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '01', 'Unix', 1);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '01', 'Windows', 6);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '01', '02', 'Linux', 9);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '02', '01', 'Windows', 4);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '02', '02', 'Linux', 4);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('01', '02', '02', 'Windows', 5);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '01', '01', 'Unix', 2);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '01', '01', 'Unix', 3);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '01', '02', 'Linux', 8);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '01', '02', 'Windows', 4);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '02', '01', 'Windows', 5);
insert into TABLE_1 (col_1, col_2, col_3, serv_type, valid_date)
values ('02', '02', '02', 'Windows', 6);
commit;
prompt 15 records loaded
prompt Loading TABLE_2...
insert into TABLE_2 (b_type, servtype)
values ('01', 'Linux');
insert into TABLE_2 (b_type, servtype)
values ('02', 'Unix');
insert into TABLE_2 (b_type, servtype)
values ('03', 'Windows');
commit;
prompt 3 records loaded
prompt Enabling triggers for TABLE_1...
alter table TABLE_1 enable all triggers;
prompt Enabling triggers for TABLE_2...
alter table TABLE_2 enable all triggers;
