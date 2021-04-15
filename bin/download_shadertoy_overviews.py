import urllib.request
import os.path

def download(id):
    output_filename = os.path.join("media",f"{id}.jpg")
    # Don't need to redownload. Save resources on Shadertoy
    if not os.path.exists(output_filename):
        url = f'https://www.shadertoy.com/media/shaders/{id}.jpg'
        urllib.request.urlretrieve(url, output_filename)
def find_shadertoy_link(event):
    for phase in event['phases']:
        for entry in phase['entries']:
            yield entry['shadertoy_url']

def create_cache(event):
    shadertoy_url = [ url for url in find_shadertoy_link(event) if url]
    for url in shadertoy_url:
        download(url.split('/')[-1])