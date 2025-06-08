--creating branch table 
drop table if exists branch
 create table branch(
 branch_id text primary key,
 manager_id text,
 branch_address text,
 contact_no text
)
-- creating employee table
drop table if exists employee;
create table employee(
emp_id text primary key,
emp_name text,
position text,
salary float,
branch_id text -- fr key
);
-- creating book table
drop table if exists book;
create table book(
isbn  text primary key,
book_title varchar(80),
category varchar(20),
rental_price float,
status varchar(15),	
author varchar(25),	
publisher varchar(50)
);
-- creating book table
drop table if exists members;
create table members(
member_id text primary key,
member_name text,
member_address text,
reg_date DATE
);
-- creating issue table
drop table if exists issue;
create table issue(
issued_id text primary key,	
issued_member_id text,--fr key
issued_book_name text,
issued_date DATE,
issued_book_isbn text,  -- fr key
issued_emp_id text--- fr key
);
-- creating rerturn table
drop table if exists returnstatus;
create table returnstatus(
return_id text primary key,
issued_id	text, 
return_book_name text,
return_date DATE,
return_book_isbn text 
);
select * from returnstatus
-- Adding foreign key
alter table issue
add constraint fk_members
foreign key(issued_member_id)
references members(member_id);

alter table issue
add constraint fk_books
foreign key(issued_book_isbn)
references book (isbn);

alter table issue
add constraint fk_employee
foreign key(issued_emp_id)
references employee(emp_id);

alter table employee
add constraint fk_branch
foreign key(branch_id)
references branch(branch_id);

alter table returnstatus
add constraint fk_issue
foreign key(issued_id)
references issue(issued_id);
-- questions
--Q1. Create a New Book Record -- "978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

