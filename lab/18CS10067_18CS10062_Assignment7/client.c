// Assignment 7
// 18CS10067, Atharva Naik
// 18CS10062, Radhika Patwari

#include <stdio.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <unistd.h> 
#include <string.h> 
#include <stdlib.h> 
#include <fcntl.h>
#include <stdbool.h>

#define PORT 8080 // port used for file transfer
#define MAX_LEN 100 // max length for buffers
#define BLOCK_SIZE 5 // block size (in bytes)
#define RESPONSE_FILENAME "response.txt" // file name assigned to the response returned by the server


int main(int argc, char const *argv[]) 
{ 
	int sock = 0;
    long int FSIZE; 
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
    ssize_t n = recv(sock, buffer, 1, 0); // just receive one character
    // print same message as server to let the user know if the file was found
    if (strcmp(buffer, "E") == 0) {
        printf("\x1b[31;1mFile '%s' Not Found\x1b[0m\n", fname);
        exit(EXIT_FAILURE);
    }
    else if (strcmp(buffer, "L") == 0) {
        n = recv(sock, buffer, MAX_LEN, 0);
        sscanf(buffer, "%ld", &FSIZE);
        printf("\x1b[32;1mFile '%s' Found, file_size=%ld\x1b[0m\n", fname, FSIZE);
    }
    else {
        printf("\x1b[33;1m%s: unrecognized response\x1b[0m\n", buffer);
        exit(EXIT_FAILURE);
    }
    remove(RESPONSE_FILENAME); // remove file if it already exists, (otherwise file simply gets written over and not replaced)
    int resp_fd = open(RESPONSE_FILENAME, O_RDWR | O_CREAT, 0777); // open a file to write the response to
    long int EXP_BLOCKS = FSIZE / BLOCK_SIZE; // number of blocks client expects to receive
    int LAST_BLOCK_SIZE = FSIZE % BLOCK_SIZE; // size of the last block to be received
    char file_buffer[BLOCK_SIZE]; // buffer to store received file segments in
    // loop to receive blocks of file
    for (long int i = 0; i < EXP_BLOCKS; i++) {
        n = recv(sock, file_buffer, BLOCK_SIZE, MSG_WAITALL);
        write(resp_fd, file_buffer, BLOCK_SIZE);
        memset(file_buffer, 0, BLOCK_SIZE);
    }
    n = recv(sock, file_buffer, LAST_BLOCK_SIZE, MSG_WAITALL);
    write(resp_fd, file_buffer, LAST_BLOCK_SIZE);
    memset(file_buffer, 0, BLOCK_SIZE);
    
    if (LAST_BLOCK_SIZE != 0)
        EXP_BLOCKS++;
       
    printf("The file transfer is successful. Total number of blocks received = %ld, Last block size = %d\n", EXP_BLOCKS, LAST_BLOCK_SIZE);

    return 0; 
} 
