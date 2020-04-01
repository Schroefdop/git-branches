# git-branches

Are you tired of copy pasting long branch names to just check it out? Me too! That's why I made this oh-my-zsh plugin. This plugin lists all the local/remote branches you have prepended with a number and you just have to type the corresponding number to switch to the branch! 🕺🏻

![](http://www.giphy.com/gifs/J4yVzLSG0hVbDaUyEB)

## How to install
### Prerequisites
1. zsh
2. oh-my-zsh

### Installation
Open terminal and paste the following lines. This will clone the repository to the right location, add `git-branches` to the plugins located in ~/.zshrc and restart your shell.

```
git clone https://github.com/Schroefdop/git-branches.git ~/.oh-my-zsh/custom/plugins/git-branches
while read line; do; if [[ $line == plugins* ]]; then; sed -i -e 's/plugins=(/plugins=(git-branches /g' ~/.zshrc; fi;  done < ~/.zshrc
exec zsh
```

## How to use

After you installed the plugin and restarted your shell there are three commands you can use:
1. `gco` (`git checkout`) - This will list all your local branches and an option to switch using a number
2. `gcor` (`git checkout -r`) - This will list all your remote branches and an option to switch using a number
3. `gbd` (`git branch -d`) - This will list all your local branches and the option to delete a branch. Confirmation is asked before deletion.

If you know the branchname and you are not too lazy to type, you can also append the banchname to the `gco` command. Like `gco master` and you will switch to local master branch.
