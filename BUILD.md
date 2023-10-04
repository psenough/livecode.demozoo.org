# Build

Note: Based on Windows. Adapt for Linux/Mac, should be easy.

## Requirements

- [Python](https://www.python.org/) 3
- Dependencies:

  ```sh
  pip install -r requirements.txt
  ```

### Linux (and probably Mac OS, too)

On Linux, you might want to create a virtual environment to isolate the
project dependencies from the rest of the system.

Create it (using Python 3.7 in this example) in the path `venv/` (needs
to be done just once):

```sh
$ python3.7 -m venv venv
```

Activate it (needs to be done every time you want to use it):

```sh
$ . ./venv/bin/activate
```

Make sure pip and related tools/packages are available and up-to-date:

```sh
(venv)$ pip install -U pip setuptools wheel
```

Install the actual project dependencies:

```sh
(venv)$ pip install -r requirements.txt
```

## Build Website

```sh
python livecode update
python livecode generate
```

## Check JSON data

```sh
jsonschema -i .\data\2020_shader_royale_shader_royale2.json .\meta\event.schema.json
```

## Add preview image

So far no automatic way, just put preview images under `./media`. 

Make sure image is 1920x1080 (or any ratio of it).

Try to focus on jpg image (smaller) with some optimisation jpegoptim -m75 --strip-all %
