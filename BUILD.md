# Build

Note : Based on windows, adapt for linux / mac, should be easy

## Requierments

Requierments : Python 3

```python
pip install -r requirements.txt
```

## Build Website

`python .\bin\generate_html.py`

## Check json data

`jsonschema -i .\data\2020_shader_royale_shader_royale2.json .\meta\event.schema.json`
