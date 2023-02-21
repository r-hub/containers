
first_char <- function(x) {
  substr(x, 1, 1)
}

last_char <- function(x) {
  substr(x, nchar(x), nchar(x))
}

unquote <- function(x) {
  ifelse(
    first_char(x) == last_char(x) & first_char(x) %in% c("'", '"'),
    substr(x, 2L, nchar(x) - 1L),
    x
  )
}
