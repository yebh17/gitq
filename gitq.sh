#!/bin/bash

set -e
set -o pipefail

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

setup_git_config() {
    if [ ! -f ~/.gitconfig ]; then
        echo ""
        echo "*** Welcome to GitQ! ***"
        echo "It looks like you are missing some configurations."
        echo "Let's set up your '.gitconfig':"
        read -p "Enter your git user name: " username
        read -p "Enter your git email: " useremail
        gitq config --global user.name "$username"
        gitq config --global user.email "$useremail"
        echo "Git config has been set up with user name: $username and user email: $useremail."
        echo "You can check the config in ~/.gitconfig"
    fi
}

set_git_editor() {
    if ! grep -q "\[core\]" ~/.gitconfig; then
        echo "*** Choose Your Editor ***"
        select selected_editor in "Nano" "Vim" "Emacs" "VSCode" "Geany" "Other"; do
            case "$selected_editor" in
                "Other")
                    read -p "Enter the custom editor command: " custom_editor
                    selected_editor="$custom_editor"
                    ;;
            esac
            if command -v "$selected_editor" &>/dev/null; then
                gitq config --global core.editor "$selected_editor"
                echo "Your chosen editor has been set as the default for Git operations."
                break
            else
                echo "The selected editor is not installed. Please choose a different editor."
            fi
        done
    fi
}

check_origin_master() {
    if [ -z "$(git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit | grep 'origin/master, origin/HEAD, master')" ]; then
        echo ""
        echo "------------------------------------------------------------------------"
        echo -e "⚠️ WARNING! Diverged from 'origin/master' ⚠️\n"
        echo -e "* If you wantedly checked-out to a particular commit diverging from 'origin/master' (or) wantedly kept your baseline behind 'origin/master', you can IGNORE this message\n"
        echo -e "* If you checked-out to a particular commit diverging from 'origin/master' (or) If you are stuck with your baseline being behind 'origin/master' and wanted to have your current baseline up to date with 'origin/master', you can run:\n"
        if [ '$(git rev-parse --abbrev-ref HEAD)' = "master" ]; then
            echo -e "> git pull origin master\n"
        else
            echo -e "> git pull origin $(git rev-parse --abbrev-ref HEAD)\n"
            echo -e "* If you want to update your local "$(git rev-parse --abbrev-ref HEAD)" branch with remote master, run:\n> gitq checkout master\n> gitq rebase origin master\n> gitq rebase master $(git rev-parse --abbrev-ref HEAD)"
        fi
        echo "------------------------------------------------------------------------"
    fi
}

display_git_log_explanation() {
    echo "Commit Log Information:"
    echo "----------------------------------"
    echo "Commit ID: Unique identifier for each commit."
    echo "HEAD -> master: Current commit or branch checked out."
    echo "origin/master: Default branch on remote repository."
    echo "Author: The person who made the changes."
    echo "Date: Timestamp when the commit was made."
    echo -e "Commit Message: Descriptive message explaining the changes.\n"
}

interactive_rebase_help_text() {
    local last_arg=${@: -1}
    local n=${last_arg#"HEAD~"}
    local COMMITS_PICKED=$(git log -n "$n" --pretty=format:"%h %s")
    echo "This is the list of commits you are about to rebase interactively:"
    echo "--------------------------------------------------------------"
    echo "$COMMITS_PICKED"
    git rebase -i --exec "cat /tmp/rebase-script; rm /tmp/rebase-script" "$CURRENT_BRANCH"
}

show_commits_gui() {
    local last_arg=${@: -1}
    local n=${last_arg#"HEAD~"}

    # Get the original commit log before reordering
    local original_commit_log=$(git log -n "$n" --pretty=format:"%h %s")

    # Run the interactive rebase command
    git rebase -i HEAD~"$n"
    rebase_exit_code=$?

    # Create a temporary file to store the commit logs with visualization
    log_file=$(mktemp)

    if [ "$rebase_exit_code" -eq 1 ]; then
        git rebase --abort
        echo "Interactive rebase aborted."
        return
    else
        # Get the updated commit log after reordering
        updated_commit_log=$(git log -n "$n" --pretty=format:"%h %s")

        # Add visualization elements to the commit logs
        echo -e "🌟🌟🌟 Original Commit Log 🌟🌟🌟\n"
        echo "$original_commit_log" | sed 's/^/  ➤ /' >> "$log_file"
        echo -e "\n\n🔄🔄🔄 Reordering Commits 🔄🔄🔄\n\n" >> "$log_file"
        echo -e "🌟🌟🌟 Updated Commit Log 🌟🌟🌟\n" >> "$log_file"
        echo "$updated_commit_log" | sed 's/^/  ➤ /' >> "$log_file"

        # Display a Zenity question dialog to choose whether to continue or abort
        local original_commit_log=$(git log -n "$n" --pretty=format:"%h %s")
        zenity --question --title="Commit Reordering Visualization" --text="The following is the order of how you will have your commits in your commit history now, \n\n $original_commit_log\n\nDo you want to abort the interactive rebase?\n\nNote: If you abort the interactive rebase process you will be redirected to the interactive rebase IDE again, you then need to update the commits back to how they were before." --ok-label="Abort" --cancel-label="Continue"
        response=$?

        if [ $response -eq 0 ]; then
            git rebase -i HEAD~"$n"
            echo "Interactive rebase aborted."
        fi

        # Remove the temporary file
        rm "$log_file"
    fi
}

handle_interactive_rebase_with_changes() {
    echo "Error: You have unstaged changes. Here are the changes:"
    git status --short
    read -p "Do you want to stash these changes? (y/n): " stash_choice
    case "$stash_choice" in
        [Yy])
            git stash
            echo "Changes stashed successfully. Continuing with the interactive rebase."
            show_commits_gui "$@"
            ;;
        [Nn])
            echo "Exiting without performing the interactive rebase."
            return 1
            ;;
        *)
            echo "Invalid choice. Exiting without performing the interactive rebase."
            return 1
            ;;
    esac
}

git_wrapper() {
    if [[ "$*" == *"-e"* ]] && [ "$1" = "log" ]
    then
        display_git_log_explanation
    elif [[ "$*" == *"-i"* ]] && [ "$1" = "rebase" ]
    then
        if git diff --exit-code --quiet
        then
            show_commits_gui "$@"
        else
            handle_interactive_rebase_with_changes "$@"
        fi
    elif command -v git &>/dev/null; then
        git "$@"
    else
        echo "Git is not installed. Please install Git to use version control."
        return 1
    fi
}

main() {
    git_wrapper "$@"
    setup_git_config
    set_git_editor
    check_origin_master
}

main "$@"
