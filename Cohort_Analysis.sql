create database cohort_analysis;
-- create database cohort_analysis;
create table invoice_data( 
InvoiceNo varchar(20),
StockCode varchar(20),
Description	 varchar(255),
Quantity	int,
InvoiceDate	 datetime,
UnitPrice	float,
CustomerID	varchar(100),
Country varchar(20));

select count(*) from invoice_data;

-- cleaning the data and storing the result in temp table

create temporary table sales_data as
select distinct * from invoice_data where UnitPrice > 0 and CustomerID != 0 and quantity > 0 ;

-- Begin cohort analysis
select * from sales_data ;

create temporary table cohort_table as
select customerid, min(invoicedate) as first_purchase_date, 
DATE(CONCAT(YEAR(MIN(invoicedate)), '-', MONTH(MIN(invoicedate)), '-01')) as cohort_date 
from sales_Data
group by customerid;

-- creating cohort index. A cohort index is an integer representation of the number of months that has passed since the customers first engagement.

create temporary table Cohort_Retention As
select mmm.*,
(year_diff*12 + month_diff + 1) as cohort_index
from 
	(
	   select mm.*, 
			  (invoice_year - cohort_year) as year_diff ,
			  (invoice_month - cohort_month) as month_diff
			
		from
			  (
				select s.*, c.cohort_date,
				year(s.invoicedate) invoice_year,
				month(s.invoicedate) invoice_month,
				year(c.cohort_date) cohort_year,
				month(c.cohort_date) cohort_month
				from sales_data s left join cohort_table c on s.customerid = c.customerid
				
				) mm
	 )mmm
   order by  customerid, cohort_index;

-- Final display of cohort retention data

select distinct customerid, cohort_index, cohort_date,
 invoicedate 
from cohort_retention
order by 1,2;

select count(customerid), cohort_index from cohort_retention group by cohort_index order by 2;

-- Displaying cohort table data

create temporary table cohort_results_table
as 
select 
Cohort_Date	,
count(case when cohort_index = '1' then customerid else null end) as Cohort_1,
count(case when cohort_index = '2' then customerid else null end) as Cohort_2,
count(case when cohort_index = '3' then customerid else null end) as Cohort_3,
count(case when cohort_index = '4' then customerid else null end) as Cohort_4,
count(case when cohort_index = '5' then customerid else null end) as Cohort_5,
count(case when cohort_index = '6' then customerid else null end) as Cohort_6,
count(case when cohort_index = '7' then customerid else null end) as Cohort_7
from cohort_retention
group by cohort_date
order by 1;
select * from cohort_results_table;
-- Calculating retention percentage for cohort table

select Cohort_date,
concat(round((cohort_1/cohort_1)*100, 2), '%') as 1_Retention,
concat(round((cohort_2/cohort_1)*100, 2), '%') as 2_Retention,
concat(round((cohort_3/cohort_1)*100, 2), '%') as 3_Retention,
concat(round((cohort_4/cohort_1)*100, 2), '%') as 4_Retention,
concat(round((cohort_5/cohort_1)*100, 2), '%') as 5_Retention,
concat(round((cohort_6/cohort_1)*100, 2), '%') as 6_Retention,
concat(round((cohort_7/cohort_1)*100, 2), '%') as 7_Retention
from cohort_results_table
order by 1;







 
