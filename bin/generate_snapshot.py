"""
TODO : Make it more reliable, for the moment just a save

Usage : 
python generate_snapshot <globpath>
"""
import glob
import sys
import os
import subprocess
import time
for f in glob.glob(sys.argv[1]):
    basename = os.path.splitext(os.path.basename(f))[0]
    p = subprocess.Popen(['.\Bonzomatic.exe','skipdialog', f"shader={f}"])
    time.sleep(3)
    try:
        output = subprocess.run(['ffmpeg','-ss','5.5','-f','gdigrab','-i','title=BONZOMATIC - GLFW','-vframes','1','-q:v', '2', '-y', f'{basename}.jpg'])
    except subprocess.TimeoutExpired: 
        print('subprocess has been killed on timeout')
    else:
        print('subprocess has exited before timeout')
    p.kill()