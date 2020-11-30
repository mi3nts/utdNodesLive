










function continual_process()
 path_to_watch = 'C:\Users\3cal-shape\Desktop\test';
 fileObj = System.IO.FileSystemWatcher(path_to_watch);
 fileObj.Filter = '*.slm';
 fileObj.EnableRaisingEvents = true;
 addlistener(fileObj,'Created', @eventhandlerChanged);
 addlistener(fileObj,'Changed', @eventhandlerChanged);
 i=0;
 while i<1000000
    i = i+1;
    pause(0.001);
 end
 end
 function eventhandlerChanged(source,arg)
 disp(source)
 disp('found new file')
 end