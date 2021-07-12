#!/usr/bin/env bash

# ----------------------
# Git helper functions
# Merge branches
# Checkout local branches
# Find branches by keyword
# Checkout remote branches
# Delete local branches
# ----------------------
_INPUT=

branchesFile=$TMPDIR'branches'
trap "{ rm -f $branchesFile; }" EXIT

# git merge
gm() {
    _ACTION="merge"

    if [ -z "$1" ]; then
        _retrieveBranches $_ACTION
    elif; then
        if ! git merge --no-ff $1; then
            _checkIfKeywordExists $1 $_ACTION
        fi
    fi
}

# git checkout
gco() {
    _ACTION="checkout"
    
    if [ -z "$1" ]; then
        _retrieveBranches $_ACTION
    elif; then
        if ! git checkout $1; then
            _checkIfKeywordExists $1 $_ACTION
        fi
    fi
}

# git branch -d
gbd() {
    _retrieveBranches "deletion"
}

# git checkout -t
gcor() {
    _retrieveBranches "remote checkout"
}

_retrieveBranches() {
    _ACTION=$1
    
    local NOCOLOR='\033[0m'
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'

    case $_ACTION in
    "remote checkout") git branch -r >$branchesFile ;; # Get remote branches
    *) git branch >$branchesFile ;;                    # Get local branches
    esac

    currentBranch=$(git branch | grep \* | cut -d ' ' -f2)
    echo "Current branch:\n${GREEN}$currentBranch${NOCOLOR}"
    _removeCurrentBranchFromList
    
    echo "Branches available for $_ACTION:"
    _listBranchesFromFile $branchesFile

    _validateInput 'Branch number: '
    branch=$(head -$_INPUT $branchesFile | tail -1 | awk '{$1=$1};1')

    _handleActionForBranch $_ACTION $branch
}

_checkIfKeywordExists() {
    _KEYWORD=$1
    _ACTION=$2

    grepBranches=$TMPDIR'grepBranches'
    trap "{ rm -f $grepBranches; }" EXIT

    git branch >$branchesFile

    _removeCurrentBranchFromList

    hitCount=$(grep -c $_KEYWORD $branchesFile)
    grep $_KEYWORD $branchesFile >$grepBranches

    case $hitCount in
    # If 0 results, return
    0) return ;; 

    # If 1 result, give option to switch
    1) 
        line=($(grep -i "$_KEYWORD" $grepBranches))
        printf "Did you mean ${GREEN}$line${NOCOLOR}? [y/n]${NOCOLOR} "
        read confirm
        case $confirm in
        [Yy]*) _handleActionForBranch $_ACTION $line ;;
            # git checkout $line
            # return
            # ;;
        *) return ;;
        esac
        ;;

    # If multiple results, let the user choose
    *) 
        echo "Found branches with keyword '$_KEYWORD'"
        _listBranchesFromFile $grepBranches
        _validateInput 'Branch number: '
        branch=$(awk -v "line=$_INPUT" 'NR==line' $grepBranches | awk '{$1=$1};1')
        git checkout $branch
        ;;
    esac
}

_removeCurrentBranchFromList() {
    n=1
    while read line; do
        if [[ $line == *"*"* ]]; then
            # Remove the current branch from the file, we cannot checkout current branch
            sed -i "" $n\d $branchesFile
        fi
        n=$((n + 1))
    done <$branchesFile
}

_listBranchesFromFile() {
    n=1
    while read line; do
        if [[ $line != *"*"* ]]; then
            echo "$n. ${RED}$line${NOCOLOR}"
            n=$((n + 1))
        fi
    done <$1
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

_handleActionForBranch() {   
    _ACTION=$1
    _BRANCH=$2

    case $_ACTION in
    "merge") git merge --no-ff $_BRANCH ;;
    "remote checkout") git checkout -t $_BRANCH ;;
    "checkout") git checkout $_BRANCH ;;
    "deletion")
        printf "${RED}Are you sure you want to delete branch ${NOCOLOR}$_BRANCH${RED}? [y/n]${NOCOLOR} "

        read confirm
        case "$confirm" in
        [yY]) git branch -D $_BRANCH ;;
        *) echo "¯\_(ツ)_/¯" ;;
        esac
        ;;
    esac
}