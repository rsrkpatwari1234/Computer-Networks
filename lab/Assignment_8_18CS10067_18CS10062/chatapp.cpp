#include <ctime>
#include "utils.h"
#include <chrono>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <dirent.h> 
#include <stdlib.h> 
#include <unistd.h>
#include <sys/wait.h>
#include <sys/stat.h> 
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/in.h> 
#include <bits/stdc++.h>

#define MAX_MSG_LEN 10000 // maximum characters allowed in the message.
#define MAX_USERS 5 //this is the maximum number of peers allowed.
#define DEBUG false // set this flag to true for verbose output, for debugging purposes.
#define STDIN 0 // file descriptor for standard input. 

const int TIMEOUT_VAL = 30; // timeout of 30 seconds is used to disconnect the connection between the peers

using namespace std;

/* read user_info */
vector<vector<string>> read_user_info(string fname) {
    string row;
    ifstream fin(fname);
    vector<vector<string>> user_info;    

    #if DEBUG
        cout << "\x1b[32;1m Inside the read_user_info function \x1b[0m" << endl;
    #endif

    while ( getline(fin, row) ) {
        #if DEBUG
            cout << "row:" << row << endl;
        #endif 
        user_info.push_back(tokenize(row,','));
    }
    
    return user_info;
}

/* find row index using any unique column value as a key. In case of a non-unique 
key value first occurrence is returned. -1 is returned in case no record is matched.*/
int get_record(vector<vector<string>> table, string key, int col) {
    int ind = 0;
    for ( vector<string> row: table ) {
        if ( row[col] == key )
            break;
        else
            ind++;
    }
    if ( ind == table.size() ) ind = -1;

    #if DEBUG 
        cout << "\x1b[32;1m Inside the get_record function \x1b[0m" << endl;
        cout << "index=" << ind << endl;
    #endif

    return ind;
}

