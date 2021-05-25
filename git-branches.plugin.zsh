#!/usr/bin/env bash

# ----------------------
# Git helper functions
# Checkout local branches
# Checkout remote branches
# Delete local branches
# ----------------------
_INPUT=

gm() {
    if [ -z "$1" ]; then
        _listBranches "merge"
    elif; then
        git merge --no-ff $1
    fi
}

gco() {
    if [ -z "$1" ]; then
        _listBranches "checkout"
    elif; then
        git checkout $1
    fi
}

gbd() {
    _listBranches "deletion"
}

gcor() {
    _listBranches "remote checkout"
}

_listBranches() {
    local NOCOLOR='\033[0m'
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'

    branchesFile=$TMPDIR'branches'
    trap "{ rm -f $branchesFile; }" EXIT

    case $1 in
    "remote checkout") git branch -r >$branchesFile ;; # Get remote branches
    *) git branch >$branchesFile ;;                    # Get local branches
    esac

    n=1
    while read line; do
        if [[ $line == *"*"* ]]; then
            currentBranch=$(git branch | grep \* | cut -d ' ' -f2)
            echo "Current branch:\n${GREEN}$currentBranch${NOCOLOR}"
            # Remove the current branch from the file, we cannot checkout current branch
            sed -i "" $n\d $branchesFile
        fi
        n=$((n + 1))
    done <$branchesFile

    echo "Branches available for $1:"
    n=1
    while read line; do
        if [[ $line != *"*"* ]]; then
            echo "$n. ${RED}$line${NOCOLOR}"
            n=$((n + 1))
        fi
    done <$branchesFile

    _validateInput 'Branch number: '
    branch=$(head -$_INPUT $branchesFile | tail -1 | awk '{$1=$1};1')

    case $1 in
    "merge")
        git merge --no-ff $branch
    ;;
    "remote checkout")
        git checkout -t $branch
        ;;
    "checkout")
        git checkout $branch
        ;;
    "deletion")
        printf "${RED}Are you sure you want to delete branch ${NOCOLOR}$branch${RED}? [y/n]${NOCOLOR} "

        read confirm
        case "$confirm" in
        [yY]) git branch -D $branch ;;
        *) echo "¯\_(ツ)_/¯" ;;
        esac
        ;;
    esac
}

_validateInput() {
    local NOCOLOR='\033[0m'
    local RED='\033[0;31m'

    while true; do
        #
        # Read user input
        #
        printf $1
        read tmp

        #
        # If input is not an integer or if input is out of range, throw an error
        # Ask for input again
        #
        if [[ ! $tmp =~ ^[0-9]+$ ]]; then
            echo "${RED}Invalid input${NOCOLOR}"
        elif [[ "$tmp" -lt "1" ]] || [[ "$tmp" -gt $((n - 1)) ]]; then
            echo "${RED}Input out of range ${NOCOLOR}"
        else
            _INPUT=$tmp
            break
        fi
    done
}
