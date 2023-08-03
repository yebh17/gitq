# gitq

Introducing gitq: Simplifying Your Git Workflow with Interactive Prompts and Guidance!

gitq is an innovative git wrapper tool designed to streamline your experience with Git commands. Say goodbye to the complexities of remembering various git commands and their syntax – with gitq, you'll receive interactive prompts right in your terminal, guiding you through each step of your workflow.

Navigating through different scenarios becomes a breeze, as gitq provides real-time feedback and suggests the most suitable commands based on your specific requirements. Whether you're committing changes, branching, merging, or handling complex version control tasks, gitq has got you covered.

Embrace the power of a more intuitive and user-friendly Git experience. Try gitq now and witness how effortlessly you can interact with Git, making version control a seamless and enjoyable process for developers of all levels.

## Steps (LINUX)

Clone this repo wherever you prefer, for simplifying things I use home folder in this case.
-   `cd ~`

If you wanted to clone via ssh then run the following. 
-   `git clone git@github.com:yebh17/gitq.git` 

If you wanted to clone via https then run the following. 
-   `git clone https://github.com/yebh17/bash_aliases.git` 

We need to make the script permanently available in the PATH, so that gitq is accessible from any path.
-   `mkdir -p ~/bin`

Copy the gitq script to the bin folder you just created.
-   `cp gitq/gitq.sh ~/bin/gitq`

Add this "bin" directory to the PATH.
-   `nano ~/.bashrc`

Add the following line at the end of the file and then save and close the file.
-   `export PATH="$HOME/bin:$PATH"`

###### Note: If you are using a different shell (e.g., Zsh), use the appropriate configuration file (e.g., ~/.zshrc) instead.

Ensure the script has executable permissions.
-   `chmod +x ~/bin/gitq`

To apply the changes immediately, either close and reopen your terminal or run the following in the same terminal.
-   `source ~/.bashrc`
###### Note: If you made changes to a different shell configuration file, replace "~/.bashrc" with the appropriate file path.

Now, you should be able to run the gitq tool from any location and it works exactly the same as git but with additional features.
For example, the below command shows an explanation on what the "git log" shows,
```
# gitq log -e

Commit ID: This is a unique identifier for a particular commit. It is a long string of alphanumeric characters, typically shown as a SHA-1 hash. The commit ID uniquely identifies each commit in the Git history.

HEAD -> master: This indicates the current branch you are on (HEAD) and the branch it points to (master). In Git, HEAD represents the current commit or branch that you have checked out. In this case, it means you are on the master branch.

origin/master: This refers to the 'master' branch on the remote repository, typically named 'origin.' When you clone a repository, 'origin' is the default name given to the remote repository from which you cloned.

origin/HEAD: This refers to the default branch on the remote repository. It points to the same branch as origin/master, which is typically the default branch of the remote repository.

Author: The author of the commit. It includes the name and email address of the person who made the changes. The author is the person who initially created the changes.

Date: The date and time when the commit was made. It shows the timestamp of when the changes were committed.

Commit Message: This is the descriptive message provided by the author when they committed the changes. The commit message explains the purpose of the commit, the changes made, and any other relevant information about the commit.
## master...origin/master
```

Similarly, the below command shows a warning if your baseline is diverged from origin/master unintentionally, and also provides the command to bring back your repository to up to date.
```
# gitq status

HEAD detached at 094b799
Changes not staged for commit:
(use "git add <file>..." to update what will be committed)
(use "git restore <file>..." to discard changes in working directory)
        modified:   gitq.sh

no changes added to commit (use "git add" and/or "git commit -a")

WARNING!!
You are diverged from the origin master and missing 'origin/master' in your current baseline.
If you want to bring your repository up to date, please run the following command: 
gitq fetch origin master && gitq rebase origin master
```