brew update
brew install nvm
mkdir ~/.nvm
echo "export NVM_DIR=~/.nvm\nsource \$(brew --prefix nvm)/nvm.sh" >> .zshrc
source ~/.zshrc

# enlace donde obtuve el código
# https://medium.com/@alvaro.apavon/como-instalar-nvm-node-versi%C3%B3n-manager-en-macos-chip-apple-con-brew-0cb56eb1605a