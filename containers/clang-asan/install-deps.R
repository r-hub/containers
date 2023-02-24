
install_deps <- function(path) {
  options(pak.no_extra_messages = TRUE)
  deps <- pak::pkg_deps(
    paste0("deps::", normalizePath(path)), dependencies = FALSE
  )$deps[[1]]

  lnkto <- deps$ref[deps$type == "LinkingTo"]
  if (length(lnkto) != 0) {
    message("LinkingTo dependencies: ", paste(lnkto, collapse = ", "), ".")
    repos <- getOption("repos")
    options(repos = repos["CRAN"])
    pak::pkg_install(lnkto)
    options(repos = repos)
  }

  # Install others, potentitally from binaries
  pak::pkg_install(paste0("deps::", path), dependencies = TRUE)
}

if (is.null(sys.calls())) {
  install_deps(commandArgs(TRUE)[1])
}
