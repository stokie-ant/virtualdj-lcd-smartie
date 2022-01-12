# Virtual DJ Shared Memory Plugin and Virtual DJ LCD Smartie Plugin

Consists of two Plugins

## vdj_lcdsmartie
This is for the virtual dj side of things
It creates a named shared memory object and two event objects that can be used to Send verbs to and receive replies from virtual dj.

vdj_lcdsmartie.dll would go in Documents\VirtualDJ\Plugins64\AutoStart
I'm not sure if home versions of Virtual DJ support autostarting plugins though

- "Local\VDJSM" // this is the named shared memory segment
- "Local\VDJCommand" // this object signals the plugin to read a command from shared memory
- "Local\VDJData" // the plugin sets this to signal that data is ready to be read from shared memory

So it can be used for more than just lcd smartie
Check the console program in the vdj_lcdsmartie\demo folder

Built with visual studio 2022

## vdj-smartie-plugin
This is for the LCD Smartie side of things

only 1 function

$dll(virtualdj.dll,1,verb,[window size]#[window id])

- verbs are listed here https://www.virtualdj.com/wiki/VDJscript_verbs_v8.html
- 'window size' gives a left right scroll effect of 'window size' chars long
- 'window id' is mandatory if 'window size' is used. It is 0 to 9 and is used 
internally to track the scroll state. Every 'window id' on a screen must be unique

$dll(virtualdj.dll,1,deck 1 get_loaded_song title,0)
Will just give a unformatted reply to 'deck 1 get_loaded_song title' ie. track name 

$dll(virtualdj.dll,1,deck 2 get_loaded_song title,20#1)
will give the reply but give it a left right scroll effect limited to 20 chars wide

example also using spc plugin for spectrum display

Text01="$dll(virtualdj.dll,1,deck 1 get_loaded_song title,19#0)||$dll(virtualdj.dll,1,deck 2 get_loaded_song title,19#1)"\
Text02="$dll(virtualdj.dll,1,deck 1 get_loaded_song author,19#2)||$dll(virtualdj.dll,1,deck 2 get_loaded_song author,19#3)"\
Text03="$dll(virtualdj.dll,1,deck 1 get_time,7#4)|$dll(SPC,1,2#2,24)|$dll(virtualdj.dll,1,deck 2 get_time,7#5)"\
Text04="$dll(virtualdj.dll,1,deck 1 get_time total,7#6)|$dll(SPC,1,1#2,24)|$dll(virtualdj.dll,1,deck 2 get_time total,7#7)"

![example](example.gif)

Built with Lazarus IDE https://www.lazarus-ide.org
