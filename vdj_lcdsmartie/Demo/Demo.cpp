// Demo.cpp : Send a verb and receive response

#include <iostream>
#include <string>
#include <windows.h>
#include <tchar.h>
using namespace std;

string verb; // input string
LPCTSTR shbuffer; // shared memory buffer
HANDLE hMapFile; // shared memory handle 
HANDLE ghCommandEvent; // handle for command event
HANDLE ghDataEvent; // handle for data event


int main(int argc, char** argv)
{
    if (argc < 2)
    {
        cout << "Input a script verb: ";
        getline(cin, verb);
    }
    else
    {
        verb = argv[1];
    }

    hMapFile = OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, TEXT("Local\\VDJSM")); // open shared memory
    if (hMapFile == NULL || hMapFile == INVALID_HANDLE_VALUE)
    {
        cout << "Could not open file mapping\n";
        return 1;
    }

    shbuffer = (LPTSTR)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 2048); // our window to shared memory
    if (shbuffer == NULL)
    {
        cout << "Could not map View of file\n";
        return 1;
    }


    ghCommandEvent = OpenEvent(EVENT_ALL_ACCESS, FALSE, TEXT("Local\\VDJCommand")); // command event
    if (ghCommandEvent == NULL)
    {
        cout << "Could not open command event\n";
        return 1;
    }

    ghDataEvent = OpenEvent(EVENT_ALL_ACCESS, FALSE, TEXT("Local\\VDJData")); // data event
    if (ghDataEvent == NULL)
    {
        cout << "Could not open data event\n";
        return 1;
    }

    CopyMemory((PVOID)shbuffer, verb.c_str(), strlen(verb.c_str())); // copy command to shared memory

    SetEvent(ghCommandEvent); // tell the plugin we've sent data

    WaitForSingleObject(ghDataEvent, INFINITE); // wait for signal from plugin to say data is ready

    cout << std::flush; // flush as crap gets left in buffers or something
    cout << shbuffer; // output 
 ;
}

