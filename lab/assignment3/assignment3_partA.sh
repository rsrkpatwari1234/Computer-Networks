
# NAME : RADHIKA PATWARI
# ROLL NO. : 18CS10062
# PART A

# ===========================================================================

# I am working with 'sudo' for authentication ; please feel free to remove it 
# if you are already running as 'root' user in your system

echo -------- CREATING AND LISTING NETWORK NAMESPACES --------------------
# Creating a network namespace with name 'namespace_0'
sudo ip netns add namespace_0

# To verify namespace_0 is created , print all the namespaces present in the system
echo -e "\nList of namespaces present currently"
ip netns list

echo -e "\nnamespace_0 successfully created!\n"

# Creating another network namespace with name 'namespace_1'
sudo ip netns add namespace_1

# To verify namespace_1 is created , print all the namespaces present in the system
echo -e "\nList of namespaces present currently"
ip netns list

echo -e "\nnamespace_1 successfully created!\n"

echo -------- CREATING VIRTUAL ETHERNET INTERFACES -----------------------
# Creating 2 virtual ethernet (veth) interfaces 'Veth0' and  'Veth1' and linking them together
sudo ip link add Veth0 type veth peer name Veth1

# To verify that the veth pair is created by listing all existing network links
echo -e "\nList of veth pairs present currently\n"
ip link list

echo -e "\n--------- ASSIGNING VETH INTERFACES TO NAMESPACES -------------------"
# Moving virtual ethernet interface 'Veth0' to namespace 'namespace_0'
sudo ip link set Veth0 netns namespace_0

# To verify that Veth0 is successfully moved to namespace 'namespace_0'
echo -e "\nList of interfaces at namespace_0"
sudo ip netns exec namespace_0 ip link list
echo -e "\nSuccessfully moved Veth0 to namespace_0\n" 

# Moving virtual ethernet interface 'Veth1' to namespace 'namespace_1'
sudo ip link set Veth1 netns namespace_1

# To verify that Veth1 is successfully moved to namespace 'namespace_1'
echo -e "\nList of interfaces at namespace_1"
sudo ip netns exec namespace_1 ip link list
echo -e "\nSuccessfully moved Veth1 to namespace_1\n" 

echo --------- CONFIGURING INTERFACES -------------------------------------
# Configuring Veth0 interface of namespace 'namespace_0' with ip 10.1.1.0/24
sudo ip netns exec namespace_0 ip addr add 10.1.1.0/24 dev Veth0

# To verify that Veth0 is successfully configured by listing links of 'namespace_0'
echo -e "\nList of interfaces at namespace_0"
sudo ip netns exec namespace_0 ip addr list
echo -e "\nSuccessfully configured Veth0 of namespace_0\n"

# Configuring Veth1 interface of namespace 'namespace_1' with ip 10.1.2.0/24
sudo ip netns exec namespace_1 ip addr add 10.1.2.0/24 dev Veth1

# To verify that Veth0 is successfully configured by listing links of 'namespace_1'
echo -e "\nList of interfaces at namespace_1"
sudo ip netns exec namespace_1 ip addr list
echo -e "\nSuccessfully configured Veth1 of namespace_1\n"

echo ---------- FOR TESTING [PINGING AND DELETING OPERATIONS] -------------------
# Please comment if not required

# Bringing the two interfaces up
sudo ip netns exec namespace_0 ip link set Veth0 up
sudo ip netns exec namespace_1 ip link set Veth1 up

# Configuring all external traffic at namespace_0 to pass through Veth0
sudo ip netns exec namespace_0 ip route add default via 10.1.1.0 dev Veth0

# Configuring all external traffic at namespace_1 to pass through Veth1
sudo ip netns exec namespace_1 ip route add default via 10.1.2.0 dev Veth1

# checking routes at the two namespaces
sudo ip netns exec namespace_0 ip route show
sudo ip netns exec namespace_1 ip route show

# Pinging Veth1 from namespace_0 and vice-versa
sudo ip netns exec namespace_0 ping -c 1 10.1.2.0
sudo ip netns exec namespace_1 ping -c 1 10.1.1.0

# To delete the namespaces  [for testing]
sudo ip netns del namespace_0
sudo ip netns del namespace_1
sudo ip link del Veth0 type veth peer name Veth1
echo "Check deletion ....."
ip netns list
echo -e "\nSuccesfully deleted the namespaces along with virtual ethernet interfaces\n"


