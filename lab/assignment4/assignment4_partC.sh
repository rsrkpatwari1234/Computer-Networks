
# NAME : RADHIKA PATWARI
# ROLL NO. : 18CS10062
# Assignment 4
# PART C

# ===========================================================================

# I am working with 'sudo' for authentication ; please feel free to remove it 
# if you are already running as 'root' user in your system

echo -------- CREATING AND LISTING NETWORK NAMESPACES --------------------

# Creating four network namespace with name 'N1', 'N2', 'N3', 'H4', 'N5' and 'N6'
sudo ip netns add N1
sudo ip netns add N2
sudo ip netns add N3
sudo ip netns add N4
sudo ip netns add N5
sudo ip netns add N6

# To verify namespaces are created , print all the namespaces present in the system
echo -e "\nList of namespaces present currently"
ip netns list

echo -e "\nN1, N2, N3, N4, N5 and N6 namespaces successfully created!\n"

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

sudo ip link set v1 netns N1
sudo ip link set v2 netns N2
sudo ip link set v3 netns N2
sudo ip link set v4 netns N3
sudo ip link set v5 netns N3
sudo ip link set v6 netns N4
sudo ip link set v7 netns N4
sudo ip link set v8 netns N5
sudo ip link set v9 netns N5
sudo ip link set v10 netns N6
sudo ip link set v11 netns N6
sudo ip link set v12 netns N1
echo -e "\nAssigned interfaces to N1,N2,N3,N4,N5 and N6!\n"

echo --------- CONFIGURING INTERFACES -------------------------------------

sudo ip netns exec N1 ip addr add 10.0.10.62/24 dev v1
sudo ip netns exec N2 ip addr add 10.0.10.63/24 dev v2
sudo ip netns exec N2 ip addr add 10.0.20.62/24 dev v3
sudo ip netns exec N3 ip addr add 10.0.20.63/24 dev v4
sudo ip netns exec N3 ip addr add 10.0.30.62/24 dev v5
sudo ip netns exec N4 ip addr add 10.0.30.63/24 dev v6
sudo ip netns exec N4 ip addr add 10.0.40.62/24 dev v7
sudo ip netns exec N5 ip addr add 10.0.40.63/24 dev v8
sudo ip netns exec N5 ip addr add 10.0.50.62/24 dev v9
sudo ip netns exec N6 ip addr add 10.0.50.63/24 dev v10
sudo ip netns exec N6 ip addr add 10.0.60.62/24 dev v11
sudo ip netns exec N1 ip addr add 10.0.60.63/24 dev v12

echo -e "\nList of interfaces at N1"
sudo ip netns exec N1 ip addr list
echo -e "\nList of interfaces at N2"
sudo ip netns exec N2 ip addr list
echo -e "\nList of interfaces at N3"
sudo ip netns exec N3 ip addr list
echo -e "\nList of interfaces at N4"
sudo ip netns exec N4 ip addr list
echo -e "\nList of interfaces at N5"
sudo ip netns exec N5 ip addr list
echo -e "\nList of interfaces at N6"
sudo ip netns exec N6 ip addr list

# echo ---------- SETTING PORTS UP ----------------------------------------------

sudo ip netns exec N1 ip link set v1 up
sudo ip netns exec N2 ip link set v2 up
sudo ip netns exec N2 ip link set v3 up
sudo ip netns exec N3 ip link set v4 up
sudo ip netns exec N3 ip link set v5 up
sudo ip netns exec N4 ip link set v6 up
sudo ip netns exec N4 ip link set v7 up
sudo ip netns exec N5 ip link set v8 up
sudo ip netns exec N5 ip link set v9 up
sudo ip netns exec N6 ip link set v10 up
sudo ip netns exec N6 ip link set v11 up
sudo ip netns exec N1 ip link set v12 up

echo -e "\nAll interfaces are up\n"

echo ---------- ENABLING LOOPBACK INTERFACE AT NAMESPACES ---------------------

sudo ip netns exec N1 ip link set dev lo up
sudo ip netns exec N2 ip link set dev lo up
sudo ip netns exec N3 ip link set dev lo up
sudo ip netns exec N4 ip link set dev lo up
sudo ip netns exec N5 ip link set dev lo up
sudo ip netns exec N6 ip link set dev lo up

echo -e "\nAll loopback interfaces are up\n"

echo ---------- ENABLING IP FORWARDINIG AT THE NAMESPACES --------------------

# Enabling ip forwarding at N1, N2, N3, N4, N5 and N6

sudo ip netns exec N1 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec N2 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec N3 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec N4 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec N5 sysctl -w net.ipv4.ip_forward=1
sudo ip netns exec N6 sysctl -w net.ipv4.ip_forward=1


echo -e "\nEnabling ip forwarding at the namespaces N1, N2, N3, N4, N5 and N6\n"

echo ---------- SETTING UP ROUTE TABLE ----------------------------------------


sudo ip netns exec N1 ip route add 10.0.20.0/24 via 10.0.10.63 dev v1
sudo ip netns exec N1 ip route add 10.0.30.0/24 via 10.0.10.63 dev v1
sudo ip netns exec N1 ip route add 10.0.40.0/24 via 10.0.10.63 dev v1
sudo ip netns exec N1 ip route add 10.0.50.0/24 via 10.0.10.63 dev v1

sudo ip netns exec N2 ip route add 10.0.30.0/24 via 10.0.20.63 dev v3
sudo ip netns exec N2 ip route add 10.0.40.0/24 via 10.0.20.63 dev v3
sudo ip netns exec N2 ip route add 10.0.50.0/24 via 10.0.20.63 dev v3
sudo ip netns exec N2 ip route add 10.0.60.0/24 via 10.0.20.63 dev v3

