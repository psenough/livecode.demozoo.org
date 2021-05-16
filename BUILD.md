# Build

Note: Based on Windows. Adapt for Linux/Mac, should be easy.

## Requirements

- [Python](https://www.python.org/) 3
- Dependencies:

  ```sh
  pip install -r requirements.txt
  ```

## Build Website

```sh
python .\bin\generate_html.py
```

## Check JSON data

```sh
jsonschema -i .\data\2020_shader_royale_shader_royale2.json .\meta\event.schema.json
```
