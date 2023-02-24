
install_deps <- function(path) {

  deps <- pak::pkg_deps(
    paste0("deps::", normalizePath(path)), dependencies = FALSE
  )$deps[[1]]

  lnkto <- deps$ref[deps$type == "LinkingTo"]
  if (length(knkto == 0)) return()

  # Install LinkingTo deps from source
  refs <- paste0(lnkto, "?source")
  pak::pkg_install(refs)

  # Install others, potentitally from binaries
  pak::pkg_install(paste0("deps::", path), dependencies = TRUE)
}

if (is.null(sys.calls()) {
  install_deps(commandArgs(TRUE)[1])
}
