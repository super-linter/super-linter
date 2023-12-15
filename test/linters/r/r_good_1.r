# Each of the default linters should throw at least one lint on this file

# assignment
# function_left_parentheses
# closed_curly
# commas
# paren_brace
f <- function(x, y = 1) {

}

# commented_code

# cyclocomp
# equals_na
# infix_spaces
# line_length
# object_length
# object_name
# object_usage
# open_curly
short_snake <- function(x) {
  y <- 1
  y <- y^2
  if (1 > 2 && 5 * 10 > 6 && is.na(x)) {
    TRUE
  } else {
    FALSE
  }
}

# pipe_continuation
# seq_linter
# spaces_inside
x <- 1:10
x[2]
seq_len(x) %>%
  lapply(function(x) x * 2) %>%
  head()

# single_quotes
message("single_quotes")

# spaces_left_parentheses
# trailing_whitespace
y <- 2 + (1:10)

# trailing_blank_lines
