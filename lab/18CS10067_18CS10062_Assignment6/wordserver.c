// Server side C/C++ program to demonstrate Socket programming 
#include <unistd.h> 
#include <stdio.h> 
#include <sys/socket.h> 
#include <stdlib.h> 
#include <netinet/in.h> 
#include <string.h> 
#include <fcntl.h>

#define PORT 8080 
#define MAX_LEN 100
#define CHUNK_SIZE 5 // chunk size in bytes read
#define RESPONSE_NAME "test_response.txt"

int main(int argc, char const *argv[]) 
{ 
	int server_fd, new_socket, valread; 
	struct sockaddr_in address; 
	int opt = 1; 
	int addrlen = sizeof(address); 
	char buffer[1024] = {0}; 
	// Creating socket file descriptor 
	if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) 
	{ 
		perror("socket failed"); 
		exit(EXIT_FAILURE); 
	} 
	// Forcefully attaching socket to the port 8080 
	if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) 
	{ 
		perror("setsockopt"); 
		exit(EXIT_FAILURE); 
	} 
	address.sin_family = AF_INET; 
	address.sin_addr.s_addr = INADDR_ANY; 
	address.sin_port = htons( PORT ); 
	// Forcefully attaching socket to the port 8080 
	if (bind(server_fd, (struct sockaddr *)&address, sizeof(address))<0) 
	{ 
		perror("bind failed"); 
		exit(EXIT_FAILURE); 
	} 
	// listen to socket file descriptor (server_fd)
	if (listen(server_fd, 3) < 0) 
	{ 
		perror("listen"); 
		exit(EXIT_FAILURE); 
	}
	printf("\x1b[44mTCP server started. Close with Ctrl+C.\x1b[0m\n");
    // loop to service multiple clients 
	while(1) {
		// open new socket to service the client
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen))<0) 
        { 
            perror("accept"); 
            exit(EXIT_FAILURE); 
        }
		memset(buffer, 0, MAX_LEN); 
        valread = read(new_socket, buffer, MAX_LEN); 
        printf("\x1b[33mREQUEST RECEIVED FOR FILE: %s\x1b[0m\n", buffer); 
        // try to open requested file
        int req_fd = open(buffer, O_RDONLY);
        // file descriptor is -1 if file doesn't exist
		if (req_fd < 0)
        {	// print error if file doesn't exist
            printf("\x1b[31mERR 01: File '%s' Not Found\x1b[0m\n", buffer);
            close(new_socket); // close connection with client
			continue; // jump to next iteration of loop
		}
        char file_buffer[MAX_LEN]; // buffer to read from the requested file
        // read file into the file buffer (CHUNK_SIZE number of bytes)
        int i = read(req_fd, file_buffer, CHUNK_SIZE);
		send(new_socket, "1", strlen("1"), 0); // to distinguish empty file
        while(i != 0) { // while file buffer is non empty, the EOF hasn't been reached
            file_buffer[i] = '\0'; // once EOF is reached, read will return 0 (no new characters/bytes read)
            send(new_socket, file_buffer, strlen(file_buffer), 0);
            memset(file_buffer, 0, MAX_LEN); // reset/clear file buffer, to read next chunk
            i = read(req_fd, file_buffer, CHUNK_SIZE); 
        }
		// close connection to client once file transfer is over
        close(new_socket);
    }

	return 0; 
} 