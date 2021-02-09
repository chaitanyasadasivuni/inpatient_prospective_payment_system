create table inpatient(
drg varchar(100),
pid int,
pname varchar(100),
paddress varchar(100),
pcity varchar(50),
pstate varchar(5),
pzip int,
pregion varchar(100),
discharges int,
avgcharges decimal(15,5),
avgpayments decimal(15,5),
avgmedicarepayments decimal(15,5)
);

select count(*) from inpatient;

select sum(discharges),pstate from inpatient group by pstate order by sum(discharges) asc;
  
select drg,round(avg(avgpayments)) from inpatient group by drg order by round(avg(avgpayments)) asc;

create view phoenix_addresses as select drg,pname,paddress,pzip,pregion from inpatient where pstate='AZ' AND pcity='PHOENIX';
select * from phoenix_addresses;

select max(discharges) from inpatient;
select drg from inpatient where discharges>1000 group by drg;