sudo ip netns exec N3 ip route add 10.0.10.0/24 via 10.0.30.63 dev v5
sudo ip netns exec N3 ip route add 10.0.40.0/24 via 10.0.30.63 dev v5
sudo ip netns exec N3 ip route add 10.0.50.0/24 via 10.0.30.63 dev v5
sudo ip netns exec N3 ip route add 10.0.60.0/24 via 10.0.30.63 dev v5

sudo ip netns exec N4 ip route add 10.0.10.0/24 via 10.0.40.63 dev v7
sudo ip netns exec N4 ip route add 10.0.20.0/24 via 10.0.40.63 dev v7
sudo ip netns exec N4 ip route add 10.0.50.0/24 via 10.0.40.63 dev v7
sudo ip netns exec N4 ip route add 10.0.60.0/24 via 10.0.40.63 dev v7

sudo ip netns exec N5 ip route add 10.0.10.0/24 via 10.0.50.63 dev v9
sudo ip netns exec N5 ip route add 10.0.20.0/24 via 10.0.50.63 dev v9
sudo ip netns exec N5 ip route add 10.0.30.0/24 via 10.0.50.63 dev v9
sudo ip netns exec N5 ip route add 10.0.60.0/24 via 10.0.50.63 dev v9

sudo ip netns exec N6 ip route add 10.0.10.0/24 via 10.0.60.63 dev v11
sudo ip netns exec N6 ip route add 10.0.20.0/24 via 10.0.60.63 dev v11
sudo ip netns exec N6 ip route add 10.0.30.0/24 via 10.0.60.63 dev v11
sudo ip netns exec N6 ip route add 10.0.40.0/24 via 10.0.60.63 dev v11

echo ---------- DISPLAYING ROUTE TABLE -----------------------------------------

echo -e "\nRoute table at N1\n"
sudo ip netns exec N1 ip route 

echo -e "\nRoute table at N2\n"
sudo ip netns exec N2 ip route 

echo -e "\nRoute table at N3\n"
sudo ip netns exec N3 ip route 

echo -e "\nRoute table at N4\n"
sudo ip netns exec N4 ip route

echo -e "\nRoute table at N5\n"
sudo ip netns exec N5 ip route 

echo -e "\nRoute table at N6\n"
sudo ip netns exec N6 ip route  

echo ---------- PERFORMING PING OPERATIONS -------------------------------------

tot_packets=3

# ping from N1
echo -e "\nFrom N1 :\n" 
sudo ip netns exec N1 ping -c $tot_packets 10.0.10.62
sudo ip netns exec N1 ping -c $tot_packets 10.0.10.63
sudo ip netns exec N1 ping -c $tot_packets 10.0.20.62
sudo ip netns exec N1 ping -c $tot_packets 10.0.20.63
sudo ip netns exec N1 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N1 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N1 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N1 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N1 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N1 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N1 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N1 ping -c $tot_packets 10.0.60.63

# # ping from N2
# echo -e "\nFrom N2 :\n" 
# sudo ip netns exec N2 ping -c $tot_packets 10.0.10.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.10.63
# sudo ip netns exec N2 ping -c $tot_packets 10.0.20.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.20.63
# sudo ip netns exec N2 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N2 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N2 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N2 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N2 ping -c $tot_packets 10.0.60.63

# # ping from N3
# echo -e "\nFrom N3 :\n" 
# sudo ip netns exec N3 ping -c $tot_packets 10.0.10.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.10.63
# sudo ip netns exec N3 ping -c $tot_packets 10.0.20.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.20.63
# sudo ip netns exec N3 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N3 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N3 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N3 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N3 ping -c $tot_packets 10.0.60.63

# # ping from N4
# echo -e "\nFrom N4 :\n" 
# sudo ip netns exec N4 ping -c $tot_packets 10.0.10.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.10.63
# sudo ip netns exec N4 ping -c $tot_packets 10.0.20.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.20.63
# sudo ip netns exec N4 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N4 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N4 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N4 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N4 ping -c $tot_packets 10.0.60.63

# # ping from N5
# echo -e "\nFrom N5 :\n" 
# sudo ip netns exec N5 ping -c $tot_packets 10.0.10.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.10.63
# sudo ip netns exec N5 ping -c $tot_packets 10.0.20.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.20.63
# sudo ip netns exec N5 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N5 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N5 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N5 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N5 ping -c $tot_packets 10.0.60.63

# # ping from N6
# echo -e "\nFrom N6 :\n" 
# sudo ip netns exec N6 ping -c $tot_packets 10.0.10.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.10.63
# sudo ip netns exec N6 ping -c $tot_packets 10.0.20.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.20.63
# sudo ip netns exec N6 ping -c $tot_packets 10.0.30.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.30.63
# sudo ip netns exec N6 ping -c $tot_packets 10.0.40.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.40.63
# sudo ip netns exec N6 ping -c $tot_packets 10.0.50.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.50.63
# sudo ip netns exec N6 ping -c $tot_packets 10.0.60.62
# sudo ip netns exec N6 ping -c $tot_packets 10.0.60.63

echo ---------- TRACING ROUTES -------------------------------------------------

echo -e "\nRoute from N1 to N5 : \n"
sudo ip netns exec N1 traceroute 10.0.40.63

echo -e "\nRoute from N3 to N5 : \n"
sudo ip netns exec N3 traceroute 10.0.50.62

echo -e "\nRoute from N3 to N1 : \n"
sudo ip netns exec N3 traceroute 10.0.60.63

echo ---------- TESTING : DELETING ALL NAMESPACES AND INTERFACES ---------------

sudo ip netns del N1
sudo ip netns del N2
sudo ip netns del N3
sudo ip netns del N4
sudo ip netns del N5
sudo ip netns del N6

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


