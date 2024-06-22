# Load necessary libraries
library(DBI)
library(duckdb)
library(dplyr)
library(ggplot2)
library(tidyr)
library(lubridate)
library(forcats)

# Connect to the DuckDB database
con <- DBI::dbConnect(duckdb::duckdb(), dbdir = "coffee_db")

# Read data from the tables
locations <- dbReadTable(con, "locations")
shops <- dbReadTable(con, "shops")
employees <- dbReadTable(con, "employees")
suppliers <- dbReadTable(con, "suppliers")

# Exploratory Data Analysis (EDA)
# Summary statistics
?summary


summary(locations)
summary(shops)
summary(employees)
summary(suppliers)

# Check for missing values
sapply(locations, function(x) sum(is.na(x)))
sapply(shops, function(x) sum(is.na(x)))
sapply(employees, function(x) sum(is.na(x)))
sapply(suppliers, function(x) sum(is.na(x)))

# Unique values in each table
lapply(locations, unique)
lapply(shops, unique)
lapply(employees, unique)
lapply(suppliers, unique)

# Number of employees per shop
emp_per_shop <- employees %>%
  dplyr::group_by(coffeeshop_id) %>%
  dplyr::summarise(num_employees = n())

glimpse(emp_per_shop)

ggplot2::ggplot(data = emp_per_shop,
                mapping = aes(x = forcats::fct_reorder(as.character(coffeeshop_id), num_employees,.desc = TRUE),
                              y = num_employees))+
  geom_bar(stat = "identity", fill = "steelblue")+
  labs(title = "Number of Employees per Coffee Shop",
       x = "Coffee Shop ID",
       y = "Number of Employees") +
  theme_minimal()

# Visualizations
# Number of employees per shop
ggplot(emp_per_shop, aes(x = fct_reorder(as.character(coffeeshop_id), num_employees,.desc = TRUE), 
                         y = num_employees)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Number of Employees per Coffee Shop",
       x = "Coffee Shop ID",
       y = "Number of Employees") +
  theme_minimal()

# Number of shops per city
shops_per_city <- shops %>%
  dplyr::left_join(locations, by = "city_id") %>%
  dplyr::group_by(city) %>%
  dplyr::summarise(num_shops = n())

ggplot(shops_per_city, aes(x = fct_reorder(city, num_shops), y = num_shops)) +
  geom_bar(stat = "identity", fill = "coral") +
  labs(title = "Number of Coffee Shops per City",
       x = "City",
       y = "Number of Shops") +
  theme_minimal() +
  coord_flip()

# Distribution of salaries
ggplot(employees, aes(x = salary)) +
  geom_histogram(binwidth = 5000, fill = "darkgreen", color = "black") +
  labs(title = "Distribution of Salaries",
       x = "Salary",
       y = "Frequency") +
  theme_minimal()

# Gender distribution
gender_dist <- employees %>%
  group_by(gender) %>%
  summarise(count = n())

ggplot(gender_dist, aes(x = gender, y = count, fill = gender)) +
  geom_bar(stat = "identity") +
  labs(title = "Gender Distribution of Employees",
       x = "Gender",
       y = "Count") +
  theme_minimal()

# Number of suppliers per shop
suppliers_per_shop <- suppliers %>%
  group_by(coffeeshop_id) %>%
  summarise(num_suppliers = n())

ggplot(suppliers_per_shop, aes(x = fct_reorder(as.character(coffeeshop_id), num_suppliers, .desc = TRUE), y = num_suppliers)) +
  geom_bar(stat = "identity", fill = "purple") +
  labs(title = "Number of Suppliers per Coffee Shop",
       x = "Coffee Shop ID",
       y = "Number of Suppliers") +
  theme_minimal()

# Close the database connection
dbDisconnect(con)

