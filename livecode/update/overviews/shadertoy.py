from pathlib import Path
from typing import Iterator
import urllib.request


def get_image_url(shadertoy_id: str) -> str:
    return f'https://www.shadertoy.com/media/shaders/{shadertoy_id}.jpg'


def download(shadertoy_id: str, target_path: Path) -> None:
    output_filename = target_path / f'{shadertoy_id}.jpg'

    # No need to redownload. Save resources on Shadertoy.
    if output_filename.exists():
        return

    url = get_image_url(shadertoy_id)
    urllib.request.urlretrieve(url, output_filename)


def find_shadertoy_urls(event) -> Iterator[str]:
    for phase in event['phases']:
        for entry in phase['entries']:
            url = entry.get('shadertoy_url')
            if url:
                yield url


def download_shadertoy_overview(event, target_path: Path) -> None:
    for url in find_shadertoy_urls(event):
        shadertoy_id = url.split('/')[-1]
        try:
            download(shadertoy_id, target_path)
        except:
            print(f"Error downloading {url}. Please open {get_image_url(shadertoy_id)} in a browser and save it to {target_path}.")
