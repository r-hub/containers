
pkgload::load_all()
if (! tolower(Sys.getenv("UPDATE_MANIFEST", "yes")) %in%
    c("no", "false", "off", "0")) {
  pull_containers()
}

# we always need to create a manifest file
update_manifest()
