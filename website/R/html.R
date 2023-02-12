
format_manifest <- function() {
  cat(r"(
```
this is is verbatim
```
  )")
}

format_tag <- function(tag) {
  ""
}

format_container <- function(id) {
  ""
}

format_id <- function(id) {
  id <- sub("^ghcr.io/r-hub/containers/[-.a-zA-Z0-9]+@sha256:", "", id)
  substr(id, 1, 7)
}

format_tag <- function(tag) {
  tag <- sub("ghcr.io/r-hub/containers/", "", tag, fixed = TRUE)
  tag <- sub(":latest", "", tag, fixed = TRUE)
  tag
}
