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

_ACTION_MERGE="merge"
_ACTION_CHECKOUT="checkout"
_ACTION_DELETE="deletion"
_ACTION_REMOTE_CHECKOUT="remote checkout"

# git merge
gm() {
    _showListOrHandleUserInputForAction $_ACTION_MERGE $1
}

# git checkout
gco() {
    _showListOrHandleUserInputForAction $_ACTION_CHECKOUT $1
}

# git branch -d
gbd() {
    _showListOrHandleUserInputForAction $_ACTION_DELETE $1
}

# git checkout -t
gcor() {
    _showListOrHandleUserInputForAction $_ACTION_REMOTE_CHECKOUT $1
}

_showListOrHandleUserInputForAction() {
    _ACTION=$1
    _USER_INPUT=$2

    if [ -z "$_USER_INPUT" ]; then
        _presentBranchList $_ACTION
    elif; then
        _handleActionWithUserInput $_ACTION $_USER_INPUT
    fi
}

_presentBranchList() {
    _ACTION=$1

    _addBranchesToFileForAction $_ACTION

    currentBranch=$(git branch | grep \* | cut -d ' ' -f2)
    echo "Current branch:\n$fg[green]$currentBranch$reset_color"
    _removeCurrentBranchFromList

    echo "Branches available for $_ACTION:"
    _listBranchesFromFile $branchesFile

    _validateInput 'Branch number: '
    branch=$(head -$_INPUT $branchesFile | tail -1 | awk '{$1=$1};1')

    _handleActionWithBranch $_ACTION $branch
}

_addBranchesToFileForAction() {
    _ACTION=$1

    case $_ACTION in
    "remote checkout") git branch -r >$branchesFile ;; # Get remote branches
    *) git branch >$branchesFile ;;                    # Get local branches
    esac
}

_handleActionWithKeyword() {
    _ACTION=$1
    _KEYWORD=$2

    grepBranches=$TMPDIR'grepBranches'
    trap "{ rm -f $grepBranches; }" EXIT

    _addBranchesToFileForAction $_ACTION
    _removeCurrentBranchFromList

    hitCount=$(grep -i -c $_KEYWORD $branchesFile)
    grep -i $_KEYWORD $branchesFile >$grepBranches

    case $hitCount in
    # If 0 results, return
    0) return ;;

    # If 1 result, give option to switch
    1)
        line=($(grep -i "$_KEYWORD" $grepBranches))

        if read -q "choice?Did you mean $fg[green]$line$reset_color? [y/n] "; then
            echo
            _handleActionWithBranch $_ACTION "$line"
        fi
    ;;

    # If multiple results, let the user choose
    *)
        echo "Found branches with keyword '$_KEYWORD'"
        _listBranchesFromFile $grepBranches
        _validateInput 'Branch number: '
        branch=$(awk -v "line=$_INPUT" 'NR==line' $grepBranches | awk '{$1=$1};1')
        _handleActionWithBranch $_ACTION $branch
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
    FILE=$1

    n=1
    while read line; do
        if [[ $line != *"*"* ]]; then
            echo "$n. $fg[red]$line$reset_color"
            n=$((n + 1))
        fi
    done <$FILE
}

_validateInput() {
    while true; do
        
        # Read user input
        printf $1
        read tmp

        # If input is not an integer or if input is out of range, throw an error
        # Ask for input again
        if [[ ! $tmp =~ ^[0-9]+$ ]]; then
            echo "$fg[red]Invalid input$reset_color"
        elif [[ "$tmp" -lt "1" ]] || [[ "$tmp" -gt $((n - 1)) ]]; then
            echo "$fg[red]Input out of range $reset_color"
        else
            _INPUT=$tmp
            break
        fi
    done
}

_handleActionWithUserInput() {
    _ACTION=$1
    _USER_INPUT=$2

    case $_ACTION in
    $_ACTION_MERGE)
        if ! git merge --no-ff $_USER_INPUT; then
            _handleActionWithKeyword $_ACTION $_USER_INPUT
        fi
        ;;
    $_ACTION_REMOTE_CHECKOUT)
        if ! git checkout -t $_USER_INPUT; then
            _handleActionWithKeyword $_ACTION $_USER_INPUT
        fi
        ;;
    $_ACTION_CHECKOUT)
        if ! git checkout $_USER_INPUT; then
            _handleActionWithKeyword $_ACTION $_USER_INPUT
        fi
        ;;
    $_ACTION_DELETE)
        if ! git branch -D $_USER_INPUT; then
            _handleActionWithKeyword $_ACTION $_USER_INPUT
        fi
        ;;
    esac
}

_handleActionWithBranch() {
    _ACTION=$1
    _BRANCH=$2

    # Trim leading '+' if branch is in another worktree
    _BRANCH="${_BRANCH##+([[:space:]]|+)}"

    case $_ACTION in
    $_ACTION_MERGE) git merge --no-ff $_BRANCH ;;
    $_ACTION_REMOTE_CHECKOUT) git checkout -t $_BRANCH ;;
    $_ACTION_CHECKOUT) _handleCheckout $_BRANCH ;;
    $_ACTION_DELETE)
        if read -q "choice?$fg[red]Are you sure you want to delete branch $reset_color$_BRANCH$fg[red]? [y/n]$reset_color "; then
            echo
            git branch -D $_BRANCH
        fi
    esac
}

_handleCheckout() { 
    _BRANCH=$1

    local worktree_path
    worktree_path=$(git worktree list --porcelain | awk -v b="refs/heads/${_BRANCH}" '
        $1 == "worktree" { path=$2 }
        $1 == "branch" && $2 == b { print path }
    ')

    if [[ -n "$worktree_path" ]]; then
        worktree_name=$(basename "$worktree_path")
        echo "Checked out $fg[green]$_BRANCH$reset_color at worktree: $fg[green]$worktree_name$reset_color"
        cd "$worktree_path" || return 1
    else
        git checkout "$_BRANCH"
    fi
}
