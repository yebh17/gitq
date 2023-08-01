#!/bin/bash

set -e
set -o pipefail

setup_git_config() {
    # Check if .gitconfig already exists
    if [ ! -f ~/.gitconfig ]; then
        echo ""
        echo "*** Looks like you are missing some configurations***"
        echo "Your '.gitconfig' is missing in your home folder, follow the below prompts to setup your '.gitconfig'"
        read -p "Enter your git user name: " username
        read -p "Enter your git email: " useremail
        gitq config --global user.name "$username"
        gitq config --global user.email "$useremail"
        echo "Git config has been set up with user name: $username and user email: $useremail. You can check the config in ~/.gitconfig"
    fi
}

set_git_editor() {
    # Check if the editor is already set in the .gitconfig file, if not then set it.
    if ! grep -q "\[core\]" ~/.gitconfig; then
        echo "*** Looks like you are missing some configurations ***"
        local selected_editor
        local valid_editor=false

        while ! $valid_editor; do
            echo ""
            echo "Select your preferred editor for Git operations:"
            echo "1. Nano"
            echo "2. Vim"
            echo "3. Emacs"
            echo "4. VSCode"
            echo "5. Geany"
            echo "6. Other (Specify a custom editor)"

            read -p "Enter the number of your choice: " editor_choice

            case "$editor_choice" in
                1)
                    selected_editor="nano"
                    ;;
                2)
                    selected_editor="vim"
                    ;;
                3)
                    selected_editor="emacs"
                    ;;
                4)
                    selected_editor="code --wait"
                    ;;
                5)
                    selected_editor="geany"
                    ;;
                6)
                    read -p "Enter the custom editor command (e.g., 'subl -w' for Sublime Text): " custom_editor
                    selected_editor="$custom_editor"
                    ;;
                *)
                    echo "Invalid choice. Please choose a valid editor."
                    continue
                    ;;
            esac

            # Check if the selected editor is installed on the host
            if command -v "$selected_editor" &>/dev/null; then
                gitq config --global core.editor "$selected_editor"
                echo "Your chosen editor has been set as the default editor for Git operations."
                valid_editor=true
            else
                read -p "The selected editor is not installed on the host. Do you want to choose a different editor? (yes/no): " response
                case "$response" in
                    [Nn]|[Nn][Oo])
                        echo "No changes have been made to the default editor."
                        return
                        ;;
                esac
            fi
        done
    fi
}

display_git_log_explanation() {
    echo "
Commit ID: This is a unique identifier for a particular commit. It is a long string of alphanumeric characters, typically shown as a SHA-1 hash. The commit ID uniquely identifies each commit in the Git history.

HEAD -> master: This indicates the current branch you are on (HEAD) and the branch it points to (master). In Git, HEAD represents the current commit or branch that you have checked out. In this case, it means you are on the master branch.

origin/master: This refers to the 'master' branch on the remote repository, typically named 'origin.' When you clone a repository, 'origin' is the default name given to the remote repository from which you cloned.

origin/HEAD: This refers to the default branch on the remote repository. It points to the same branch as origin/master, which is typically the default branch of the remote repository.

Author: The author of the commit. It includes the name and email address of the person who made the changes. The author is the person who initially created the changes.

Date: The date and time when the commit was made. It shows the timestamp of when the changes were committed.

Commit Message: This is the descriptive message provided by the author when they committed the changes. The commit message explains the purpose of the commit, the changes made, and any other relevant information about the commit."
}

git_wrapper() {
    if [[ "$*" == *"-e"* ]] && [ "$1" = "log" ]
    then
        display_git_log_explanation
    elif command -v git &>/dev/null; then
        git "$@"
    else
        echo "Git is not installed. Please install Git to use version control."
        return 1
    fi
}

# Main function
main() {

    # Wrapped git alongside additional help features
    git_wrapper "$@"

    # Set git editor if needed
    set_git_editor

    # Set git config if needed
    setup_git_config
}

main "$@"