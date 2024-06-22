# Load the package required to read JSON files.
# install.packages("DBI")
library(DBI)
library(dbplyr)
library(duckdb)
# library(tidyverse)
library(dplyr)
library(ggplot2)

# this connection connects to an existing database
con <- DBI::dbConnect(duckdb::duckdb(dbdir = "coffee_db"))

?tbl
dplyr::tbl()
dbListTables(con)
dbExecute()

tbl(src = con, "employees")
# access data from duckdb database tables
# Remember these are not actual data frame and are not available in the 
# RStudio environment
# first use tbl() to create an object that represents a database table:
dplyr::tbl(con, "employees")
# This object is lazy; when you use dplyr verbs on it, 
# dplyr doesn’t do any work: it just records the sequence of operations 
# that you want to perform and only performs them when needed.
dplyr::tbl(con, "employees") %>% class()

# To get all the data back into R, you call collect(). 
# Behind the scenes, this generates the SQL, 
# calls dbGetQuery() to get the data, 
# then turns the result into a tibble:
dplyr::tbl(con, "employees") %>% dplyr::collect()

my_employees_tbl <- tbl(con, "employees") %>% collect()

dplyr::tbl(con, "shops") 
dplyr::tbl(con, "locations") 
dplyr::tbl(con, "suppliers") 

# to get the data into RStudio environment for the output of tbl(),
# you will need to convert it to a tibble and assign it a variable name
employees_tbl <- dplyr::tbl(con, "employees") %>% as_tibble()
shops_tbl <- dplyr::tbl(con, "shops") %>% as_tibble()
locations_tbl <- dplyr::tbl(con, "locations") %>% as_tibble()
suppliers_tbl <- dplyr::tbl(con, "suppliers") %>% as_tibble()

class(suppliers_tbl)

# DBI::dbReadTable()

employees_df <- dbReadTable(con, "employees")

class(employees_df)

shops_df <- dbReadTable(con, "shops")
locations_df <- dbReadTable(con, "locations")
suppliers_df <- dbReadTable(con, "suppliers")

# data manipulation

shops_df

?select

dplyr::select(.data = shops_df,coffeeshop_id,coffeeshop_name)

select(employees_df, 1:5) %>% slice(1:10)

head(employees_df)


