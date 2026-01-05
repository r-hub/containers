#! /usr/bin/env bash

set -e

MAKEVARS=`mktemp`
cat >$MAKEVARS <<EOF
CPICFLAGS=-fPIC
CFLAGS=-Wall -g -O0 -fPIC
CXXFLAGS=-Wall -g -O0 -fPIC -I/usr/include/libcxxabi
LLVM_COMPILER=clang
LD=clang++ -stdlib=libc++
EOF

/opt/R/devel-rchk/bin/R CMD config --all |
    grep 'CXX[0-9]*\s*=' |
    sed 's/clang/wllvm/g' >> "$MAKEVARS"

/opt/R/devel-rchk/bin/R CMD config --all |
    grep 'CC[0-9]*\s*=' |
    sed 's/clang/wllvm/g' >> "$MAKEVARS"

export R_MAKEVARS_USER="$MAKEVARS"
export WLLVM=/opt/R/devel-rchk/python/bin
export RCHK=/opt/R/devel-rchk/rchk
export LLVM=/usr/lib/llvm-14
export WLLVM_BC_STORE=/opt/R/devel-rchk/bcstore
export LLVM_COMPILER=clang

export PATH=$WLLVM:/opt/R/devel-rchk/bin:$PATH

if [ ! -f DESCRIPTION ]; then
    >&2 echo "No DESCRIPTION file. Need to run this script from an R package"
    exit 2
fi

PACKAGE=`cat DESCRIPTION | grep "^Package:" | cut -d: -f2 | tr -d '[:blank:]'`

if [ -z "$PACKAGE" ]; then
    >&2 echo "Could not get package name from DESCRIPTION"
    exit 2
fi

echo Installing package
mkdir -p /opt/R/devel-rchk/packages/lib
_R_INSTALL_LIBS_ONLY_FORCE_DEPENDS_IMPORTS_=FALSE R CMD INSTALL \
    --libs-only --no-test-load -l /opt/R/devel-rchk/packages/lib .

(
    # the rest needs to run here
    cd /opt/R/devel-rchk

    # some config
    . $RCHK/scripts/cmpconfig.inc

    # check that package (lib) is installed
    PKGDIR=$R_LIBS
    PKGARG=$PACKAGE
    if [ "X$PKGARG" != X ] ; then
	PKGDIR=${R_LIBSONLY}/$PKGARG
	if [ ! -d $PKGDIR ] ; then
	    PKGDIR=$R_LIBS/$PKGARG
	    if [ ! -d $PKGDIR ] ; then
		echo "Cannot find package $PKGARG ($PKGDIR does not exist)." >&2
		exit 2
	    fi
	fi
    fi

    # TOOLS="bcheck maacheck fficheck"
    TOOLS=bcheck

    # R bitcode file
    RBC=./R.bc

    # extract package bitcode if needed

    find $PKGDIR -name "*.so" | while read SOF ; do
	if [ ! -r $SOF.bc ] || [ $SOF.bc -nt $SOF ] ; then
	    $WLLVM/extract-bc $SOF
	fi
    done

    # run the tools

    for T in $TOOLS ; do
	find $PKGDIR -name "*.bc" | grep -v '\.o\.bc' | while read F ; do
	    FOUT=`echo $F | sed -e 's/\.bc$/.'$T'/g'`
	    if [ ! -r $FOUT ] || [ $F -nt $FOUT ] || [ $RBC -nt $FOUT ] ; then
		echo Running $T
		$RCHK/src/$T $RBC $F >$FOUT 2>&1
		echo "==== rchk $T ========================================="
		cat $FOUT
		echo "------------------------------------------------------"
	    fi
	done
    done
    
)
