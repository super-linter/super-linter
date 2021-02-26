# Each of the default linters should throw at least one lint on this file

# assignment
# function_left_parentheses
# closed_curly
# commas
# paren_brace
f = function (x,y = 1){}

# commented_code
# some <- commented("out code")

# cyclocomp
# equals_na
# infix_spaces
# line_length
# object_length
# object_name
# object_usage
# open_curly
someComplicatedFunctionWithALongCameCaseName <- function(x)
{
  y <- 1
  if (1 > 2 && 2 > 3 && 3 > 4 && 4 > 5 && 5*10 > 6 && x == NA) {TRUE} else {FALSE}
}

# pipe_continuation
# seq_linter
# spaces_inside
x <- 1:10
x[ 2]
1:length(x) %>% lapply(function(x) x*2) %>%
  head()

# single_quotes
message('single_quotes')

# spaces_left_parentheses
# trailing_whitespace
y <- 2 +(1:10)

# unexpected end of input
{

# trailing_blank_lines

