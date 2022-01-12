library virtualdj;

{$MODE Delphi}

uses
  SysUtils, Classes, Windows, DateUtils;

const
  SHARED_MEMORY_NAME = 'Local\VDJSM';


type
    TSharedMem=packed record
      allmem:Array[1..2048] of char;
    end;

    PTSharedMem=^TSharedMem;

    Tscreendata=record
      currentposition:integer;
      moveleft:integer;
      fullstring:string;
      last:string;
      line: string;
      timer:TTimeStamp;
    end;



var
  myHandle: Cardinal;
  memory: PTSharedMem;
  // support 10 screen ids
  screen0: Tscreendata;
  screen1: Tscreendata;
  screen2: Tscreendata;
  screen3: Tscreendata;
  screen4: Tscreendata;
  screen5: Tscreendata;
  screen6: Tscreendata;
  screen7: Tscreendata;
  screen8: Tscreendata;
  screen9: Tscreendata;
  thisscreen : Tscreendata;

  commandeventhandle:THandle;
  dataeventhandle:THandle;

Function MapMemory: Boolean;
begin
  result := false;
  if (myHandle > 0) and (memory <> nil) then result := true
  else
  begin

    myHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, SHARED_MEMORY_NAME);
    if myHandle > 0 then
    begin
      memory := MapViewOfFile(myHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
      if (memory <> nil) then
          result := true
      else
      begin
          FileClose(myHandle);
          myHandle := 0;
      end;
    end;
  end;
end;
// Smartie will call this when the plugin is 1st loaded
// This function is optional
Procedure SmartieInit; stdcall;
begin
  myHandle := 0;
   memory := nil;

end;

// Smartie will call this just before the plugin is unloaded
// This function is optional
Procedure SmartieFini; stdcall;
begin
  if (myHandle > 0) then
  begin
    if (memory <> nil) then
    begin
       UnMapViewOfFile(memory);
       memory := nil;
    end;
    FileClose(myHandle); { *Converted from CloseHandle* }
    myHandle := 0;
  end;
end;

// Define the minimum interval that a screen should get fresh data from our
// plugin.
// The actual value used by Smartie will be the higher of this value and
// of the 'dll check interval' setting
// on the Misc tab.  [This function is optional, Smartie will assume
// 300ms if it is not provided.]
Function GetMinRefreshInterval: Integer; stdcall;
begin
	result := 100;
end;

Function function1(param1:pchar;param2:pchar):pchar; stdcall;
var
  tmpstr:string;
  windowsize:integer;
  waitresult:dword;
  parpos:integer;
  arg1:string;
  arg2:string;
  tnow:TTimeStamp;
  tdiff:integer;
begin
  // re-open these every time so we can detect if they've gone thus preventing lockups
  dataeventhandle := OpenEvent(EVENT_ALL_ACCESS, TRUE,'Local\VDJData');
  commandeventhandle := OpenEvent(EVENT_ALL_ACCESS, TRUE, 'Local\VDJCommand');

  if  not (dataeventhandle > 0 ) or not (dataeventhandle > 0 )then begin
    tmpstr := 'Virtualdj or plugin not running';
  end
  else begin
  try
    if (MapMemory()) then
    begin
      memory^.allmem := copy(param1,0,2048); // like 'deck 1 get_loaded_song title'

      setevent(CommandEventHandle); // let virtual dj plugin know we have sent a command

      // wait for virtual dj to signal data is ready. timeout in case object has gone
      waitresult := WaitForSingleObject(dataeventhandle,1000);
      if (waitresult = WAIT_TIMEOUT) then begin
        result := PChar('Command timed out');
        exit; // nothing to do
      end;

      tmpstr := PChar(@memory^.allmem); // copy returned data from shared mem

      closehandle(dataeventhandle); // so it can be re-opened
    end
    else
      tmpstr := 'VDJ or plugin not running';
  except
    on E: Exception do
      tmpstr := 'plugin had exception: ' + E.Message;
  end;
  end;

  if not (param2 = '0') then begin
    parpos := pos('#',param2);
    arg1 := copy(param2, 0, parpos-1);
    arg2 := copy(param2, parpos+1, 2);

    case (strtoint(arg2)) of
       0 : thisscreen := screen0;
       1 : thisscreen := screen1;
       2 : thisscreen := screen2;
       3 : thisscreen := screen3;
       4 : thisscreen := screen4;
       5 : thisscreen := screen5;
       6 : thisscreen := screen6;
       7 : thisscreen := screen7;
       8 : thisscreen := screen8;
       9 : thisscreen := screen9;
       else result := PChar('id not found');
    end;

    windowsize := strtoint(arg1);
    thisscreen.fullstring:=tmpstr;
    if (length(thisscreen.fullstring) < windowsize) then
      thisscreen.fullstring := copy(thisscreen.fullstring + '                                        ', 0, windowsize);

    if not (thisscreen.fullstring = thisscreen.last) then  // track change
    begin                      // track change detected. reset all parameters
      thisscreen.moveleft := 1;
      thisscreen.currentposition :=0;
    end;

    thisscreen.line := copy(thisscreen.fullstring, thisscreen.currentposition, windowsize);

   tnow := DateTimeToTimeStamp(now);
   tdiff := tnow.Time - thisscreen.timer.Time;

   if  (tdiff  > 500) then begin
    if (thisscreen.moveleft = 1) then
      inc(thisscreen.currentposition);
    if (thisscreen.moveleft = 0) then
      dec(thisscreen.currentposition);
    if (thisscreen.currentposition <= 0) and (thisscreen.moveleft = 0) then
      thisscreen.moveleft := 1;
    if ((thisscreen.currentposition + windowsize) > length(thisscreen.fullstring)) then
      thisscreen.moveleft:=0;
    thisscreen.timer := DateTimeToTimeStamp(Now);
  end;
    thisscreen.last := thisscreen.fullstring; // so we can detect a track change
    tmpstr := thisscreen.line;

    case (strtoint(arg2)) of
       0 : screen0 := thisscreen;
       1 : screen1 := thisscreen;
       2 : screen2 := thisscreen;
       3 : screen3 := thisscreen;
       4 : screen4 := thisscreen;
       5 : screen5 := thisscreen;
       6 : screen6 := thisscreen;
       7 : screen7 := thisscreen;
       8 : screen8 := thisscreen;
       9 : screen9 := thisscreen;
    end;
  end;
  result := PChar(tmpstr);
end;

// don't forget to export the funtions, else nothing works :)
exports
  function1,
  SmartieInit,
  SmartieFini,
  GetMinRefreshInterval;
begin
end.

