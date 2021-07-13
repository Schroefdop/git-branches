# git-branches

- [git-branches](#git-branches)
  - [How to install](#how-to-install)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)
  - [How to use](#how-to-use)
    - [Features](#features)

Are you tired of copy pasting long branch names to just check it out? Me too! That's why I made this `oh-my-zsh` plugin. This plugin lists all the local/remote branches you have prepended with a number and you just have to type the corresponding number to switch to the branch! 🕺🏻

![](https://media.giphy.com/media/jVT7YO7XwLfhCkMWxt/giphy.gif)

## How to install
### Prerequisites
1. zsh
2. oh-my-zsh

### Installation
Open terminal and paste the following lines. This will clone the repository to the right location, add `git-branches` to the plugins located in ~/.zshrc and restart your shell.

```
git clone https://github.com/Schroefdop/git-branches.git $ZSH_CUSTOM/plugins/git-branches
while read line; do; if [[ $line == plugins* ]]; then; sed -i -e 's/plugins=(/plugins=(git-branches /g' ~/.zshrc; fi;  done < ~/.zshrc
exec zsh
```

## How to use

After you installed the plugin and restarted your shell there are four main commands you can use.

- `gco` (`git checkout`) - This will list all local branches with an option to switch using a number
- `gcor` (`git checkout -r`) - This will list all your remote branches and an option to switch using a number
- `gbd` (`git branch -d`) - This will list all your local branches and the option to delete a branch. Confirmation is asked before deletion.
- `gm` (`git merge --no-ff`) - This will list all your local branches and an option to switch using a number

### Features

**gco**\
Will list all local available branches for checkout. Choose a number from the list to checkout that branch.

**gco \<branchname>**\
This command will immediately checkout the local branch if it exists, same like `git checkout <branchname>`.
Example: 
```
> gco feature/add_login
> Switched to branch 'feature/add_login'
```

Note: When using `gbp` (`git branch -D`) with an exact branchname, it will be deleted without prompt, as is git standard behavior.

**gco \<keyword>**\
If you have a lot of branches, the list a command provides can become pretty long and it can become tedious to search for the right branch. So if you know a keyword, for example it was a branch containing the text `login`, you can just write `gco login` and it will list all available branches which contain the word `login`, or if there's only 1 hit, ask you if you want to checkout that one.

Single hit example: 
```
> gco login
> error: pathspec 'login' did not match any file(s) known to git
> Did you mean feature/add_login? [y/n] y
> Switched to branch 'feature/add_login'
```

Multiple hits example:
```
> gco login
> error: pathspec 'login' did not match any file(s) known to git
> Found branches with keyword 'login'
> 1. feature/login_businesslogic
> 2. feature/login_ui
> Branch number: 1
> Switched to branch 'feature/login_businesslogic'
```

This also works with the the other commands `gcor`, `gbd` and `gm`