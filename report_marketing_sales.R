# Load necessary libraries
library(DBI)
library(duckdb)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(forcats)
library(gt)

# Connect to the DuckDB database
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "coffee_db")

# Read data from the tables
locations <- dbReadTable(con, "locations")
shops <- dbReadTable(con, "shops")
employees <- dbReadTable(con, "employees")
suppliers <- dbReadTable(con, "suppliers")

# Enhanced Analysis
# 1. Sales Performance by Region (using salaries as a proxy for sales)

sales_performance <- employees %>%
  left_join(shops, by = "coffeeshop_id") %>%
  left_join(locations, by = "city_id") %>%
  group_by(country, city) %>%
  summarise(total_salary = sum(salary), avg_salary = mean(salary), num_employees = n()) %>%
  arrange(desc(total_salary))

# 2. Employee Salary Trends Over Time
employees <- employees %>%
  mutate(hire_year = year(as.Date(hire_date)))

salary_trends <- employees %>%
  group_by(hire_year) %>%
  summarise(avg_salary = mean(salary), num_employees = n())

# 3. Supplier Contributions to Coffee Shops
supplier_contributions <- suppliers %>%
  left_join(shops, by = "coffeeshop_id") %>%
  left_join(locations, by = "city_id") %>%
  group_by(supplier_name, city) %>%
  summarise(num_shops = n(), .groups = 'drop')

# Visualizations

# 1. Sales Performance by Region
sales_performance_plot <- ggplot(sales_performance, 
                                 aes(x = fct_reorder(city, total_salary,
                                                     ), 
                                     y = total_salary, 
                                     fill = country)) +
  geom_bar(stat = "identity") +
  labs(title = "Sales Performance by City (Total Salary as Proxy)",
       x = "City",
       y = "Total Salary") +
  theme_minimal() +
  coord_flip()


# 2. Employee Salary Trends Over Time
salary_trends_plot <- ggplot(salary_trends, aes(x = hire_year)) +
  geom_line(aes(y = avg_salary), color = "blue") +
  geom_point(aes(y = avg_salary), color = "blue") +
  labs(title = "Employee Salary Trends Over Time",
       x = "Year",
       y = "Average Salary") +
  theme_minimal()

# 3. Supplier Contributions to Coffee Shops
# 
supplier_contributions_plot <- ggplot(supplier_contributions, 
                                      aes(x = fct_reorder(supplier_name, 
                                                      num_shops), 
                                          y = num_shops, 
                                          fill = city)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Supplier Contributions to Coffee Shops",
       x = "Supplier Name",
       y = "Number of Coffee Shops") +
  scale_colour_manual(values = c("red", "yellow", "green"))+
  theme_minimal() +
  coord_flip()

# Close the database connection
dbDisconnect(con)







# Create a Quarto Markdown Report
report_content <- "
---
title: 'Marketing and Sales Report'
author: 'Data Analysis Team'
date: '`r Sys.Date()`'
format: html
---

# Sales Performance by Region

```{r}
gt::gt(sales_performance) %>%
  gt::tab_header(
    title = 'Sales Performance by Region'
  )
print(sales_performance_plot)

gt::gt(salary_trends) %>%
  gt::tab_header(
    title = 'Employee Salary Trends Over Time'
  )

print(salary_trends_plot)

gt::gt(supplier_contributions) %>%
  gt::tab_header(
    title = 'Supplier Contributions to Coffee Shops'
  )
print(supplier_contributions_plot)
"
