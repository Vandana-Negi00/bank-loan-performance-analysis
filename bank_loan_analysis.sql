-- creating database

create database Bank_Loan_DB;
use Bank_Loan_DB;

DROP TABLE bank_loan_data;

-- create Table
CREATE TABLE bank_loan_data (
id INT,
address_state VARCHAR(50),
application_type VARCHAR(50),
emp_length VARCHAR(50),
emp_title VARCHAR(100),
grade VARCHAR(10),
home_ownership VARCHAR(50),
issue_date VARCHAR(50),
last_credit_pull_date VARCHAR(20),
last_payment_date VARCHAR(50),
loan_status VARCHAR(50),
next_payment_date VARCHAR(20),
member_id INT,
purpose VARCHAR(100),
sub_grade VARCHAR(10),
term VARCHAR(20),
verification_status VARCHAR(50),
annual_income DOUBLE,
dti DOUBLE,
installment DOUBLE,
int_rate DOUBLE,
loan_amount DOUBLE,
total_acc INT,
total_payment DOUBLE
);

SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

-- Load the dataset
LOAD DATA LOCAL INFILE 'C:/Users/Vandana/Downloads/financial_loan.csv'
INTO TABLE bank_loan_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


-- checking the dataset.
select * from bank_loan_data
limit 5;

-- Step 1: Convert date columns stored as text (VARCHAR) into proper DATE format.
-- The dataset contains two formats: DD-MM-YY (25-02-21) and DD-MM-YYYY (11-02-2021).
-- We use CASE and STR_TO_DATE() to correctly convert both formats.
UPDATE bank_loan_data
SET 
issue_date =
CASE
    WHEN LENGTH(issue_date)=8 THEN STR_TO_DATE(issue_date,'%d-%m-%y')
    WHEN LENGTH(issue_date)=10 THEN STR_TO_DATE(issue_date,'%d-%m-%Y')
END,

last_credit_pull_date =
CASE
    WHEN LENGTH(last_credit_pull_date)=8 THEN STR_TO_DATE(last_credit_pull_date,'%d-%m-%y')
    WHEN LENGTH(last_credit_pull_date)=10 THEN STR_TO_DATE(last_credit_pull_date,'%d-%m-%Y')
END,

last_payment_date =
CASE
    WHEN LENGTH(last_payment_date)=8 THEN STR_TO_DATE(last_payment_date,'%d-%m-%y')
    WHEN LENGTH(last_payment_date)=10 THEN STR_TO_DATE(last_payment_date,'%d-%m-%Y')
END,

next_payment_date =
CASE
    WHEN LENGTH(next_payment_date)=8 THEN STR_TO_DATE(next_payment_date,'%d-%m-%y')
    WHEN LENGTH(next_payment_date)=10 THEN STR_TO_DATE(next_payment_date,'%d-%m-%Y')
END;

-- change the datatype
ALTER TABLE bank_loan_data
MODIFY issue_date DATE,
MODIFY last_credit_pull_date DATE,
MODIFY last_payment_date DATE,
MODIFY next_payment_date DATE;

-- confirming the dtypes
DESCRIBE bank_loan_data;

-- find total loan applications.
select count(id) as Total_Applications from bank_loan_data;


-- Total loan applications for month to date (MTD).
-- current data is of december month so we will filter that data.

SELECT COUNT(id) AS Total_Applications_MTD
FROM bank_loan_data
WHERE MONTH(issue_date) = 12 and year(issue_date) = 2021 ;

-- Total loan applications for previous month to date (PMTD).
select count(id) as Total_Applications_PMTD from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021 ;


-- Total funded amount.
select sum(loan_amount) as Total_funded_amount
from bank_loan_data;

-- MTD total funded amount.
select sum(loan_amount) as MTD_TOTAL_FUNDED_AMT from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021 ;

-- PMTD TOTAL FUNDED AMOUNT.
 select sum(loan_amount) as PMTD_TOTAL_FUNDED_AMT from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021 ;


-- FIND TOTAL AMOUNT RECEIVED.
select sum(total_payment) as Total_payment from bank_loan_data;

-- MTD TOTAL AMOUNT RECEIVED.
select sum(total_payment) as MTD_Total_payment from bank_loan_data
where month(issue_date) = 12 and year(issue_date) = 2021 ;

-- PMT TOTAL AMOUNT RECEIVED.
select sum(total_payment) as PMTD_Total_payment from bank_loan_data
where month(issue_date) = 11 and year(issue_date) = 2021 ;