select * from book
insert into book (isbn,book_title,category,rental_price,status,author,publisher)
values
('978-1-60129-456-2','To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

--Q2.Update an Existing Member's Address of any member
select * from members

update members
set member_address='125 Main St'
where member_id='C101';
--Q3.Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
select * from issue
delete from issue
where issued_id='IS121';

-- Q4.Retrieve All Books Issued by a Specific Employee --
--Objective: Select all books issued by the employee with emp_id = 'E101'.

select * from issue
where issued_emp_id ='E101'
--Q5. List Members Who Have Issued More Than One Book --
--Objective: Use GROUP BY to find members who have issued more than one book.
select issue.issued_member_id,members.member_name,count (issue.issued_member_id) as count_book
from issue
join members on issue.issued_member_id=members.member_id
group by issue.issued_member_id,members.member_name
having count (issue.issued_member_id)  >1
order by 3 desc
--Q6.Create Summary Tables: 
--Used CTAS to create or generate new tables based on query results - each book and total book_issued_cnt
create table book_count
as

select issue.issued_book_isbn,issue.issued_book_name,count(issue.issued_id)
from issue
group by 1,2
order by 2,3 

select * from book_count
--Q7.Retrieve All Books in a Specific Category:
select *
from book
where category='Classic'

--Q8.Find Total Rental Income by Category:

select book.category,sum(book.rental_price),count(*)
from book
join issue on issue.issued_book_isbn=book.isbn
group by 1
order by 2 desc
--Q9.List members who have regisgtered in last 180 days(C122,Kram,565 boleuvard,2025-02-26)
insert into members(member_id,member_name,member_address,reg_date)
values
('C121','gram','564 boleuvard','2025-02-25'),
('C122','Kram','565 boleuvard','2025-02-26');
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';

--Q10.List employees with their branch manager name and thier branch details

select e1.*,e2.emp_name as manger_name,branch.manager_id
from employee as e1
left join branch on branch.branch_id=e1.branch_id
join employee as e2
on branch.manager_id=e2.emp_id
--Q11.Create a table of books where rental price is above the certain threshold(for ex-6)

create table booky_book
as
select * from book
where rental_price>6.5

select * from booky_book
--Q12.Retrieve al the books that are not returned yet

select distinct i.issued_id,i.issued_book_name
 from issue as i
 left join returnstatus as r
 on r.issued_id=i.issued_id
 where r.return_id is NULL

-- INSERT INTO book_issued in last 30 days
-- SELECT * from employees;
-- SELECT * from books;
-- SELECT * from members;
-- SELECT * from issued_status


INSERT INTO issue(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

-- Adding new column in return_status

ALTER TABLE returnstatus
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE returnstatus
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM returnstatus;

select * from issue
select * from book
select * from members
select * from employee
select * from branch
select * from returnstatus

/*
Q13:
Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period).
Display the member's_id, member's name, book title, issue date, and days overdue.
*/
with book_status as(
select members.member_id,members.member_name,book.book_title
,issue.issued_date,returnstatus.return_date,current_date-issue.issued_date as day_taken
from issue
join book on book.isbn=issue.issued_book_isbn
left join returnstatus on returnstatus.issued_id=issue.issued_id
 join members on members.member_id=issue.issued_member_id
where returnstatus.return_date is null and (current_Date-issue.issued_date )>30
order by 1
)
select * from book_status

/*
Q14. Update Book Status on Return
Write a query to update the status of books in the books table 
to "Yes" when they are returned (based on entries in the return_status table).
*/

select * from book
select * from issue
select * from returnstatus


-- this question is done using stored procedures
create or replace procedure add_return_records(p_return_id varchar(10),p_issued_id varchar(10),p_book_quality varchar(10))
language plpgsql
AS $$

declare
  v_isbn varchar(50);
  v_book_name varchar(80);

begin
--all the logic comes here
-- user enters the input based on the code written here
insert into returnstatus(return_id,issued_id,return_date,book_quality)
values
(p_return_id,p_issued_id,current_date,p_book_quality);

select 
issued_book_isbn,issued_book_name
into
v_isbn,v_book_name
from issue
where issued_id=p_issued_id;

update book
set status='yes'
where isbn=v_isbn;

RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
end
$$

-- Testing and calling fucntion
issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM book
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issue
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM returnstatus
WHERE issued_id = 'IS135';

--calling the function 
call add_return_records('RS138','IS135','Good')

CALL add_return_records('RS148', 'IS140', 'Good');

/*
Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

create table  branch_report
AS
with branch_revenue as(
select branch.branch_id as branch_,count(issue.issued_id) as books_issued,count(rst.return_id)as books_returned,sum(book.rental_price) as 
total_revenue
from issue
left join returnstatus as rst
on rst.issued_id=issue.issued_id
join book on book.isbn=issue.issued_book_isbn
join employee on employee.emp_id=issue.issued_emp_id
join branch on branch.branch_id=employee.branch_id
group by 1

)
select * from branch_revenue
order by 1

select * from branch_report

/*
CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to
create a new table active_members containing members who have issued at least one book in the last 6 months.
*/

create table active_members
as
select * from members
 where member_id in(
         select distinct members.member_id
         from issue
          join members on members.member_id=issue.issued_member_id
          where issued_date>=current_date -interval '6 month')
 
select * from active_members

/*
Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name,
number of books processed, and their branch.
*/
select branch.branch_id,issue.issued_emp_id,employee.emp_name,
count(issue.issued_id) as number_of_book_issued
from issue
 join  employee on employee.emp_id=issue.issued_emp_id
 join branch on branch.branch_id=employee.branch_id
 group by 1,2,3
 order by 4 desc
 limit 3

 /*
 Stored Procedure Objective:
 Create a stored procedure to manage the status of books in a library system.
 Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
 The procedure should function as follows: 
 The stored procedure should take the book_id as an input parameter. 
 The procedure should first check if the book is available (status = 'yes'). If the book is available, 
 it should be issued, 
 and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
 the procedure should return an error message indicating that the book is currently not available.
 */
 select * from book
 select * from issue

create or replace procedure status_of_book(p_issued_id varchar(10),p_issued_member_id varchar(30)
,p_issued_book_isbn varchar(50),p_issued_emp_id varchar(10))
language plpgsql
AS $$

declare
  v_status varchar(10);

begin
--All the logic is written here
-- first checking if book is available 'yes'
      select status
	  into
	  v_status
	  from book
	  where isbn=p_issued_book_isbn;

	  --if it is available
	  if v_status='yes' then
      insert into issue(issued_id,issued_member_id,issued_date,issued_book_isbn,issued_emp_id)
      values
	  (p_issued_id,p_issued_member_id,current_date,p_issued_book_isbn,p_issued_emp_id);


       update book
       set status='no'
       where isbn=p_issued_book_isbn;

	  raise notice 'book record added successfully for book isbn: %',p_issued_book_isbn;

       -- if not availble
	   else 
        raise notice 'sorry book is not available for book isbn: %',p_issued_book_isbn;

	   end if;
	   
end;
$$
select * from book
select * from issue
--"978-0-553-29698-2"-yes
--"978-0-7432-7357-1"-no

call status_of_book('IS155','C108','978-0-553-29698-2','E111')
call status_of_book('IS156','C109','978-0-7432-7357-1','E112')