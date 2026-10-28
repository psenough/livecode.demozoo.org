#!python3

import argparse
import codecs
import json
from zipfile import ZipFile
from datetime import datetime
from pathlib import Path


def server_url_builder(schema: str, host: str, port: str, room: str):
    """
    Create a factory to build server url based on the coder handle
    """

    def _function(handle: str):
        return f"{schema}://{host}:{port}/{room}/{handle}"

    return _function


def bonzo_arguments(server_url: str):
    """
    Argument use to launch bonzomatic
    """
    return f"skipdialog networkMode=sender serverURL={server_url}"


def _generate_launcher(filename: str, bonzo_cmd: str, bonzo_args):
    """
    Write in a file a command line that should run bonzomatic
    """
    with codecs.open(filename, "w", "UTF-8") as f:
        f.write(f"{bonzo_cmd} {bonzo_args}")
    return filename


def generate_launcher(host: str, room: str, coder: str, server_url):
    """
    Generate a zip for a coder that contains a windows launcher, a unix launcher and the info.txt
    """
    date = datetime.today().strftime("%Y_%m_%d")
    id = f"{date}_{host.replace('.','_')}_{room}_{coder}"
    files = [
        _generate_launcher(
            f"{id}.bat",
            ".\\Bonzomatic_W64_GLFW.exe ",
            bonzo_arguments(server_url(coder)),
        ),
        _generate_launcher(
            f"{id}.sh", "./Bonzomatic_W64_GLFW", bonzo_arguments(server_url(coder))
        ),
    ]
    with ZipFile(f"{id}.zip", "w") as zip_obj:
        for f in files:
            zip_obj.write(f)
        zip_obj.write("info.txt")

    for f in files:
        Path(f).unlink()


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--schema", default="ws", help="Schema of the server url")
    parser.add_argument(
        "--host", default="drone.alkama.com", help="Host of the server url"
    )
    parser.add_argument("--port", default="9000", help="Port of the server url")
    parser.add_argument("--room", default="roomtest", help="Room of the server url")
    parser.add_argument("--config", default="launcher.json", help="Configuration file")

    args = parser.parse_args()

    data = json.load(open(args.config))

    url_builder = server_url_builder(args.schema, args.host, args.port, args.room)
    for coder in data["coders"]:
        generate_launcher(args.host, args.room, coder, url_builder)
