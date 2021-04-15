// Assignment1
// 18CS10067, Atharva Naik
// 18CS10062, Radhika Patwari

/* We are running the server in an infinite loop */

#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 

#define END "END" // end is the predefined end of file indicator
#define PORT 8080 // port used for UDP
#define HELLO "HELLO" // hello is the predefined start of file indicator
#define MAXLINE 1024 // maximum messsage length
#define WORDSIZE 100 // maximum word size for words read from the file
#define FILE_NOT_FOUND "FILE_NOT_FOUND" // error to be returned when file doesn't exist
#define WRONG_FILE_FORMAT "WRONG_FILE_FORMAT" // error to be returned when file format is wrong
#define WRONG_MESSAGE_FORMAT "WRONG_MESSAGE_FORMAT" // error to be returned when message request differs from WORDi, while reading file

int main() { 
    int socket_fd; // file descriptor for socket
    char buffer[MAXLINE]; // character buffer to store recieved messages
    // char *hello = "Hello from server"; 
    struct sockaddr_in servaddr, cliaddr; 
      
    // Creating the socket file descriptor 
    if ((socket_fd = socket(AF_INET, SOCK_DGRAM, 0)) < 0) 
    { 
        perror("Failed to create socket"); 
        exit(EXIT_FAILURE); 
    } 
      
    memset(&servaddr, 0, sizeof(servaddr)); 
    memset(&cliaddr, 0, sizeof(cliaddr)); 
      
    // Filling server information 
    servaddr.sin_family = AF_INET; // IPv4 
    servaddr.sin_addr.s_addr = INADDR_ANY; 
    servaddr.sin_port = htons(PORT); 
      
    // Bind the socket with the server address 
    if (bind(socket_fd, (const struct sockaddr *)&servaddr, sizeof(servaddr)) < 0) 
    { 
        perror("Failed to bind socket with server address"); 
        exit(EXIT_FAILURE); 
    } 
      
    int n;
    socklen_t len;

    len = sizeof(cliaddr); 
    printf("\x1b[44m server has been started! Ctrl+C to break\x1b[0m\n"); // to indicate server has been started

    while(1) {
        // receive message from client
        n = recvfrom(socket_fd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *)&cliaddr, &len); 
        buffer[n] = '\0';
        // store the name of the file received from client as fname
        char* fname = buffer;
        FILE* fptr = fopen(fname, "r");

        printf("\x1b[33mREQUEST RECEIVED FOR FILE: %s\x1b[0m\n", fname);
        char word[WORDSIZE]; // character buffer to store words in the file
        // file pointer will be null if file doesn't exist
        if (fptr == NULL)
        { 
            sendto(socket_fd, FILE_NOT_FOUND, strlen(FILE_NOT_FOUND), MSG_CONFIRM, (const struct sockaddr *)&cliaddr, len); 
            exit(EXIT_FAILURE);
        }

        fscanf(fptr, "%s", word);
        if (strcmp(HELLO, word) == 0) // check if the first word of the requested file is hello
        {
            char expected[WORDSIZE];
            // send hello message to client (the file exists and is in the right format)
            sendto(socket_fd, HELLO, strlen(HELLO), MSG_CONFIRM, (const struct sockaddr *)&cliaddr, len); 
            int i = 1;
                
            while (fscanf(fptr, "%s", word) != EOF)
            {
                char i_str[10];            
                sprintf(i_str, "%d", i);
                // clear expected
                memset(expected, 0, strlen(expected));
                // generate WORDi
                strcat(expected, "WORD");
                strcat(expected, i_str);
                // clear buffer
                memset(buffer,0,strlen(buffer));
                n = recvfrom(socket_fd, (char *)buffer, MAXLINE, MSG_WAITALL, (struct sockaddr *) &servaddr, &len); 
                buffer[n] ='\0';
                // check if message is of the form WORDi, with the correct value of i
                if (strcmp(buffer, expected) == 0)
                    sendto(socket_fd, (const char *)word, strlen(word), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
                else 
                {   // message sent when request is not of the form WORDi
                    sendto(socket_fd, (const char *)WRONG_MESSAGE_FORMAT, strlen(WRONG_MESSAGE_FORMAT), MSG_CONFIRM, (const struct sockaddr *) &servaddr, sizeof(servaddr)); 
                    break;
                }
                i++;
            }
            fclose(fptr);
        }
        else // in case the file doesn't start with a hello
        {  
            printf("\x1b[31mWrong file format\x1b[0m\n");
            sendto(socket_fd, WRONG_FILE_FORMAT, strlen(WRONG_FILE_FORMAT), MSG_CONFIRM, (const struct sockaddr *)&cliaddr, len); // send message indicating that the file format is wrong
            exit(EXIT_FAILURE);
        }
    }
    return 0; 
} 