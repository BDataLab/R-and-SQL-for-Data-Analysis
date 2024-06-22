## A step further into R programming syntax
# variables

x <- 10
y <- 20

x+y
# using variables in arithmetric operations
z <- x + y   # Addition
z

# boolean operator 
# checking for equality
x == y
is_equal <- x == y   # Equality check
is_equal

is_greater <- x > y  # Greater than
is_greater


# combine variables and operators to produce a result:

result <- (x + y) * 2

x <- 15

# basic R functions
total <- sum(x, y, z)

total

# R packages extend the functionality of R. 
# - install and load packages using:
# install.packages("dplyr")
# install.packages('ggplot2')
# install.packages(c("tidyr", "stringr"))

library(dplyr)

dplyr::select()

library(ggplot2)


