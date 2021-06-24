from pathlib import Path
from typing import Iterator
import urllib.request


MEDIA_PATH = Path('media')


def download(shadertoy_id: str) -> None:
    output_filename = MEDIA_PATH / f'{shadertoy_id}.jpg'

    # No need to redownload. Save resources on Shadertoy.
    if output_filename.exists():
        return

    url = f'https://www.shadertoy.com/media/shaders/{shadertoy_id}.jpg'
    urllib.request.urlretrieve(url, output_filename)


def find_shadertoy_urls(event) -> Iterator[str]:
    for phase in event['phases']:
        for entry in phase['entries']:
            url = entry.get('shadertoy_url')
            if url:
                yield url


def create_cache(event) -> None:
    for url in find_shadertoy_urls(event):
        shadertoy_id = url.split('/')[-1]
        download(shadertoy_id)
