
#!/bin/bash
set -e
set -o pipefail

check_git_installed() {
    if command -v git &>/dev/null; then
        echo "Git is installed."
    else
        echo "Git is not installed. Please install Git to use version control."
        exit 1
    fi
}

setup_git_config() {
    # Check if .gitconfig already exists
    if [ -f ~/.gitconfig ]; then
        echo "Git config is already set up."
        return
    fi

    # Prompt for user name and email if not provided as arguments
    if [ -z "$1" ]; then
        read -p "Enter your git user name: " username
    else
        username="$1"
    fi

    if [ -z "$2" ]; then
        read -p "Enter your git email: " useremail
    else
        useremail="$2"
    fi

    # Set up git config with provided user name and email
    git config --global user.name "$username"
    git config --global user.email "$useremail"
    echo "Git config has been set up with user name: $username and user email: $useremail"
}



# Main function
main() 
{
    check_git_installed
    setup_git_config
}

main "$@"
