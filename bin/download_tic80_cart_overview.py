import urllib.request
import os.path
import shutil

from bs4 import BeautifulSoup
import requests

def download(id):
    output_filename = os.path.join("media",f"cart_{id}.gif")
    # Don't need to redownload. Save resources on Tic80
    if not os.path.exists(output_filename):
        url = f'https://tic80.com/play?cart={id}'
        req = requests.get(url)
        soup = BeautifulSoup(req.content,'html5lib')
        img = soup.find("meta",{'property':"og:image"})
        img = img.attrs.get('content')
        r = requests.get(img, stream=True)
        if r.status_code == 200:
            with open(output_filename, 'wb') as f:
                r.raw.decode_content = True
                shutil.copyfileobj(r.raw, f)   
def find_cart_id(event):
    for phase in event['phases']:
        for entry in phase['entries']:
            yield entry.get('tic80_cart_id', None)

def create_cache(event):
    tic80_carts = [ cart_id for cart_id in find_cart_id(event) if cart_id]
    for cart_id in tic80_carts:
        download(cart_id.split('/')[-1])