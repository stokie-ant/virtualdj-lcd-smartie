#include "vdj_lcdsmartie.h"
#include <fstream>
#include <tchar.h>
using namespace std;


LPCTSTR shbuffer; // shared memory buffer

HANDLE hMapFile; // shared memory handle 
HANDLE hcommandthread; // handle to thread
HANDLE ghCommandEvent; // handle for command event
HANDLE ghDataEvent; // handle for data event

bool threadrun = true;

DWORD WINAPI CommandThread(PVOID lpParam)
{
    while (threadrun)
    {
        char mystr[2048] = ""; // holds virtualdj command output

        WaitForSingleObject(ghCommandEvent, INFINITE); // it's ok to wait indefinitely for a command, we're doing nothing else

        ((vdj_lcdsmartie*)lpParam)->GetStringInfo(shbuffer, mystr, 2048); // run virtualdj command

        memset((PVOID)shbuffer, 0, strlen(shbuffer)); // clear the shared mem

        CopyMemory((PVOID)shbuffer, mystr, (_tcslen(mystr) * sizeof(TCHAR))); // copy command output to shared memory

        SetEvent(ghDataEvent); // let lcd smartie plugin know data is ready
    }
  return 0;
}

//-----------------------------------------------------------------------------
HRESULT VDJ_API vdj_lcdsmartie::OnLoad()
{
    hMapFile = CreateFileMapping(INVALID_HANDLE_VALUE, NULL, PAGE_READWRITE, 0, 2048, TEXT("Local\\VDJSM")); // Shared memory for passing data between plugins
    if (hMapFile == NULL || hMapFile == INVALID_HANDLE_VALUE)
    {
        return 1;
    }

    shbuffer = (LPTSTR)MapViewOfFile(hMapFile, FILE_MAP_ALL_ACCESS, 0, 0, 2048); // our window to shared memory
    if (shbuffer == NULL)
    {
        return 1;
    }


    ghCommandEvent = CreateEvent(NULL, FALSE, FALSE, TEXT("Local\\VDJCommand")); // event to let us know when lcd smartie plugin has sent us a command
    if (ghCommandEvent == NULL)
    {
        return 1;
    }

    ghDataEvent = CreateEvent(NULL, FALSE, FALSE, TEXT("Local\\VDJData")); // event to let lcd smartie plugin know when data is available
    if (ghDataEvent == NULL)
    {
        return 1;
    }

    hcommandthread = CreateThread(NULL, 0, CommandThread, this, 0, NULL); // create our thread

    return S_OK;
}

//-----------------------------------------------------------------------------
HRESULT VDJ_API vdj_lcdsmartie::OnGetPluginInfo(TVdjPluginInfo8* infos)
{
    infos->PluginName = "LCDSmartie";
    infos->Author = "Stokie-Ant";
    infos->Description = "VirtualDJ 8 LCDSmartie plugin";
    infos->Version = "1.0";
    infos->Flags = 0x00;
    infos->Bitmap = NULL;

    return S_OK;
}

//---------------------------------------------------------------------------
ULONG VDJ_API vdj_lcdsmartie::Release()
{
    threadrun = false;
    CloseHandle(hcommandthread);
    CloseHandle(ghCommandEvent);
    CloseHandle(ghDataEvent);
    UnmapViewOfFile(shbuffer);
    CloseHandle(hMapFile);
    delete this;
    return 0;
}

