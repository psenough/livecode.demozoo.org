from pathlib import Path
from typing import Iterator
import urllib.request


def download(poshbrolly_id: str, target_path: Path) -> None:
    output_filename = target_path / f'{poshbrolly_id}.jpg'

    # No need to redownload. Save resources on Shadertoy.
    if output_filename.exists():
        return

    url = f'https://firebasestorage.googleapis.com/v0/b/posh-brolly.appspot.com/o/thumbs%2F{poshbrolly_id}.jpg?alt=media&token=1278aea8-75ab-469c-b1dd-c91f42e6d11f'
    urllib.request.urlretrieve(url, output_filename)


def find_poshbrolly_urls(event) -> Iterator[str]:
    for phase in event['phases']:
        for entry in phase['entries']:
            url = entry.get('poshbrolly_url')
            if url:
                yield url


def download_poshbrolly_overview(event, target_path: Path) -> None:
    if not target_path.exists():
        target_path.mkdir()
    for url in find_poshbrolly_urls(event):
        shadertoy_id = url.split('/')[-1]
        download(shadertoy_id, target_path)
