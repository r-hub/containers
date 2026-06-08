#! /usr/bin/env bash
set -e

if [ ! -f DESCRIPTION ]; then
    >&2 echo "No DESCRIPTION file. Need to run this script from an R package"
    exit 2
fi

PACKAGE=`cat DESCRIPTION | grep "^Package:" | cut -d: -f2 | tr -d '[:blank:]'`

if [ -z "$PACKAGE" ]; then
    >&2 echo "Could not get package name from DESCRIPTION"
    exit 2
fi

# https://www.r-project.org/nosvn/vnu/README.txt

Rscript -e "tools::pkg2HTML('$PACKAGE', out = 'pkg.html', concordance = TRUE)"
Rscript - <<'END'
    bad <- W3CMarkupValidator::w3c_markup_validate(
        file = 'pkg.html',
        jar = TRUE,
        concordance = TRUE
    )
    class(bad) <- c("w3c_markup_validate", class(bad))
    print(bad)
    if (nrow(bad) > 0) {
        write.dcf(bad)
        stop("Validation failed")
    }
END
