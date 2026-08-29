# EzBonzo
Script that generate launcher pre-configured as sender to the correct bonzomatic server url.

This is supposed to ease the preparation of online shader event.

```
usage: ezbonzo.py [-h] [--schema SCHEMA] [--host HOST] [--port PORT] [--room ROOM] [--config CONFIG]

optional arguments:
  -h, --help       show this help message and exit
  --schema SCHEMA  Schema of the server url
  --host HOST      Host of the server url
  --port PORT      Port of the server url
  --room ROOM      Room of the server url
  --config CONFIG  Configuration file
```

It only needs python. 

`--config CONFIG  Configuration file` is based on the Bonzomatic Launcher configuration files. It's expecting to have at least this format : 

```json
{
    #  ... Whatever before ...

    "coders": [
      "Coder_01",
      "Coder_02",
      "Coder_03",
      "Coder_04"
    ],

    #  ... Whatever after ...
}
```

If you are using the Bonzomatic Launcher as a host, just running `ezbonzo.py` aside the `launcher.json` should generate all the zip files for the participants.