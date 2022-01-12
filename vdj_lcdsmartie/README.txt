this is for the virtual dj side of things

It creates a named shared memory object and two event objects that can be used to Send verbs to and receive replies from virtual dj.

"Local\VDJSM" // this is the named shared memory segment

"Local\VDJCommand" // this object signals the plugin to read a command from shared memory

"Local\VDJData" // the plugin sets this to signal that data is ready to be read from shared memory

So it can be used for more than just lcd smartie

Check the console program in the demo folder

Built with visual studio 2022