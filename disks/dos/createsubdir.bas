10 open1,8,15,"/0:sub1,"+chr$(1)+chr$(0)+chr$(140)+chr$(0)+",c":close1
20 open1,8,15,"/0:sub1,"chr$(1)chr$(0)chr$(140)chr$(0)",c":close1
30 open1,8,15:print#1,"/0:sub1,"chr$(1)chr$(0)chr$(140)chr$(0)",c"
33 gosub 40:  print#1,"/0:sub1"
35 gosub 40:  print#1,"n0:sub1"
37 gosub 40: goto 60
39 rem ------------------------------
40 input#1, ee$, em$, et$, es$
50 print "floppy-status: " ee$ " - " em$ " (" et$ "," es$ ")" : print
55 return
60 close1
