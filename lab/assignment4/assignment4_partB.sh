
# NAME : RADHIKA PATWARI
# ROLL NO. : 18CS10062
# Assignment 4
# PART B

# ===========================================================================

# I am working with 'sudo' for authentication ; please feel free to remove it 
# if you are already running as 'root' user in your system

echo -------- CREATING AND LISTING NETWORK NAMESPACES --------------------

# Creating four network namespace with name 'H1', 'H2', 'H3', 'H4', 'R1', 'R2' and 'R3'
sudo ip netns add H1
sudo ip netns add H2
sudo ip netns add H3
sudo ip netns add H4
sudo ip netns add R1
sudo ip netns add R2
sudo ip netns add R3

# To verify namespaces are created , print all the namespaces present in the system
echo -e "\nList of namespaces present currently"
ip netns list

echo -e "\nH1, H2, H3, H4, R1, R2 and R3 namespaces successfully created!\n"

echo -------- CREATING VIRTUAL ETHERNET INTERFACES -----------------------

# Creating 12 virtual ethernet (veth) interfaces
# Linking 'v1' and 'v2', 'v3' and 'v4', 'v5' and 'v6', 'v7' and 'v8', 'v9' and 'v10' & 'v11' and 'v12' 
sudo ip link add v1 type veth peer name v2
sudo ip link add v3 type veth peer name v4
sudo ip link add v5 type veth peer name v6
sudo ip link add v7 type veth peer name v8
sudo ip link add v9 type veth peer name v10
sudo ip link add v11 type veth peer name v12

# To verify that the veth pairs are created by listing all existing network links
echo -e "\nList of veth pairs present currently\n"
ip link list

echo -e "Interfaces created successfully!\n"

echo --------- ASSIGNING VETH INTERFACES TO NAMESPACES -------------------

sudo ip link set v1 netns H1
sudo ip link set v2 netns R1
sudo ip link set v3 netns H2
sudo ip link set v4 netns R1
sudo ip link set v5 netns R1
sudo ip link set v6 netns R2
sudo ip link set v7 netns R2
sudo ip link set v8 netns R3
sudo ip link set v9 netns R3
sudo ip link set v10 netns H3
sudo ip link set v11 netns R3
sudo ip link set v12 netns H4
echo -e "\nAssigned interfaces to H1,H2,H3,H4,R1,R2 and R3!\n"

echo --------- CONFIGURING INTERFACES -------------------------------------

sudo ip netns exec H1 ip addr add 10.0.10.62/24 dev v1
sudo ip netns exec R1 ip addr add 10.0.10.63/24 dev v2
sudo ip netns exec H2 ip addr add 10.0.20.62/24 dev v3
sudo ip netns exec R1 ip addr add 10.0.20.63/24 dev v4
sudo ip netns exec R1 ip addr add 10.0.30.62/24 dev v5
sudo ip netns exec R2 ip addr add 10.0.30.63/24 dev v6
sudo ip netns exec R2 ip addr add 10.0.40.62/24 dev v7
sudo ip netns exec R3 ip addr add 10.0.40.63/24 dev v8
sudo ip netns exec R3 ip addr add 10.0.50.62/24 dev v9
sudo ip netns exec H3 ip addr add 10.0.50.63/24 dev v10
sudo ip netns exec R3 ip addr add 10.0.60.62/24 dev v11
sudo ip netns exec H4 ip addr add 10.0.60.63/24 dev v12

echo -e "\nList of interfaces at H1 :"
sudo ip netns exec H1 ip addr list
echo -e "\nList of interfaces at H2 :"
sudo ip netns exec H2 ip addr list
echo -e "\nList of interfaces at H3 :"
sudo ip netns exec H3 ip addr list
echo -e "\nList of interfaces at H4 :"
sudo ip netns exec H4 ip addr list
echo -e "\nList of interfaces at R1 :"
sudo ip netns exec R1 ip addr list
echo -e "\nList of interfaces at R2 :"
sudo ip netns exec R2 ip addr list
echo -e "\nList of interfaces at R3 :"
sudo ip netns exec R3 ip addr list

