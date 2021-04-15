#ifndef UTILS_H
#define UTILS_H

#include <bits/stdc++.h>

#define DEBUG false // set this flag to true for verbose output, for debugging purposes.

using namespace std;

// tokenize input in to output vector out, with delim as the delimiter.
vector<string> tokenize(string &in, char delim) {
    size_t start = 0;
    size_t end = 0;
    vector<string> out;
    // iterate over the string starting every time at a the first position not having the delim.
    while (( start = in.find_first_not_of(delim, end)) != string::npos)
    {
        end = in.find(delim, start); // find first occurence of delim after the start position.
        out.push_back(in.substr(start, end-start)); // substring starting at start with the length end-start.
        // note the length is end-start and not end-start+1, as we don't want to include the delim itself.
    }

    return out;
}

// get only the first occurence of the token and rest of the input string
void tokenize_prefix(string in, char delim, string &prefix, string &suffix) {
    size_t end = in.find(delim, 0);
    prefix = in.substr(0, end);
    suffix = in.substr(end+1);
}

// just parse the friend/<message> and display it on the console
void print_msg(string msg) {
    string friend_; // name of the sender
    string act_msg; // actual message
    tokenize_prefix(msg, '/', friend_, msg);
    cout << "\x1b[31;1m" << friend_ << ":\x1b[0m" << " " << msg << endl;   
}

// pad string with delim character, to length n (right side)
string pad_str(string in, char delim, int n) {
    string out = in;
    return out.append(string(n-in.length(), delim));
}

// Function which return string by concatenating it.
string repeat(string s, int n)
{
    // Copying given string to temparory string.
    string s1 = s;
    for (int i=1; i<n;i++)
        s += s1; // Concatinating strings
    return s;
}

// a general fucntion to print a vector of vectors of strings as a table.
void print_table(vector<vector<string>> table, vector<string> fields) {
    int i;
    // print the header (all the fields)
    #if DEBUG
        cout << "\x1b[32;1m Inside the print_table function \x1b[0m" << endl;
    #endif
    
    vector <int> maxlens(table[0].size(), 0);
    for ( vector<string> row: table ) {
        i = 0;
        for ( string s: row ) {
            maxlens[i] = max((int)s.length(), maxlens[i]);            
            i++;
        }
    }
    i = 0;
    for ( string field: fields ) {
        maxlens[i] = max((int)field.length(), maxlens[i]);            
        i++;       
    }
    #if DEBUG 
        cout << "max length of any value for each column:" << endl;
        for ( int len : maxlens) {
            cout << len << ", ";
        }
        cout << endl;
    #endif 

    cout << "\x1b[34;1m";
    i = 0;    
    for ( string field: fields )
        cout << repeat("—", maxlens[i++]+3);
    cout << "—" << endl << "| ";
    i = 0;
    for ( string field: fields )
        cout << pad_str(field, ' ', maxlens[i++]) << " | ";
    cout << endl;
    i = 0;    
    for ( string field: fields )
        cout << repeat("—", maxlens[i++]+3);
    cout << "—\x1b[0m" << endl;

    for ( vector<string> row: table ) {
        cout << "| ";
        i = 0;
        for ( string col: row) {
            cout << pad_str(col, ' ', maxlens[i++]) << " | ";
        }
        cout << endl;
    }
    
    i = 0;
    for ( string field: fields )
        cout << repeat("—", maxlens[i++]+3);
    cout << "—" << endl;
}

#endif