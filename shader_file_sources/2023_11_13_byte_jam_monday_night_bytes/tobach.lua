--           ^^^^^^^^
--hellooooo toooooooobach here
--
--blimey! 9 people!!
--greetz to mantra, lynn, dr soft
--lex, gasman, jtruk, visy and evilpaul

txtarr={}
txtarr[1]= "C-301000 C-202C10 G-203900 ---00000"
txtarr[2]= "---00000 ---00000 G-203902 ---00000"
txtarr[3]= "---00000 D-202C20 G-303904 ---00000"
txtarr[4]= "---00000 ---00000 G-203906 ---00000"
txtarr[5]= "C-301000 E-202C10 G-203908 ---00000"
txtarr[6]= "---00000 ---00000 G-30390A ---00000"
txtarr[7]= "---00000 F-202C20 G-20390C ---00000"
txtarr[8]= "---00000 ---00000 G-30390E ---00000"
txtarr[9]= "C-301000 G-202C10 G-203910 ---00000"
txtarr[10]="---00000 ---00000 G-203912 ---00000"
txtarr[11]="---00000 A-202C20 G-303914 ---00000"
txtarr[12]="---00000 ---00000 G-203916 ---00000"
txtarr[13]="C-301000 B-202C10 G-203918 ---00000"
txtarr[14]="---00000 ---00000 G-30391A ---00000"
txtarr[15]="---00000 C-302C20 G-20391C ---00000"
--blank for copying :)
txtarr[17]=""

ft=0
ft2=0
sin=math.sin
function TIC()
 cls(13)
 t=time()/80
 rect(10,55,220,79,0)
 rect(0,87,240,8,13)
 rectb(10,54,220,81,14)
 for i=1,16 do
  if i==5 then
   print(txtarr[i],16,48+i*8,0,true)
  else
   print(txtarr[i],16,48+i*8,9,true)
  end
 end
 ft=ft+4
 if ft>16 then
  ft=0
  ft2=ft2+1
  if ft2>16 then ft2=0 end
  copyshit()
 end
 for i=0,3 do
  rect(83+i*38,18,32,26,0)
 end
 for i=0,31 do
  pix(159+i,30+sin(i+t*2)*sin(i/3+t*2)*sin(i/7+t*2)*8,4)
 end
 for i=0,31 do
  pix(121+i,30+sin(i/(16-ft2)+t*8)*8,4)
 end
 for i=0,31 do
  pix(83+i,30+sin(i+t*i)*(8-ft2%4),4)
 end
 rectb(-1,43,242,12,14)
 print("SONGNAME:",3,46,14,true)
 print("MY EPIC CHOON______________",60,46,0,true)
 print("  PLAY      STOP      PLST",88,2,14,false)
 print("PATTERN   CLEAR   PSET-ED",88,10,14,false)
 for j=0,1 do
  for i=0,2 do
   rectb(83+i*47,0+j*8,48,9,12)
  end
 end
 print("JANK",5,5,15,true,3)
 print("TRACKER",-1,21,15,true,2)
 print("2.3D-SLP'1993",6,33,15,false)
 
 for i=0,3 do
  rect(142,79-i*8,12,8,1+i)
 end
 for i=0,ft2*2%4 do
  rect(88,79-i*8,12,8,1+i)
 end
 for i=0,ft2/2%4 do
  rect(34,79-i*8,12,8,1+i)
 end

end

function copyshit()
 for i=1,16 do
  txtarr[i]=txtarr[i+1]
 end
 txtarr[15]=txtarr[1]
end