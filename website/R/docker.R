
load_old_manifest <- function() {
  path <- "_site/manifest.json"
  if (file.exists(path)) {
    # if input exists, we copy it to output, in case there is nothing to do
    file.copy(path, "manifest.json")
  } else {
    # otherwise we download it, and copy it to output
    cli::cli_alert_warning("Old manifest file does not exist, downloading it.")
    url <- "https://r-hub.github.io/containers/manifest.json"
    download.file(url, "manifest.json")
    path <- "manifest.json"
  }
  jsonlite::fromJSON(path, simplifyVector = FALSE)
}

load_new_manifest <- function() {
  if (!file.exists("manifest.json")) {
    stop("New manifest file does not exist!")
  }
  jsonlite::fromJSON("manifest.json", simplifyVector = FALSE)
}

list_containers <- function() {
  dir("../containers")
}

pull_containers <- function() {
  conts <- list_containers()
  for (cont in conts) {
    cli::cli_alert_info("Pulling container {cont}")
    processx::run(
      echo = TRUE,
      "docker",
      c("pull",
        sprintf("ghcr.io/r-hub/containers/%s", cont),
        "--platform=linux/amd64"
      )
    )
  }
}

update_manifest <- function() {
  # load known containers
  old <- load_old_manifest()
  old <- unlist(purrr::map(old$containers, "builds"), recursive = FALSE)

  # get data from latest container versions
  if (! tolower(Sys.getenv("UPDATE_MANIFEST", "yes")) %in%
      c("no", "false", "off", "0")) {
    new <- purrr::map(list_containers(), get_container_data)
  } else {
    new <- list()
  }

  # filter out the ones that we have already seen
  oldids <- purrr::map_chr(old, "id")
  newids <- purrr::map_chr(new, "id")
  new <- new[! newids %in% oldids]

  # if nothing new, quit here
  if (length(new) == 0) {
    cli::cli_alert_success("No new containers to add to manifest.")
    return(invisible())
  }

  tags <- unique(c(
    purrr::map_chr(old, "tag"),
    purrr::map_chr(new, "tag")
  ))

  last_containers_for_tag <- function(tag) {
    sels <- c(
      purrr::keep(old, function(x) x$tag == tag),
      purrr::keep(new, function(x) x$tag == tag)
    )
    sels <- sels[order(purrr::map_chr(sels, "created"), decreasing = TRUE)]
    utils::tail(sels, 5)
  }

  conts <- map(
    tags,
    function(tag) list(tag = tag, builds = last_containers_for_tag(tag))
  )
  obj <- list(
    updated = format(Sys.time()),
    containers = conts
  )

  json <- jsonlite::toJSON(obj, pretty = TRUE, auto_unbox = TRUE)
  writeLines(json, "manifest.json")
  cli::cli_alert_success("Container manifest updated.")
}

docker_inspect <- function(name, property) {
  trimws(processx::run(
    "docker",
    c("inspect", "-f", paste0("{{.", property, "}}"), name)
  )$stdout)
}

docker_run <- function(name, cmd, platform = "linux/amd64") {
  processx::run(
    echo_cmd = TRUE,
    "docker",
    c("run", "--rm", paste0("--platform=", platform), name, cmd)
  )$stdout
}

get_container_data <- function(cont) {
  name <- sprintf("ghcr.io/r-hub/containers/%s:latest", cont)

  id <- docker_inspect(name, "Id")
  created <- docker_inspect(name, "Created")
  size <- as.numeric(docker_inspect(name, "Size"))

  os_release <- docker_run(name, c("cat", "/etc/os-release"))
  uname <- trimws(docker_run(name, c("uname", "-a")))
  ospkgs <- docker_run(name, c("bash", "-c", "dpkg -l || rpm -qa"))

  cc <- docker_run(name, c("bash", "-c", "$(R CMD config CC) --version"))
  cxx <- docker_run(name, c("bash", "-c", "$(R CMD config CXX) --version"))
  fc <- docker_run(name, c("bash", "-c", "$(R CMD config FC) --version"))

  si <- docker_run(name, c("R", "-q", "--slave", "-e", "utils::sessionInfo()"))
  extsv <- docker_run(name, c("R", "-q", "--slave", "-e", "extSoftVersion()"))
  caps <- docker_run(name, c("R", "-q", "--slave", "-e", "capabilities()"))
  rconfig <- docker_run(name, c("R", "CMD", "config", "--all"))
  curl <- docker_run(name, c("R", "-q", "--slave", "-e", "libcurlVersion()"))
  lav <- docker_run(name, c("R", "-q", "--slave", "-e", "La_version()"))
  lal <- docker_run(name, c("R", "-q", "--slave", "-e", "La_library()"))
  grs <- docker_run(name, c("R", "-q", "--slave", "-e", "grSoftVersion()"))
  pcre <- docker_run(name, c("R", "-q", "--slave", "-e", "pcre_config()"))
  l10n <- docker_run(name, c("R", "-q", "--slave", "-e", "l10n_info()"))

  list(
    tag = name,
    id = id,
    size = size,
    created = created,

    "/etc/os-release" = os_release,
    "uname -a" = uname,
    "OS packages" = ospkgs,

    "$(CC) --version" = cc,
    "$(CXX) --version" = cxx,
    "$(FC) --version" = fc,

    "sessionInfo()" = si,
    "extSoftVersion()" = extsv,
    "libcurlVersion()" = curl,
    "capabilities()" = caps,
    "R CMD config --all" = rconfig,
    "La_version()" = lav,
    "La_library()" = lal,
    "grSoftVersion()" = grs,
    "pcre_config()" = pcre,
    "l10n_info()" = l10n
  )
}