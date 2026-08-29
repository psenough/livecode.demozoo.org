-- More robots!
S=math.sin
C=math.cos

function makeRobot(x,y,o)
    return {
        x=x,
        y=y,
        ofs=o,
        faceT=math.random(1,2),
        faceW=math.random(30,60),
        faceH=math.random(30,80),
        faceC=math.random(1,11),
        eyeC=math.random(1,11),
        eyeLT=math.random(1,2),
        eyeRT=math.random(1,2),
        eyeBlOfs=math.random(0,10),
        eyeBrOfs=math.random(0,10),
        jawC=math.random(1,11),
        jawT=math.random(1,2),
        teethT=math.random(1,2),
    }
end

T=0
R=0
function TIC()
    cls()
    doFFT()

    for y=0,136 do
     for x=0,240 do
            c=((S(x//20)+C(y//20)+T/5)-T)%8
      pix(x,y,c)
        end
    end

    if(R%70==0)then
        nrobot=#robots+1
        ofs=nrobot%2
        robots[nrobot]=makeRobot(-30,70,ofs)
    end

    for i=1,#robots do
        moveRobot(robots[i])
     drawRobot(
      robots[i],
      robots[i].faceW,
      robots[i].faceH
  )
    end
    T=T+1
    R=R+1
end

FFT0=0

robots={}
function doFFT()
    FFT0=0
    for i=0,6 do
        FFT0=FFT0+fft(i)/7
    end
end

function moveRobot(robot)
    robot.x=robot.x+1
end

function    drawRobot(robot,w,h)
 x=robot.x
 y=robot.y+math.abs(S(robot.ofs+T/12))*-20
    x0=x-w/2
    y0=y-h/2
    if(robot.faceT==1)then
        rect(x0,y0,w,h,robot.faceC)
    else
        elli(x,y,w/2,h/2,robot.faceC)
    end
    xEl=x-w/3
    yEl=y-h/3
    xEr=x+w/3
    yEr=y-h/3
    drawE(robot,xEl,yEl,8,2,robot.eyeBlOfs,robot.eyeLT)
    drawE(robot,xEr,yEr,8,3,robot.eyeBrOfs,robot.eyeRT)
    xM=x
    yM=y+h/2
    drawJ(robot,xM,yM+FFT0*80,w,8,6)
end

function drawE(robot,x,y,w,ofs,type)
    eyeBx=x+S(T/10+ofs*10)*w/3
    eyeBy=y+C(T/10+ofs*10)*w/3
    if(type==1)then
--        circ(x+1,y+1,w,0)
        rect(x-w/2,y-w/2,w*2,w*2,robot.eyeC)
        circ(eyeBx,eyeBy,w/3,0)
    else
        circ(x+1,y+1,w,0)
        circ(x,y,w,robot.eyeC)
        circ(eyeBx,eyeBy,w/3,0)
    end
end

function drawJ(robot,x,y,w,h)
    x0=x-w/2

    if(robot.teethT==1)then
        for i=0,10 do
            circ(x0+i*w/10,y-3,3,12)
        end
    else
        for i=1,9 do
         xt=x0+i*w/10
   tri(xt,y-8,xt-5,y,xt+5,y,12)
        end
    end

    if robot.jawT==1 then
        rect(x0,y,w,h,robot.jawC)
    else
        elli(x,y,w/2,h/2,robot.jawC)
    end
end 