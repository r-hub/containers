
first_char <- function(x) {
  substr(x, 1, 1)
}

last_char <- function(x) {
  substr(x, nchar(x), nchar(x))
}
