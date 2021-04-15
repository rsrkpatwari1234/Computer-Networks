
# NAME : RADHIKA PATWARI
# ROLL NO. : 18CS10062
# PART B

# ===========================================================================

# I am working with 'sudo' for authentication ; please feel free to remove it 
# if you are already running as 'root' user in your system

echo -------- CREATING AND LISTING NETWORK NAMESPACES --------------------

# Creating four network namespace with name 'H1', 'H2', 'H3' and 'R'
sudo ip netns add H1
sudo ip netns add H2
sudo ip netns add H3
sudo ip netns add R

# To verify namespaces are created , print all the namespaces present in the system
echo -e "\nList of namespaces present currently"
ip netns list

echo -e "\nH1, H2, H3 and R namespaces successfully created!\n"

echo -------- CREATING VIRTUAL ETHERNET INTERFACES -----------------------

# Creating 6 virtual ethernet (veth) interfaces
# Linking 'veth1' and 'veth2', 'veth4' and 'veth5' & 'veth3' and 'veth6'
sudo ip link add veth1 type veth peer name veth2
sudo ip link add veth4 type veth peer name veth5
sudo ip link add veth3 type veth peer name veth6

# To verify that the veth pairs are created by listing all existing network links
echo -e "\nList of veth pairs present currently\n"
ip link list

echo -e "Interfaces created successfully!\n"

echo --------- ASSIGNING VETH INTERFACES TO NAMESPACES -------------------

sudo ip link set veth1 netns H1
sudo ip link set veth2 netns R
sudo ip link set veth3 netns R
sudo ip link set veth4 netns R
sudo ip link set veth5 netns H3
sudo ip link set veth6 netns H2
echo -e "\nAssigned interfaces to H1,H2 and H3!\n"

echo --------- CONFIGURING INTERFACES -------------------------------------

# Configuring veth1 interface of namespace 'H1' with ip 10.0.10.62/24
sudo ip netns exec H1 ip addr add 10.0.10.62/24 dev veth1

# To verify that veth1 is successfully configured by listing links of 'H1'
echo -e "\nList of interfaces at H1"
sudo ip netns exec H1 ip addr list
echo -e "\nSuccessfully configured veth1 of H1\n"

# Configuring veth6 interface of namespace 'H2' with ip 10.0.20.62/24
sudo ip netns exec H2 ip addr add 10.0.20.62/24 dev veth6

# To verify that veth6 is successfully configured by listing links of 'H2'
echo -e "\nList of interfaces at H2"
sudo ip netns exec H2 ip addr list
echo -e "\nSuccessfully configured veth6 of H2\n"

# Configuring veth5 interface of namespace 'H3' with ip 10.0.30.62/24
sudo ip netns exec H3 ip addr add 10.0.30.62/24 dev veth5

# To verify that veth5 is successfully configured by listing links of 'H3'
echo -e "\nList of interfaces at H3"
sudo ip netns exec H3 ip addr list
echo -e "\nSuccessfully configured veth5 of H3\n"

# Configuring veth2 interface of namespace 'R' with ip 10.0.10.1/24
sudo ip netns exec R ip addr add 10.0.10.1/24 dev veth2

# Configuring veth3 interface of namespace 'R' with ip 10.0.20.1/24
sudo ip netns exec R ip addr add 10.0.20.1/24 dev veth3

# Configuring veth4 interface of namespace 'R' with ip 10.0.30.1/24
sudo ip netns exec R ip addr add 10.0.30.1/24 dev veth4

# To verify that interfaces are successfully configured by listing links of 'R'
echo -e "\nList of interfaces at R"
sudo ip netns exec R ip addr list
echo -e "\nSuccessfully configured veth2,veth3 and veth4 of R\n"

echo ---------- SETTING PORTS UP ----------------------------------------------

sudo ip netns exec H1 ip link set veth1 up
sudo ip netns exec R ip link set veth2 up
sudo ip netns exec R ip link set veth3 up
sudo ip netns exec R ip link set veth4 up
sudo ip netns exec H3 ip link set veth5 up
sudo ip netns exec H2 ip link set veth6 up
echo -e "\nAll interfaces are up\n"

echo ---------- SETTING DEFAULT ROUTES ----------------------------------------

# Configuring all external traffic at H1 to pass through veth1
sudo ip netns exec H1 ip route add default via 10.0.10.62 dev veth1

# Configuring all external traffic at R to pass through veth2
sudo ip netns exec R ip route add default via 10.0.10.1 dev veth2 

# Configuring all external traffic at R to pass through veth2
sudo ip netns exec R ip route add default via 10.0.20.1 dev veth3 

# Configuring all external traffic at R to pass through veth2
sudo ip netns exec R ip route add default via 10.0.30.1 dev veth4 

# Configuring all external traffic at H3 to pass through veth6
sudo ip netns exec H3 ip route add default via 10.0.30.62 dev veth5

# Configuring all external traffic at H2 to pass through veth6
sudo ip netns exec H2 ip route add default via 10.0.20.62 dev veth6

# Enabling ip forwarding at R
sudo ip netns exec R sysctl -w net.ipv4.ip_forward=1

echo ---------- DISPLAYING ROUTE TABLE -----------------------------------------

echo -e "\nRoute table at H1\n"
sudo ip netns exec H1 ip route 

echo -e "\nRoute table at H2\n"
sudo ip netns exec H2 ip route 

echo -e "\nRoute table at H3\n"
sudo ip netns exec H3 ip route 

echo -e "\nRoute table at R\n"
sudo ip netns exec R ip route 

echo --------- CREATING ETHERNET BRIDGE AT R ----------------------------------
sudo ip netns exec R ip link add name bridge_R type bridge
echo -e "\nBridge 'bridge_R' successfully created at R!\n"

echo ---------- SETTING BRIDGE UP ---------------------------------------------

sudo ip netns exec R ip link set bridge_R up
sudo ip netns exec R bridge link
echo -e "\nBridge 'bridge_R' at namespace 'R' is up\n"

echo --------- ASSIGNING VETH INTERFACES TO ETHERNET BRIDGE--------------

sudo ip netns exec R ip link set veth2 master bridge_R
sudo ip netns exec R ip link set veth3 master bridge_R
sudo ip netns exec R ip link set veth4 master bridge_R
echo -e "\nAssigned interfaces to bridge at R!\n"

echo ---------- PERFORMING PING OPERATIONS -------------------------------------

# Some testing ping operations
sudo ip netns exec H1 ping -c 1 10.0.30.62
sudo ip netns exec H2 ping -c 1 10.0.10.62

echo ---------- TESTING : DELETING ALL NAMESPACES, INTERFACES AND BRIDGE -------

sudo ip netns del H1
sudo ip netns del H2
sudo ip netns del H3
# deleting the bridge at R before deleting R itself
sudo ip netns exec R ip link delete bridge_R down type bridge
sudo ip netns del R

# deleting interfaces
sudo ip link del veth1 type veth peer name veth2
sudo ip link del veth3 type veth peer name veth6
sudo ip link del veth4 type veth peer name veth5

echo -e "\nCheck deletion .....\n"
ip netns list
echo -e "\nSuccesfully deleted namespaces, interfaces and bridge"


