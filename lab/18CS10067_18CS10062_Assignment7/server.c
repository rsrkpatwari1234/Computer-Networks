// Assignment 7
// 18CS10067, Atharva Naik
// 18CS10062, Radhika Patwari

#include <unistd.h> 
#include <stdio.h> 
#include <sys/socket.h> 
#include <sys/stat.h> 
#include <stdlib.h> 
#include <netinet/in.h> 
#include <string.h> 
#include <fcntl.h>

#define PORT 8080 
#define MAX_LEN 100
#define BLOCK_SIZE 5 // block size (in bytes)


int main(int argc, char const *argv[]) 
{ 
	int server_fd, new_socket;
	struct sockaddr_in address; 
	int opt = 1; 
	int addrlen = sizeof(address); 
	char buffer[MAX_LEN] = {0}; 
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
	address.sin_port = htons(PORT); 
	// Forcefully attaching socket to the port 8080 
	if (bind(server_fd, (struct sockaddr *)&address, sizeof(address)) < 0) 
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
	printf("\x1b[44;1mTCP server started. Close with Ctrl+C.\x1b[0m\n");
    // loop to service multiple clients 
	while(1) {
		// open new socket to service the client
        if ((new_socket = accept(server_fd, (struct sockaddr *)&address, (socklen_t*)&addrlen)) < 0) 
        { 
            perror("accept"); 
            exit(EXIT_FAILURE); 
        } 
        ssize_t n = recv(new_socket, buffer, MAX_LEN, 0); 
        printf("\x1b[33mREQUEST RECEIVED FOR FILE: %s\x1b[0m\n", buffer); 
        // try to open requested file
        int req_fd = open(buffer, O_RDONLY);
        // file descriptor is -1 if file doesn't exist
		if (req_fd < 0) {	
            memset(buffer, 0, MAX_LEN); // clear buffer to avoid overwriting
            // print error and send "E" as error message if file doesn't exist
            printf("\x1b[31;1mFile '%s' Not Found\x1b[0m\n", buffer);
            send(new_socket, "E", strlen("E"), 0);
            close(new_socket); // close connection with client
            continue;
        }
        else {
            // get size of file
            struct stat file_size_buf;
            fstat(req_fd, &file_size_buf);
            off_t FSIZE = file_size_buf.st_size;    
            // print file found and send "L" to indicate that the file was found
            printf("\x1b[32;1mFile '%s' Found, file_size=%ld\x1b[0m\n", buffer, FSIZE);
            //send L signal
            send(new_socket, "L", strlen("L"), 0);
            // send file size
            snprintf(buffer, MAX_LEN, "%ld", FSIZE);
            send(new_socket, buffer, MAX_LEN, 0);
            memset(buffer, 0, MAX_LEN); // clear buffer to avoid overwriting

            long int EXP_BLOCKS = FSIZE / BLOCK_SIZE; // number of blocks client expects to receive
            int LAST_BLOCK_SIZE = FSIZE % BLOCK_SIZE; // size of the last block to be received
            char file_buffer[BLOCK_SIZE]; // buffer for reading file
            // for loop to read file in blocks
            for (int i = 0; i < EXP_BLOCKS; i++) {
                ssize_t bytes = read(req_fd, file_buffer, BLOCK_SIZE);
                send(new_socket, file_buffer, BLOCK_SIZE, 0);
                memset(file_buffer, 0, BLOCK_SIZE);
            }
            ssize_t bytes = read(req_fd, file_buffer, LAST_BLOCK_SIZE);
            send(new_socket, file_buffer, LAST_BLOCK_SIZE, 0);
            memset(file_buffer, 0, BLOCK_SIZE);
        }
        close(new_socket);
    }

	return 0; 
} 