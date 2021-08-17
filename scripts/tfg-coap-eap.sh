## UBUNTU 12.04 has lost support. 
## There is a way of continue using it. 
## Changing the repositories 
## See setup ubuntu 12.04/precise-eol.sources.list

## Possible issue with keyboard language... 
## To change for example to spanish
## sudo setxkbmap -layout 'es,es' -model pc105


## Installing libraries and dependencies
# Preemtive update and upgrade
sudo apt-get update && sudo apt-get -y upgrade 

# Installing libraries and dependencies
sudo apt-get install -y autoconf libtool libssl-dev libxml2-dev openssl
sudo apt-get install -y clang libcunit1 libcunit1-dev

#Installing Java for Contiki
sudo apt-get install -y openjdk-7-jdk ant

# Posible pre-requisite for installing the cross-compilser mspgcc-4.7.2
sudo apt-get install texinfo

# Setting JAVA_HOME
sudo echo "export JAVA_HOME=/usr/lib/jvm/java-1.7.0-openjdk-i386/" >> $HOME/.bashrc

# Setting the working folder in a variable
TFG=$HOME/coap-eap-tfg



# Downloading the customized code for the proof-of-concept
git clone \
https://github.com/dangarciacarrillo/tfg-coap-eap-proof-of-concept \
$TFG




# Installing FreeRADIUS with PSK support
cd $TFG
tar xvf freeradius-2.0.2-psk.tar.gz
cd $TFG/freeradius-2.0.2-psk/hostapd/eap_example
make CONFIG_SOLIB=yes
cd $TFG/freeradius-2.0.2-psk/
tar xvf freeradius-server-2.0.2.tar.bz2
cp ./freeradius_mod_files/modules.c ./freeradius-server-2.0.2/src/main/
cp ./freeradius_mod_files/Makefile \
./freeradius-server-2.0.2/src/modules/rlm_eap2/

cd $TFG/freeradius-2.0.2-psk/freeradius-server-2.0.2
./configure --prefix=$HOME/freeradius-psk --with-modules=rlm_eap2
make
make install

# Adding some configuration files post-instalation
cd $TFG/freeradius-2.0.2-psk
cp ./freeradius_mod_files/eap.conf  $HOME/freeradius-psk/etc/raddb
cp ./freeradius_mod_files/users 	$HOME/freeradius-psk/etc/raddb
cp ./freeradius_mod_files/default   $HOME/freeradius-psk/etc/raddb/sites-enabled/



# Launching FreeRADIUS
export \
LD_PRELOAD=$TFG/freeradius-2.0.2-psk/hostapd/eap_example/libeap.so
$HOME/freeradius-psk/sbin/radiusd -X


## Installing Contiki 2.7

#Downloading Contiki from github.com
cd $HOME
git clone \
https://github.com/contiki-os/contiki.git contiki-2.7
cd  contiki-2.7
git checkout release-2-7

# Installing tunslip6 tool
cd $HOME/contiki-2.7/tools
make tunslip6

# To launch the tunslip tool in a loop, so the simulation can bind
cd $HOME/contiki-2.7/tools
while [ 1 ]; do sudo ./tunslip6 -a 127.0.0.1 aaaa::ff:fe00:1/64; sleep 4; done


## Preparing the CoAP-EAP Controller
# Compiling cantcoap to generate the library 
cd $TFG
tar xvf coap-eap-controller.tar.gz
cd $TFG/coap-eap-controller/src/cantcoap-master
make clean && make

# Compiling the CoAP-EAP Controller
cd $TFG/coap-eap-controller
autoreconf
automake
./configure --enable-aes
make

# Launching the Controller
cd src
./coapeapcontroller

# Installing the mspgcc compiler
# Alternatively there is the script in "scripts/install msp430 compiler"
cd $TFG
tar xvf mspgcc-4.7.2.tar.gz
sudo cp -R mspgcc-4.7.2 /opt
sudo echo "export PATH=$JAVA_HOME:/opt/mspgcc-4.7.2/bin:$PATH" >> $HOME/.bashrc
source $HOME/.bashrc
## Setting up COOJA

# Launching the COOJA simulation
cd $TFG
tar xvf contiki-2.7.tar.gz
cp -R contiki-2.7/apps/* $HOME/contiki-2.7/apps
cp -R contiki-2.7/examples/* $HOME/contiki-2.7/examples
cd $HOME/contiki-2.7/examples/coap-eap-ietf
make TARGET=cooja coapeap-ietfv03-simulation-z1-1hops-1node-100ratio.csc