# echo ---------- SETTING PORTS UP ----------------------------------------------

sudo ip netns exec H1 ip link set v1 up
sudo ip netns exec R1 ip link set v2 up
sudo ip netns exec H2 ip link set v3 up
sudo ip netns exec R1 ip link set v4 up
sudo ip netns exec R1 ip link set v5 up
sudo ip netns exec R2 ip link set v6 up
sudo ip netns exec R2 ip link set v7 up
sudo ip netns exec R3 ip link set v8 up
sudo ip netns exec R3 ip link set v9 up
sudo ip netns exec H3 ip link set v10 up
sudo ip netns exec R3 ip link set v11 up
sudo ip netns exec H4 ip link set v12 up

echo -e "\nAll interfaces are up\n"

echo ---------- ENABLING LOOPBACK INTERFACE AT NAMESPACES ---------------------

sudo ip netns exec H1 ip link set dev lo up
sudo ip netns exec H2 ip link set dev lo up
sudo ip netns exec H3 ip link set dev lo up
sudo ip netns exec H4 ip link set dev lo up
sudo ip netns exec R1 ip link set dev lo up
sudo ip netns exec R2 ip link set dev lo up
sudo ip netns exec R3 ip link set dev lo up

echo -e "\nAll loopback interfaces are up\n"

echo ---------- ENABLING IP FORWARDINIG AT THE NAMESPACES --------------------

# Enabling ip forwarding at R1, R2 and R3

sudo ip netns exec R1 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec R2 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec R3 sysctl -w net.ipv4.ip_forward=1


echo -e "\nEnabling ip forwarding at the namespaces R1, R2 and R3\n"

echo ---------- SETTING UP ROUTE TABLE ----------------------------------------

sudo ip netns exec H1 ip route add 10.0.20.0/24 via 10.0.10.63 dev v1
sudo ip netns exec H1 ip route add 10.0.30.0/24 via 10.0.10.63 dev v1
sudo ip netns exec H1 ip route add 10.0.40.0/24 via 10.0.10.63 dev v1
sudo ip netns exec H1 ip route add 10.0.50.0/24 via 10.0.10.63 dev v1
sudo ip netns exec H1 ip route add 10.0.60.0/24 via 10.0.10.63 dev v1

sudo ip netns exec H2 ip route add 10.0.10.0/24 via 10.0.20.63 dev v3
sudo ip netns exec H2 ip route add 10.0.30.0/24 via 10.0.20.63 dev v3
sudo ip netns exec H2 ip route add 10.0.40.0/24 via 10.0.20.63 dev v3
sudo ip netns exec H2 ip route add 10.0.50.0/24 via 10.0.20.63 dev v3
sudo ip netns exec H2 ip route add 10.0.60.0/24 via 10.0.20.63 dev v3

sudo ip netns exec H3 ip route add 10.0.10.0/24 via 10.0.50.62 dev v10
sudo ip netns exec H3 ip route add 10.0.20.0/24 via 10.0.50.62 dev v10
sudo ip netns exec H3 ip route add 10.0.30.0/24 via 10.0.50.62 dev v10
sudo ip netns exec H3 ip route add 10.0.40.0/24 via 10.0.50.62 dev v10
sudo ip netns exec H3 ip route add 10.0.60.0/24 via 10.0.50.62 dev v10

sudo ip netns exec H4 ip route add 10.0.10.0/24 via 10.0.60.62 dev v12
sudo ip netns exec H4 ip route add 10.0.20.0/24 via 10.0.60.62 dev v12
sudo ip netns exec H4 ip route add 10.0.30.0/24 via 10.0.60.62 dev v12
sudo ip netns exec H4 ip route add 10.0.40.0/24 via 10.0.60.62 dev v12
sudo ip netns exec H4 ip route add 10.0.50.0/24 via 10.0.60.62 dev v12

