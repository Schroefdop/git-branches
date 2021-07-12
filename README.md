# git-branches

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

After you installed the plugin and restarted your shell there are three commands you can use:

**gco**\
Will list all local available branches for checkout. Choose a number from the list to checkout that branch.
**gco \<branchname>**\
This command will immediately checkout the local branch if it exists, same like `git checkout <branchname>`.
Example: 
```
> gco feature/add_login
> Switched to branch 'feature/add_login'
```
**gco \<keyword>**\
If you have a lot of branches, the list `gco` provides can become pretty long and it can become tedious to search for the right branch. So if you know a keyword, for example it was a branch containing the text `login`, you can just write `gco login` and it will list all available branches which contain the word `login`, or if there's only 1 hit, ask you if you want to checkout that one.
Example: 
```
> gco login
> error: pathspec 'login' did not match any file(s) known to git
> Did you mean feature/add_login? [y/n] y
> Switched to branch 'feature/add_login'
```

- `gcor` (`git checkout -r`) - This will list all your remote branches and an option to switch using a number
- `gbd` (`git branch -d`) - This will list all your local branches and the option to delete a branch. Confirmation is asked before deletion.
- `gm` (`git merge --no-ff`) - This will list all your local branches and an option to switch using a number

If you know the branchname and you are not too lazy to type, you can also append the branchname to the `gco` command. Like `gco master` and you will switch to local master branch. This also applies to the `gm` command.