int main(int argc, char* argv[]) {

    // the user needs to supply the port number, i.e. is at least one argument.
    assert(argc > 1); 

    #if DEBUG
        cout << "argument_count=" << argc << endl;
    #endif

    vector<vector<string>> user_info;
    struct sockaddr_in server_addr, client_addr;
    struct sockaddr_in user_addr[MAX_USERS];            // addresses of all the peers
    int client_fd[MAX_USERS];                           // client side file descriptors

    /* The user_info table is read from a csv file. The name 
    of the file can be optionally a terminal argument. 
    The columns are: Name, IP, Port. */
    if ( argc > 2 )
        user_info = read_user_info(string(argv[2]));
    else 
        user_info = read_user_info(string("user_info.csv"));

    print_table(user_info, {"USERNAME", "IP", "PORT"}); 

    // maintaining current user
    int CURR_USER=0;

    //finding current user
    for(int i=0;i<MAX_USERS;i++)
    {   
        //cout<<argv[1]<<" "<<user_info[i][2]<<endl;
        if(strcmp(&user_info[i][2][0],argv[1])==0)
        {
            CURR_USER = i;
            break;
        }
    }

    for ( int i = 0; i < MAX_USERS; i++ ) {
        user_addr[i].sin_family = AF_INET; // indicates IPv4 scheme.
        #if DEBUG
            cout << user_info[i][2] << endl;
        #endif 
        user_addr[i].sin_port = htons(stoi(user_info[i][2])); // get column "Port" for each row.
        // note the table stores port and IP addresses as strings so convert them to integers first.
    }

    // setting server address
    server_addr.sin_family = AF_INET;
	server_addr.sin_port = htons(atoi(argv[1]));
	server_addr.sin_addr.s_addr = INADDR_ANY;

    // finding socket
    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
	if ( server_fd < 0){
		printf("\x1b[31;1msocket creation failed!\x1b[0m\n");
        exit(EXIT_FAILURE);
    }

    // using SO_REUSEPORT to make the listening and sending port same for all peers
    int optval1 = 1, optval2 = 1;
    setsockopt(server_fd, SOL_SOCKET, SO_REUSEPORT, &optval1, sizeof(optval1));

	// bind socket to server address
	if ( bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr)) < 0 ){
		close(server_fd);
		perror("\x1b[31;1mfailed to bind to socket!\x1b[0m\n");
	}

	listen(server_fd, MAX_USERS); 			// listen to at max MAX_SIZE connections

	printf("\x1b[33;1mchat-app started ....\x1b[0m\n");

    int ind = get_record(user_info, string(argv[1]), 2);
    #if DEBUG
        cout << "port " << argv[1] << " was assigned to " << user_info[ind][0] << endl;
    #endif 	

    fd_set fd_read;
    FD_ZERO(&fd_read); 

    struct hostent *host = gethostbyname(user_info[ind][1].c_str()); // supply ip field of the fetched user record.
	
    for ( int i = 0; i < MAX_USERS; i++ ) {
		client_fd[i] = -1;
		user_addr[i].sin_family = AF_INET;
		bcopy((char *)host->h_addr, (char *)&user_addr[i].sin_addr.s_addr, host->h_length);
	}

    int num_conn = 0;                // maintain a running count of connections.
    int max_fd = 0;                  // store value of the max fd
    char raw_msg[MAX_MSG_LEN];       // message to be transmitted
    time_t last_message[MAX_USERS];  // last observed message time

    while (1) {

        #if DEBUG
            cout << "\x1b[33minside while loop\x1b[0m" << endl;
        #endif

        FD_ZERO(&fd_read);
        time_t curr_time = time(NULL); 

        //close connections that have already timed out
        for(int i=0;i<MAX_USERS;i++)
        {
            //cout<<i<<" "<<curr_time<<" "<<last_message[i]<<endl;
            if(client_fd[i]!=-1 && curr_time-last_message[i]>TIMEOUT_VAL)
            {
                cout<<"Closing connection with: "<<user_info[i][0]<<endl;
                close(client_fd[i]);
                client_fd[i]=-1;
            }
        }

        FD_SET(STDIN, &fd_read);
        FD_SET(server_fd, &fd_read);
        max_fd = server_fd;

        for ( int i = 0; i < MAX_USERS; i++ ) {
            FD_SET(client_fd[i], &fd_read);
            max_fd = max(max_fd, client_fd[i]);
        } 

        max_fd++; // highest file descriptor value.
        
        #if DEBUG
            cout << "max_fd=" << max_fd << endl;
            for ( int i = 0; i < MAX_USERS; i++ ) {
                cout << "client_fd[" << i << "]=" << client_fd[i] << endl; 
                //cout << "client_read_fd[" << i << "]=" << client_read_fd[i] << endl; 
            }
        #endif

        if ( select(max_fd, &fd_read, NULL, NULL, NULL) <= 0 ) {
            perror("\x1b[31;1merror in select syscall!\x1b[0m\n");
            exit(EXIT_FAILURE);
        }

        if ( FD_ISSET(STDIN, &fd_read) ) {

            for ( int i = 0; i < MAX_MSG_LEN; i++ ) 
                raw_msg[i] = '\0';

            string msg, send_to;

            int raw_msg_len = read(STDIN, raw_msg, MAX_MSG_LEN);
            if ( strcmp(raw_msg, "exit") == 0 ) // exit when "exit" is typed in input.
                exit(EXIT_SUCCESS);

            #if DEBUG
                cout << "raw message: " << "\x1b[31m" << raw_msg << "\x1b[0m" << endl;
                cout << "raw message length: " << "\x1b[31m" << raw_msg_len << "\x1b[0m" << endl;
            #endif 

            tokenize_prefix(string(raw_msg), '/', send_to, msg);

            #if DEBUG 
                cout << "sending message to " << "\x1b[33;1m" << send_to << "\x1b[0m" << endl;
            #endif 
            
            ind = get_record(user_info, send_to, 0);
            if ( ind < 0 )
                exit(EXIT_FAILURE);

            if ( client_fd[ind] < 0 ) {

				#if DEBUG
                    cout << "client_fd[" << ind << "]=" << client_fd[ind] << endl;
                #endif

                client_fd[ind] = socket(AF_INET, SOCK_STREAM, 0);
                last_message[ind] = time(NULL);
                if ( client_fd[ind] < 0 ) {
			        printf("\x1b[31;1merror in opening socket\x1b[0m\n");
                    exit(EXIT_FAILURE);
                }

                setsockopt(client_fd[ind], SOL_SOCKET, SO_REUSEPORT, &optval1, sizeof(optval1));

                int temp = bind( client_fd[ind], (struct sockaddr *)&user_addr[CURR_USER], sizeof(server_addr));
                if(temp<0){
                    printf("\x1b[31;1mUnable to find to the port\x1b[0m\n");
                    exit(EXIT_FAILURE);
                }

                if ( connect(client_fd[ind], (struct sockaddr *)&user_addr[ind], sizeof(user_addr[ind])) < 0 ) {
			        printf("\x1b[31;1merror in connection\x1b[0m\n");
                    exit(EXIT_FAILURE);
                }
            }

            //set time when last message was sent
            last_message[ind] = time(NULL);

            // writing to terminal
			int err = write(client_fd[ind], msg.c_str(), strlen(msg.c_str()));
    		if ( err < 0 ) {	        
                printf("\x1b[31;1merror in opening socket\x1b[0m\n");
                exit(EXIT_FAILURE);
            }
        }

        if( FD_ISSET(server_fd, &fd_read) )
		{
            int len_client_addr = sizeof(client_addr);
			int sender_fd = accept(server_fd, (struct sockaddr *)&client_addr, (socklen_t*)&len_client_addr);
			
            if( sender_fd == -1 )		
				printf("\x1b[31;1mcouldn't accept connection!\x1b[0m");

			char ip_[100];
            inet_ntop(AF_INET, &(client_addr.sin_addr), ip_, 100);

            int tem = 0;
            while(tem<MAX_USERS)
            {
                if(to_string(ntohs(client_addr.sin_port))==user_info[tem][2]&&strcmp(ip_,&user_info[tem][1][0])==0)
                {
                    break;
                }
                tem++;
            }

            last_message[tem] = time(NULL);
            client_fd[tem] = sender_fd;

            printf("\x1b[32;1mConnection accepted from %s\x1b[0m\n",&user_info[tem][0][0]);
		}

        // iterate over already establised connecitons.
		for( int i = 0; i < MAX_USERS; i++ )
		{ 
            if(client_fd[i]==-1)
                continue;

			if(FD_ISSET(client_fd[i], &fd_read))
			{
				char buffer[MAX_MSG_LEN];
                for ( int i = 0; i < MAX_MSG_LEN; i++ ) 
                    buffer[i] = '\0';

				int raw_msg_len = read( client_fd[i], buffer, sizeof(buffer));	
				if( raw_msg_len < 0 )
                	perror("\x1b[31;1merror: Reading failed from browser\x1b[0m\n");
				
                auto end = chrono::system_clock::now(); // get current timestamp.std::time_t end_time = std::chrono::system_clock::to_time_t(end);
                time_t end_time = chrono::system_clock::to_time_t(end);
                string timestamp = string(ctime(&end_time));
                timestamp.erase(remove(timestamp.begin(), timestamp.end(), '\n'), timestamp.end());

                last_message[i] = time(NULL);

                if ( raw_msg_len > 0 ){
                    cout << "\x1b[44;1mNEW MESSAGE RECEIVED FROM "<< user_info[i][0] <<" \x1b[0m (" << timestamp << "): " << buffer;
                }

			}
		}
    }

    return 0;
}