sudo ip netns exec R1 ip route add 10.0.40.0/24 via 10.0.30.63 dev v5
sudo ip netns exec R1 ip route add 10.0.50.0/24 via 10.0.30.63 dev v5
sudo ip netns exec R1 ip route add 10.0.60.0/24 via 10.0.30.63 dev v5

sudo ip netns exec R2 ip route add 10.0.10.0/24 via 10.0.30.62 dev v6
sudo ip netns exec R2 ip route add 10.0.20.0/24 via 10.0.30.62 dev v6
sudo ip netns exec R2 ip route add 10.0.50.0/24 via 10.0.40.63 dev v7
sudo ip netns exec R2 ip route add 10.0.60.0/24 via 10.0.40.63 dev v7

sudo ip netns exec R3 ip route add 10.0.10.0/24 via 10.0.40.62 dev v8
sudo ip netns exec R3 ip route add 10.0.20.0/24 via 10.0.40.62 dev v8
sudo ip netns exec R3 ip route add 10.0.30.0/24 via 10.0.40.62 dev v8

echo ---------- DISPLAYING ROUTE TABLE -----------------------------------------

echo -e "\nRoute table at H1 :\n"
sudo ip netns exec H1 ip route 

echo -e "\nRoute table at H2 :\n"
sudo ip netns exec H2 ip route 

echo -e "\nRoute table at H3 :\n"
sudo ip netns exec H3 ip route 

echo -e "\nRoute table at H4 :\n"
sudo ip netns exec H4 ip route

echo -e "\nRoute table at R1 :\n"
sudo ip netns exec R1 ip route 

echo -e "\nRoute table at R2 :\n"
sudo ip netns exec R2 ip route 

echo -e "\nRoute table at R3 :\n"
sudo ip netns exec R3 ip route  

echo ---------- PERFORMING PING OPERATIONS -------------------------------------

tot_packets=3

# ping from H1
echo -e "\nFrom H1 :\n" 
sudo ip netns exec H1 ping -c $tot_packets 10.0.10.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.10.63
sudo ip netns exec H1 ping -c $tot_packets 10.0.20.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.20.63
sudo ip netns exec H1 ping -c $tot_packets 10.0.30.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.30.63
sudo ip netns exec H1 ping -c $tot_packets 10.0.40.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.40.63
sudo ip netns exec H1 ping -c $tot_packets 10.0.50.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.50.63
sudo ip netns exec H1 ping -c $tot_packets 10.0.60.62
sudo ip netns exec H1 ping -c $tot_packets 10.0.60.63

# ping from H2
echo -e "\nFrom H2 :\n" 
sudo ip netns exec H2 ping -c $tot_packets 10.0.10.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.10.63
sudo ip netns exec H2 ping -c $tot_packets 10.0.20.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.20.63
sudo ip netns exec H2 ping -c $tot_packets 10.0.30.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.30.63
sudo ip netns exec H2 ping -c $tot_packets 10.0.40.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.40.63
sudo ip netns exec H2 ping -c $tot_packets 10.0.50.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.50.63
sudo ip netns exec H2 ping -c $tot_packets 10.0.60.62
sudo ip netns exec H2 ping -c $tot_packets 10.0.60.63

# ping from H3
echo -e "\nFrom H3 :\n" 
sudo ip netns exec H3 ping -c $tot_packets 10.0.10.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.10.63
sudo ip netns exec H3 ping -c $tot_packets 10.0.20.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.20.63
sudo ip netns exec H3 ping -c $tot_packets 10.0.30.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.30.63
sudo ip netns exec H3 ping -c $tot_packets 10.0.40.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.40.63
sudo ip netns exec H3 ping -c $tot_packets 10.0.50.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.50.63
sudo ip netns exec H3 ping -c $tot_packets 10.0.60.62
sudo ip netns exec H3 ping -c $tot_packets 10.0.60.63

