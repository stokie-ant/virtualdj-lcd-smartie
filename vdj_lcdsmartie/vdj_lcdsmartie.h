#ifndef VDJ_LCDSMARTIE_H
#define VDJ_LCDSMARTIE_H
using namespace std;

// we include stdio.h only to use the sprintf() function
// we define _CRT_SECURE_NO_WARNINGS for the warnings of the sprintf() function
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

#include "vdjPlugin8.h"

class vdj_lcdsmartie : public IVdjPlugin8
{
public:
  HRESULT VDJ_API OnLoad();
  HRESULT VDJ_API OnGetPluginInfo(TVdjPluginInfo8* infos);
  ULONG VDJ_API Release();
};


#endif
