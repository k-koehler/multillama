#!/bin/bash

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
    source ~/.bash_profile
elif [ -f ~/.bashrc ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.bashrc
    source ~/.bashrc
elif [ -f ~/.zshrc ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.zshrc
    source ~/.zshrc
elif [ -f ~/.profile ]; then
    echo 'export PATH="$PATH:$HOME/.multillama"' >> ~/.profile
    source ~/.profile
else
    echo "Could not find a shell profile file to update. Please add ~/.multillama to your PATH manually."
    exit
fi

echo "Multillama installed! You can now run it with the command 'multillama'."