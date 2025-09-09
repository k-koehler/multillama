#!/bin/bash

# check for existing install and remove
if [ -d ~/.multillama ]; then
    echo "Existing installation found at ~/.multillama, removing it."
    rm -rf ~/.multillama
    # remove from profile files
    if [ -f ~/.bash_profile ]; then
        sed -i '/export PATH="\$PATH:\$HOME\/.multillama"/d' ~/.bash_profile
    fi
    if [ -f ~/.bashrc ]; then
        sed -i '/export PATH="\$PATH:\$HOME\/.multillama"/d' ~/.bashrc
    fi
    if [ -f ~/.zshrc ]; then
        sed -i '/export PATH="\$PATH:\$HOME\/.multillama"/d' ~/.zshrc
    fi
    if [ -f ~/.profile ]; then
        sed -i '/export PATH="\$PATH:\$HOME\/.multillama"/d' ~/.profile
    fi
    echo "Previous installation removed."
fi

# check for node 18+
if ! command -v node &> /dev/null
then
    echo "Node.js could not be found, please install Node.js 18 or higher."
    exit
fi

# check for git
if ! command -v git &> /dev/null
then
    echo "Git could not be found, please install Git."
    exit
fi


# clone repo into ~/.multillama
git clone https://github.com/k-koehler/multillama ~/.multillama

# prepare executable
chmod +x ~/.multillama/multillama

# check in order
# ~/.bashprofile
# ~/.bashrc
# ~/.zshrc
# ~/.profile
if [ -f ~/.bash_profile ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.bash_profile
    echo "Executable installed to ~/.bash_profile"
    echo "Type 'source ~/.bash_profile' or restart your terminal to apply the changes."
elif [ -f ~/.bashrc ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.bashrc
    echo "Executable installed to ~/.bashrc"
    echo "Type 'source ~/.bashrc' or restart your terminal to apply the changes."
elif [ -f ~/.zshrc ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.zshrc
    echo "Executable installed to ~/.zshrc"
    echo "Type 'source ~/.zshrc' or restart your terminal to apply the changes."
elif [ -f ~/.profile ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.profile
    echo "Executable installed to ~/.profile"
    echo "Type 'source ~/.profile' or restart your terminal to apply the changes."
else
    echo "No profile file found. Please add 'export PATH=\"\$PATH:\$HOME/.multillama\"' to your shell profile manually."
    exit
fi

echo "Multillama installed! You can now run it with the command 'multillama'."