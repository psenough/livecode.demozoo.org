from pathlib import Path
from typing import Iterator
import urllib.request


def download(shadertoy_id: str, target_path: Path) -> None:
    output_filename = target_path / f'{shadertoy_id}.jpg'

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


def create_cache(event, target_path: Path) -> None:
    for url in find_shadertoy_urls(event):
        shadertoy_id = url.split('/')[-1]
        download(shadertoy_id, target_path)