# SELECT statement
# select all (*) columns from table
dplyr::tbl(con, "employees") %>% show_query()
?show_query
# From our previous lessons,
# dbExecute() is intended for executing SQL statements that don't return 
# a result set, such as INSERT, UPDATE, DELETE, or CREATE TABLE statements. 
# For SQL queries that return results (like SELECT), 
# you should use dbGetQuery() instead.
DBI::dbGetQuery(conn = con, statement = "SELECT employee_id, first_name AS FN, last_name
FROM employees")


dplyr::tbl(con, "shops") %>% show_query()
dplyr::tbl(con, "locations") %>% show_query()
dplyr::tbl(con, "suppliers") %>% show_query()

# select some (3) columns of table

employees_df %>% dplyr::select(employee_id,
                               FN = first_name,
                               last_name)


dplyr::tbl(con, "employees") %>%
  dplyr::select(employee_id,
                FN = first_name,
                last_name) %>% 
  show_query()


dplyr::tbl(con, "employees") %>%
  dplyr::select(employee_id,
                first_name,
                last_name)



# Execute the SQL query and retrieve the results
query <- "SELECT employee_id, first_name, last_name
FROM employees"
result <- DBI::dbGetQuery(con, query)

########################################################################

# WHERE clause + AND & OR
?filter
# Select only the employees who make more than 50k
emp_salary_above_50k <- dplyr::tbl(con, "employees") %>%
  dplyr::filter(salary > 50000) %>% collect()

DBI::dbReadTable(con, "employees") %>%
  dplyr::filter(salary > 50000)

# show SQL 
dplyr::tbl(con, "employees") %>%
  filter(salary > 50000) %>% 
  show_query()


# Select only the employees who work in Common Grounds coffeshop
dplyr::tbl(con, "employees") %>%
  filter(coffeeshop_id == 1) %>% as_tibble() %>% View()

dplyr::tbl(con, "employees") %>%
  filter(coffeeshop_id == 1) %>% 
  show_query()


# Select all the employees who work in Common Grounds, make more than 50k and are male
dplyr::tbl(con, "employees") %>%
  filter(salary> 50000 & coffeeshop_id == 1 & gender == 'M') %>% as_tibble() %>% View()


dplyr::tbl(con, "employees") %>%
  filter(salary> 50000 & coffeeshop_id == 1 & gender == 'M') %>% 
  show_query()



# Select all the employees who work in Common Grounds or make more than 50k or are male
dplyr::tbl(con, "employees") %>%
  filter(salary> 50000 | coffeeshop_id == 1 | gender == 'M') 


dplyr::tbl(con, "employees") %>%
  filter(salary> 50000 | coffeeshop_id == 1 | gender == 'M') %>% 
  show_query()


# IN, NOT IN, IS NULL, BETWEEN

# Select all rows from the suppliers table where the supplier is NOT Beans and Barley

dplyr::tbl(con, "suppliers") %>% 
  filter(!(supplier_name == 'Beans and Barley'))

dplyr::tbl(con, "suppliers") %>% 
  filter(!(supplier_name == 'Beans and Barley')) %>% 
  show_query()

# Select all Robusta and Arabica coffee types
dplyr::tbl(con, "suppliers") %>% 
  filter(coffee_type %in% c('Robusta', 'Arabica'))

dplyr::tbl(con, "suppliers") %>% 
  filter(coffee_type %in% c('Robusta', 'Arabica')) %>% 
  show_query()

dplyr::tbl(con, "suppliers") %>% 
  filter(coffee_type == 'Robusta' | coffee_type == 'Arabica') %>% 
  show_query()



# Select all coffee types that are not Robusta or Arabica

dplyr::tbl(con, "suppliers") %>% 
  filter(!coffee_type %in% c('Robusta', 'Arabica'))

dplyr::tbl(con, "suppliers") %>% 
  filter(!coffee_type %in% c('Robusta', 'Arabica')) %>% 
  show_query()


# Select all employees with missing email addresses
dplyr::tbl(con, "employees") %>% 
  filter(is.na(email))

dplyr::tbl(con, "employees") %>% 
  filter(is.na(email)) %>% 
  show_query()


# Select all employees whose emails are not missing
dplyr::tbl(con, "employees") %>% 
  filter(!is.na(email))

dplyr::tbl(con, "employees") %>% 
  filter(!is.na(email)) %>% 
  show_query()

# Select all employees who make between 35k and 50k
dplyr::tbl(con, "employees") %>% 
  filter(between(salary , 35000, 50000)) %>% 
  select(employee_id,first_name,last_name,salary)

dplyr::tbl(con, "employees") %>% 
  filter(between(salary , 35000, 50000)) %>% 
  select(employee_id,first_name,last_name,salary) %>% 
  show_query()


dplyr::tbl(con, "employees") %>% 
  filter(salary>=35000 & salary <= 50000) %>% 
  select(employee_id,first_name,last_name,salary) %>% 
  show_query()



# ===========================================================

# ORDER BY, LIMIT, DISTINCT, Renaming columns

# Order by salary ascending 
dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(salary)


dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(salary) %>% 
  show_query()


dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(desc(salary))

dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(desc(salary)) %>% 
  show_query()

# Order by salary descending 
dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(desc(salary))

dplyr::tbl(con, "employees") %>%
  select(employee_id,
         first_name,
         last_name,
         salary) %>% arrange(desc(salary)) %>% 
  show_query()

# Top 10 highest paid employees
dplyr::tbl(con, "employees") %>%
  select(employee_id, first_name, last_name, salary) %>%
  arrange(desc(salary)) %>% 
  head(10)

dplyr::tbl(con, "employees") %>%
  select(employee_id, first_name, last_name, salary) %>%
  arrange(desc(salary)) %>% 
  head(10) %>% show_query()


# Return all unique coffeeshop ids
dplyr::tbl(con, "employees") %>% 
  distinct(coffeeshop_id)


# Renaming columns
dplyr::tbl(con, "employees") %>% 
  select(
    email,
    email_address = email,
    hire_date,
    date_joined = hire_date,
    salary,
    pay = salary
  )

dplyr::tbl(con, "employees") %>% 
  select(
    email,
    email_address = email,
    hire_date,
    date_joined = hire_date,
    salary,
    pay = salary
  ) %>% show_query()



# =========================================================
dplyr::tbl(con, "employees") %>% 
  filter(salary<20000) %>% 
  mutate(sal_25pct = salary+salary*0.25) %>% as_tibble() %>% View()


# EXTRACT
dplyr::tbl(con, "employees") %>% 
  mutate(
    date = hire_date,
    year = year(hire_date),
    month = month(hire_date),
    day = day(hire_date)
  )  %>% 
  select(employee_id, coffeeshop_id, date, year, month, day) %>% 
  filter(year == 2015)


#=========================================================

# UPPER, LOWER, LENGTH, TRIM

# Uppercase first and last names
dplyr::tbl(con,"employees") %>% 
  mutate(first_name_upper = str_to_lower(first_name),
         last_name_upper = str_to_upper(last_name)) %>% 
  select(
    first_name,
    first_name_upper,
    last_name,
    last_name_upper
  ) %>% show_query()




# Lowercase first and last names
dplyr::tbl(con,"employees") %>% 
  mutate(first_name_upper = str_to_lower(first_name),
         last_name_upper = str_to_lower(last_name)) %>% 
  select(
    first_name,
    first_name_upper,
    last_name,
    last_name_upper
  ) %>% show_query()

# Return the email and the length of emails
dplyr::tbl(con, "employees") %>% 
  mutate(email_length = str_length(email)) %>% 
  select(email, email_length) %>% show_query()


# =========================================================

# Concatenation, Boolean expressions, wildcards

# Concatenate first and last names to create full names
dplyr::tbl(con, "employees") %>%
  select(first_name, last_name) %>% 
  mutate(full_name = paste(first_name, last_name, sep = ' ')) %>% 
  show_query()

# Concatenate columns to create a sentence
dplyr::tbl(con, "employees") %>% 
  mutate(full_name_salary = paste(first_name, last_name, "makes", salary)) %>% 
  select(full_name_salary) %>% 
  show_query()


# Boolean expressios
# if the person makes less than 50k, then true, otherwise false
dplyr::tbl(con, "employees") %>% 
  mutate(
    full_name = paste(first_name, last_name, sep = ' '),
    less_than_50k = salary < 50000
  ) %>%
  select(full_name, less_than_50k)

