# gitq

Introducing gitq: Simplifying Your Git Workflow with Interactive Prompts and Guidance!

gitq is an innovative git wrapper tool designed to streamline your experience with Git commands. Say goodbye to the complexities of remembering various git commands and their syntax – with gitq, you'll receive interactive prompts right in your terminal, guiding you through each step of your workflow.

Navigating through different scenarios becomes a breeze, as gitq provides real-time feedback and suggests the most suitable commands based on your specific requirements. Whether you're committing changes, branching, merging, or handling complex version control tasks, gitq has got you covered.

Embrace the power of a more intuitive and user-friendly Git experience. Try gitq now and witness how effortlessly you can interact with Git, making version control a seamless and enjoyable process for developers of all levels.

## Steps (LINUX)

Clone this repo wherever you prefer, for simplifying things I use home folder in this case.
-   `cd ~`
-   `git clone git@github.com:yebh17/gitq.git`
-   `cd gitq`

We need to make the script permanently available in the PATH, so that gitq is accessible from any path.
-   `mkdir -p ~/bin`

Copy the gitq script to the bin folder you just created.
-   `cp gitq.sh ~/bin/gitq`

Add this "bin" directory to the PATH.
-   `nano ~/.bashrc`

Add the following line at the end of the file.
-   `export PATH="$HOME/bin:$PATH"`
Save and close the file.

###### Note: If you are using a different shell (e.g., Zsh), use the appropriate configuration file (e.g., ~/.zshrc) instead.

Ensure the script has executable permissions.
-   `chmod +x ~/bin/gitq`

To apply the changes immediately, either close and reopen your terminal or run the following in the same terminal.
-   `source ~/.bashrc`
###### Note: If you made changes to a different shell configuration file, replace "~/.bashrc" with the appropriate file path.

Now, you should be able to run the script from any location simply by typing its name, example,
-   `gitq -h`