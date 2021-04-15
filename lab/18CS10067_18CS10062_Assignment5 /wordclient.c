// Assignment1
// 18CS10067, Atharva Naik
// 18CS10062, Radhika Patwari

#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 
  
#define END "END" // end is the predefined end of file indicator
#define PORT 8080  
#define HELLO "HELLO" // hello is the predefined start of file indicator
#define MAXLINE 1024 // maximum messsage length
#define WORDSIZE 100 // maximum word size for words read from the file
#define REQUEST_FILE "test.txt" // name of file to be requested
#define RESPONSE_FILE "test-response.txt" // name of file to be requested
#define FILE_NOT_FOUND "FILE_NOT_FOUND" // error to be returned when file doesn't exist
#define WRONG_FILE_FORMAT "WRONG_FILE_FORMAT" // error to be returned when file format is wrong
#define WRONG_MESSAGE_FORMAT "WRONG_MESSAGE_FORMAT" // error to be returned when message request differs from WORDi, while reading file#define WRONG_MESSAGE_FORMAT "WRONG_MESSAGE_FORMAT" // error to be returned when message request differs from WORDi, while reading file

/* The client doesn't save HELLO and END in the response file,
which is by choice. Also we are saving each word read on a new
line. This means that the response file isn't an exact copy */

int main() { 
    int socket_fd; 
    char buffer[MAXLINE]; // character buffer to store recieved messages
    char request[MAXLINE] = REQUEST_FILE;
    struct sockaddr_in servaddr; 
  
    // Creating the socket file descriptor 
    if ((socket_fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) 
    { 
        perror("Failed to create socket"); 
        exit(EXIT_FAILURE); 
    } 
  
    memset(&servaddr, 0, sizeof(servaddr)); 
      
    // Filling server information 
    servaddr.sin_family = AF_INET; 
    servaddr.sin_port = htons(PORT); 
    servaddr.sin_addr.s_addr = INADDR_ANY; 
      
    int n;
    socklen_t len;

    // send request for a file (the filename)  
    sendto(socket_fd, (const char *)REQUEST_FILE, strlen(REQUEST_FILE), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
    n = recvfrom(socket_fd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *) &servaddr, &len); 
    buffer[n] = '\0'; 

    // check if a FILE_NOT_FOUND error is returned by server
    if (strcmp(buffer, FILE_NOT_FOUND) == 0)
    {
        printf("\x1b[31mFile Not Found\x1b[0m\n"); 
        exit(EXIT_FAILURE);
    }
    // check if HELLO message is returned by server
    else if (strcmp(buffer, HELLO) == 0)
    {   
        // create a new file
        FILE* fptr = fopen(RESPONSE_FILE, "w");
        int i = 1;
        char i_str[10];
        // infinite loop (termminates if end message is received from server)
        while (1)
        {
            // convert integer i to string, and store in i_str
            sprintf(i_str, "%d", i);
            // clear request
            memset(request, 0, strlen(request));
            // generate request for WORDi
            strcat(request, "WORD");
            strcat(request, i_str);
            // send request for next word
            sendto(socket_fd, (const char *)request, strlen(request), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
            memset(buffer,0,strlen(buffer));
            n = recvfrom(socket_fd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *) &servaddr, &len); 
            buffer[n] ='\0';
            // check if END messages is received from server
            if (strcmp(buffer, END) == 0)
                break;
            // check if wrong message format error is sent by server
            else if (strcmp(buffer, WRONG_MESSAGE_FORMAT) == 0)
            {
                printf("\x1b[31mWrong Message Format\x1b[0m\n");
                break;
            }
            else 
            {   // write word to client file
                if (strlen(buffer)>0)
                {
                    fputs(buffer, fptr);
                    // add newline
                    fputs("\n", fptr);
                }
            }
            i++;
        }
        fclose(fptr);
    }
    

    else if (strcmp(buffer, WRONG_FILE_FORMAT) == 0)
    {
        printf("\x1b[31mWrong File Format\x1b[0m\n"); 
        exit(EXIT_FAILURE);
    }
    // close socket
    close(socket_fd); 
    return 0; 
} 