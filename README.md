# Library Management System  SQL Project 

## Project Overview

**Project Title**: Library Management System  
**Database**: `Library Management System`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/giriaman610/Library-Management-System/blob/main/Schema%20Diagram.png)

- **Database Creation**: Created a database named `Library Management System`.
- **Table Creation**: Created tables for branche, employee, members, book, issue , and returnstatus. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE Library Management System;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employee;
CREATE TABLE employee
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Book"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issue;
CREATE TABLE issue
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS returnstatus;
CREATE TABLE returnstatus
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
--Adding Foreign Key
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
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `book` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employee` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
select issue.issued_member_id,members.member_name,count (issue.issued_member_id) as count_book
from issue
join members on issue.issued_member_id=members.member_id
group by issue.issued_member_id,members.member_name
having count (issue.issued_member_id)  >1
order by 3 desc
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
create table book_count
as

select issue.issued_book_isbn,issue.issued_book_name,count(issue.issued_id)
from issue
group by 1,2
order by 2,3
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
select *
from book
where category='Classic'
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
select book.category,sum(book.rental_price),count(*)
from book
join issue on issue.issued_book_isbn=book.isbn
group by 1
order by 2 desc
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
insert into members(member_id,member_name,member_address,reg_date)
values
('C121','gram','564 boleuvard','2025-02-25'),
('C122','Kram','565 boleuvard','2025-02-26');
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
select e1.*,e2.emp_name as manger_name,branch.manager_id
from employee as e1
left join branch on branch.branch_id=e1.branch_id
join employee as e2
on branch.manager_id=e2.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
create table booky_book
as
select * from book
where rental_price>6.5

```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
select distinct i.issued_id,i.issued_book_name
 from issue as i
 left join returnstatus as r
 on r.issued_id=i.issued_id
 where r.return_id is NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
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
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

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

```




**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
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

```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

create table active_members
as
select * from members
 where member_id in(
         select distinct members.member_id
         from issue
          join members on members.member_id=issue.issued_member_id
          where issued_date>=current_date -interval '6 month')
 
select * from active_members

```


**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
select branch.branch_id,issue.issued_emp_id,employee.emp_name,
count(issue.issued_id) as number_of_book_issued
from issue
 join  employee on employee.emp_id=issue.issued_emp_id
 join branch on branch.branch_id=employee.branch_id
 group by 1,2,3
 order by 4 desc
 limit 3
```


**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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
```


## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.