-- FIND AVERAGE INTEREST RATE.
select round(avg(int_rate) * 100 ,2) as AVG_INT_RATE from bank_loan_data;

-- FIND MTD AVERAGE INTERST RATE.
select round(avg(int_rate) * 100 ,2) as MTD_AVG_INT_RATE from bank_loan_data
where month(issue_date) = 12 ;

-- FIND PMTD AVERAGE INTERST RATE.
select round(avg(int_rate) * 100 ,2) as PMTD_AVG_INT_RATE from bank_loan_data
where month(issue_date) = 11 ;

-- FIND AVERAGE DTI(DEBT TO INCOME RATIO).
select round(avg(dti)*100 ,2) as AVERAGE_DTI
FROM bank_loan_data;

-- FIND MTD AVERAGE DTI.
select round(avg(dti)*100 ,2) as MTD_AVERAGE_DTI
FROM bank_loan_data
where month(issue_date) = 12;

-- FIND PMTD AVERAGE DTI.
select round(avg(dti)*100 ,2) as PMTD_AVERAGE_DTI
FROM bank_loan_data
where month(issue_date) = 11;

-- find good loan application %
select count(case when loan_status = 'Current' or loan_status = 'Fully Paid' then id end) *100
/
count(id) as good_loan_percentage
from bank_loan_data ;

-- find total good loan applications.
select count(id) as good_loan_application from bank_loan_data
where loan_status = 'Current' or loan_status = 'Fully Paid';

-- find good loan funded amount.
select sum(loan_amount) as good_loan_funded_amt from bank_loan_data
where loan_status = 'Current' or loan_status = 'Fully Paid';

-- find total good loan payment amount received.
SELECT SUM(total_payment) AS Good_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

-- find total bad loan application %.

SELECT (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100.0) / 
	COUNT(id) AS Bad_Loan_Percentage
FROM bank_loan_data;

-- find total bad loan applications.
select count(id) as TOTAL_BAD_LOAN_APPLICATIONS
from bank_loan_data
where loan_status = 'Charged Off' ;

-- find Bad Loan Funded Amount
SELECT SUM(loan_amount) AS Bad_Loan_Funded_amount FROM bank_loan_data
WHERE loan_status = 'Charged Off'

-- FIND Bad Loan Amount Received
SELECT  SUM(total_payment) AS Bad_Loan_amount_received FROM bank_loan_data
WHERE loan_status = 'Charged Off' ;

-- check the summary report of the loans.

select loan_status,
count(id) as TOTAL_Loan_Applications,
sum(total_payment) as TOTAL_Amount_received,
sum(loan_amount) as Total_funded_amount,
(sum(total_payment) - sum(loan_amount)) as profit,
avg(int_rate *100) as INTEREST_RATE,
avg(dti *100) as Avg_DTI
FROM bank_loan_data
group by loan_status ;

-- MTD LOAN EVALUATION.
select loan_status,
sum(total_payment) as MTD_Total_Payment_Received,
sum(loan_amount) as MTD_Total_Loan_Amt
from bank_loan_data
where month(issue_date) = 12
group by loan_status;

-- PMTD LOAN EVALUATION.
select loan_status,
sum(total_payment) as PMTD_Total_Payment_Received,
sum(loan_amount) as PMTD_Total_Loan_Amt
from bank_loan_data
where month(issue_date) = 11
group by loan_status;

-- monthly trends.
select month(issue_date) , monthname(issue_date) as month_name,
count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_loan_amount
from bank_loan_data
group by month(issue_date) , monthname(issue_date)
order by month(issue_date) ;

-- Regional analysis by state.
select address_state ,
count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_loan_amount
from bank_loan_data
group by address_state
order by address_state desc ;


-- loan term analysis.

select term , count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_funded_amount
from bank_loan_data
group by term
order by term ;

-- Employee Length Analysis
select emp_length , 
count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_funded_amount
from bank_loan_data
group by emp_length 
order by count(id) desc ;

-- Loan Purpose Breakdown 
select purpose , 
count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_funded_amount
from bank_loan_data
group by purpose
order by count(id) desc ;

-- Home Ownership Analysis
select home_ownership , 
count(id) as Total_applications,
sum(total_payment) as total_payment_received,
sum(loan_amount) as total_funded_amount
from bank_loan_data
group by home_ownership
order by count(id) desc ;

