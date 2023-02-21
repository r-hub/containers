
format_id <- function(id) {
  id <- sub("^ghcr.io/r-hub/containers/[-.a-zA-Z0-9]+@sha256:", "", id)
  substr(id, 1, 7)
}

format_tag <- function(tag) {
  tag <- sub("ghcr.io/r-hub/containers/", "", tag, fixed = TRUE)
  tag <- sub(":latest", "", tag, fixed = TRUE)
  tag
}

get_cont_data <- function(id) {
  conts <- load_new_manifest()
  tags <- format_tag(purrr::map_chr(conts$containers, "tag"))
  if (!id %in% tags) stop("Unknown container: ", id)
  conts$containers[[which(tags == id)]]$builds[[1]]
}

os_name <- function(id) {
  cont <- get_cont_data(id)
  os_release <- strsplit(cont$`/etc/os-release`, "\n", fixed = TRUE)[[1]]
  pn <- grep("^PRETTY_NAME", os_release, value = TRUE)[1]
  pn <- sub("^PRETTY_NAME=", "", pn)
  pn <- unquote(pn)
  pn
}

r_ver <- function(id) {
  cont <- get_cont_data(id)
  sess <- strsplit(cont$`sessionInfo()`, "\n", fixed = TRUE)[[1]]
  sess[1]
}
