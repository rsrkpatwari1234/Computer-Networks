// Assignment6
// 18CS10067, Atharva Naik
// 18CS10062, Radhika Patwari

// Client side C program to demonstrate Socket programming 
#include <stdio.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <unistd.h> 
#include <string.h> 
#include <stdlib.h> 
#include <fcntl.h>

#define PORT 8080 // port used for file transfer
#define MAX_LEN 100 // max length for buffers
#define RESPONSE_FILENAME "response.txt" // file name assigned to the response returned by the server

//counting the number of words in the file
// s : current data send by server
// end_of_delimiter : keeping track of words which are broken due to chunk limit
// in server and then sent
int count_words(char *s, int *end_with_delimiter){

	// ctr : keeping count of words
	// i : looping over the input
	// t : keeping track of characters other than delimiters
	int ctr = 0,i = 0,t=0;	

	//looping till end of input string
	while(s[i]!='\0'){	

		// using delimiters to break input into words
		if(s[i]==',' || s[i]==';' || s[i]==':' || s[i]=='.' || s[i]=='\n' || s[i]=='\t' || s[i]=='\r' || s[i]==' '){	
			if(!(!(*end_with_delimiter) && t))
				ctr+=t;
			t=0;						
			*end_with_delimiter = 1;
		}
		else
			t=1;
		i++;
	}

	if(!(!(*end_with_delimiter) && t))
		ctr+=t;
	*end_with_delimiter = !t;       //keeping track of inputs ending with delimiter
	return ctr;						//sending the # of words in current input
}

int main(int argc, char const *argv[]) 
{ 
	int sock = 0; 
	struct sockaddr_in serv_addr; 
	char buffer[MAX_LEN] = {0}; // buffer for receiving messages

    // error in socket creation
	if ((sock = socket(AF_INET, SOCK_STREAM, 0)) < 0) 
	{ 
		printf("\n Socket creation error \n"); 
		return -1; 
	} 
    // assign port to server address
	serv_addr.sin_family = AF_INET; 
	serv_addr.sin_port = htons(PORT); 
	
	// Convert IPv4 and IPv6 addresses from text to binary form 
	if(inet_pton(AF_INET, "127.0.0.1", &serv_addr.sin_addr)<=0) 
	{ 
		printf("\nInvalid address/ Address not supported \n"); 
		return -1; 
	} 
    // connect to client
	if (connect(sock, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) 
	{ 
		printf("\nConnection Failed \n"); 
		return -1; 
	} 
    // take filename from user
    char fname[MAX_LEN];
    printf("Enter filename: ");
    scanf("%[^\n]s", fname); // read string (along with whitespaces), upto the first newline
    send(sock , fname, strlen(fname), 0); // send filename to server
    int n = read(sock, buffer, MAX_LEN); // trial read (to check if the server has sent bytes. If file doesn't exist or is empty, 0 bytes will be read)
    
    // check if buffer is empty
    if (strlen(buffer) == 0)
    {   // show error message if no bytes are read (File Not Found or file is empty)
        printf("\x1b[31mERR 01: File Not Found\x1b[0m\n"); 
        exit(EXIT_FAILURE); // exit client program if file not found
    }
    // the below to lines remove the indicator "1" (helps to differentiate between empty file and file not found)
    // we use it as \0 is already present in socket stream so it can't be used to differentiate between the two cases
    memmove(buffer, buffer+1, strlen(buffer));
    n--;

    int tot_bytes = 0, tot_words = 0; // variables to store total number of bytes and words read
    int end_with_delimiter = 1; 
    // open file to store response from the server
    remove(RESPONSE_FILENAME); // this is to remove the response file if it exists, reason: otherwise the new respnse is 
    int resp_fd = open(RESPONSE_FILENAME, O_RDWR | O_CREAT, 0777); // file is readable, writable and executable. 
    // New file is created every time. All users have permissions to read, write and execute it
    if (resp_fd < 0) 
    {   // file descriptor is negative if file can't be created
        printf("Failed to create response file\n"); 
        exit(EXIT_FAILURE);
    }
    // update total number of bytes and words read till now (the running count)
    tot_bytes += write(resp_fd, buffer, strlen(buffer));
    tot_words += count_words((char *)buffer, &end_with_delimiter);
    // read from the socket opened by the server
    n = read(sock, buffer, MAX_LEN);
    while (n != 0) { // keep reading from the socket while more bytes can be read
        // update running counts for bytes/words read
        tot_bytes += write(resp_fd, buffer, strlen(buffer));
        tot_words += count_words((char *)buffer, &end_with_delimiter);
        // clear buffer
        memset(buffer, 0, MAX_LEN);
        n = read(sock, buffer, MAX_LEN);
    }
    // print statistics (total number of bytes and words read)
    printf("The file transfer is successful. Size of the file = %d bytes, no. of words = %d\n", tot_bytes, tot_words);

    return 0; 
} 