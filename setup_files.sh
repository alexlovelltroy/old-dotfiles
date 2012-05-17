#!/bin/bash
CWD=`pwd`
echo "We're in $CWD"
echo "updating subrepos"
git submodule update --init
for each in `ls`; do
    if [ -d $each ]; then
        pushd $each
        git submodule update --init
        popd
    fi
done

# Handle all the dotfiles
for each in `ls -a`; do
    # this actully evaluates to false when it is true
    if [ ! $each = $0 ]; then
        if [ -f $each ]; then
            # We're dealing with a file
            # diff returns true for files that are the same
            if diff $each ~/$each; then
                echo "$each is unchanged"
            elif [ -f ~/$each ]; then
                vimdiff ~/$each $each
            else
                echo "linking $each"
                ln -s $CWD/$each ~/$each
            fi
        fi
    fi
done

