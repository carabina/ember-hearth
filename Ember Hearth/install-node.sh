# via https://gist.github.com/isaacs/579814
echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bashrc
echo 'export PATH=$HOME/local/bin:$PATH' >> ~/.bash_profile
. ~/.bashrc
. ~/.bash_profile
mkdir ~/local
mkdir ~/node-latest-install
cd ~/node-latest-install
curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
./configure --prefix=$HOME/local
make install