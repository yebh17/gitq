#!/bin/bash

set -e
set -o pipefail

# Function to intercept "git" calls and forward them to the actual "git" command
gitq() {
    # Check if "git" is installed
    if command -v git &>/dev/null; then
        # Execute the "git" command with the provided arguments
        git "$@"
    else
        echo "Git is not installed. Please install Git to use version control."
        return 1
    fi
}

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

# Main function
main() 
{
    gitq "$@"
    setup_git_config
    set_git_editor
}

main "$@"