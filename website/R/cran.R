
issues_summary <- function() {
  x <- tools:::CRAN_check_details()
  x <- subset(x, Status != "OK")
  options(width = 234)
  with(x, table(substring(Check, 1, 42), as.numeric(factor(Flavor))))
}

issues_flavors_summary <- function(exclude = c("OK", "NOTE")) {
  x <- tools:::CRAN_check_details()
  x <- subset(x, ! Status %in% exclude)
  tab <- as.data.frame(table(x$Flavor))
  names(tab) <- c("flavor", "count")
  tab
}

additional_issues_summary <- function() {
  x <- readRDS(gzcon(url(
    "https://cran.r-project.org/web/checks/check_issues.rds"
  )))
  tab <- as.data.frame(table(x$kind))
  names(tab) <- c("kind", "count")
  tab
}
