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
cd $TFG/coap-eap-controller/src/cantcoap-master
make

# Compiling the CoAP-EAP Controller
cd $TFG/coap-eap-controller
autoreconf
automake
./configure --enable-aes
make

# Launching the Controller
cd src
./openpaa


# Launching the COOJA simulation
cd $HOME/contiki-2.7/examples/coap-eap-ietf
make TARGET=cooja coapeap-ietfv03-simulation-z1-1hops-1node-100ratio.csc