# ping from H4
echo -e "\nFrom H4 :\n" 
sudo ip netns exec H4 ping -c $tot_packets 10.0.10.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.10.63
sudo ip netns exec H4 ping -c $tot_packets 10.0.20.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.20.63
sudo ip netns exec H4 ping -c $tot_packets 10.0.30.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.30.63
sudo ip netns exec H4 ping -c $tot_packets 10.0.40.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.40.63
sudo ip netns exec H4 ping -c $tot_packets 10.0.50.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.50.63
sudo ip netns exec H4 ping -c $tot_packets 10.0.60.62
sudo ip netns exec H4 ping -c $tot_packets 10.0.60.63

# ping from R1
echo -e "\nFrom R1 :\n" 
sudo ip netns exec R1 ping -c $tot_packets 10.0.10.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.10.63
sudo ip netns exec R1 ping -c $tot_packets 10.0.20.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.20.63
sudo ip netns exec R1 ping -c $tot_packets 10.0.30.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.30.63
sudo ip netns exec R1 ping -c $tot_packets 10.0.40.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.40.63
sudo ip netns exec R1 ping -c $tot_packets 10.0.50.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.50.63
sudo ip netns exec R1 ping -c $tot_packets 10.0.60.62
sudo ip netns exec R1 ping -c $tot_packets 10.0.60.63

# ping from R2
echo -e "\nFrom R2 :\n" 
sudo ip netns exec R2 ping -c $tot_packets 10.0.10.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.10.63
sudo ip netns exec R2 ping -c $tot_packets 10.0.20.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.20.63
sudo ip netns exec R2 ping -c $tot_packets 10.0.30.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.30.63
sudo ip netns exec R2 ping -c $tot_packets 10.0.40.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.40.63
sudo ip netns exec R2 ping -c $tot_packets 10.0.50.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.50.63
sudo ip netns exec R2 ping -c $tot_packets 10.0.60.62
sudo ip netns exec R2 ping -c $tot_packets 10.0.60.63

# ping from R3
echo -e "\nFrom R3 :\n" 
sudo ip netns exec R3 ping -c $tot_packets 10.0.10.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.10.63
sudo ip netns exec R3 ping -c $tot_packets 10.0.20.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.20.63
sudo ip netns exec R3 ping -c $tot_packets 10.0.30.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.30.63
sudo ip netns exec R3 ping -c $tot_packets 10.0.40.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.40.63
sudo ip netns exec R3 ping -c $tot_packets 10.0.50.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.50.63
sudo ip netns exec R3 ping -c $tot_packets 10.0.60.62
sudo ip netns exec R3 ping -c $tot_packets 10.0.60.63

echo ---------- TRACING ROUTES -------------------------------------------------

echo -e "\nRoute from H1 to H4 : \n"
sudo ip netns exec H1 traceroute 10.0.60.63

echo -e "\nRoute from H3 to H4 : \n"
sudo ip netns exec H3 traceroute 10.0.60.63

echo -e "\nRoute from H4 to H2 : \n"
sudo ip netns exec H4 traceroute 10.0.20.62

echo ---------- TESTING : DELETING ALL NAMESPACES AND INTERFACES ---------------

sudo ip netns del H1
sudo ip netns del H2
sudo ip netns del H3
sudo ip netns del H4
sudo ip netns del R1
sudo ip netns del R2
sudo ip netns del R3

# deleting interfaces
sudo ip link del v1 type veth peer name v2
sudo ip link del v3 type veth peer name v4
sudo ip link del v5 type veth peer name v6
sudo ip link del v7 type veth peer name v8
sudo ip link del v9 type veth peer name v10
sudo ip link del v11 type veth peer name v12

echo -e "\nCheck deletion .....\n"
ip netns list
echo -e "\nSuccesfully deleted namespaces and interfaces"


