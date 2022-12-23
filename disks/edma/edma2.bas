10 rem bits 0 and 1 are commands
20 rem bit 5 is direction: 1=down
30 :
33 rem scroll down:
35 for i=0 to 19:edma 0, 80, i*80+2128, i*80+2048:next i
37 :
39 rem scroll up:
40 for i=14 to 0 step -1:edma 0, 80, i*80+2048, i*80+2128:next i
50 :
55 rem https://github.com/mega65/mega65-user-guide/issues/518
