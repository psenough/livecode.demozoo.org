# Shader Summary / Demoscene Livecode Events (livecode.demozoo.org)

List of demoscene livecoding events (Shader Showdown, Shader Jam, Shader Royale, Byte Battle, etc).

## How to Contribute

Contribute missing data by submitting a Pull Request of the JSON file in `/data`.

The JSON schema is in [./meta/event.schema.json](./meta/event.schema.json), but you can also take any other file in [./public/data](./public/data) as a base example.

A more readable version of the schema is available in [./public/doc/schema.html](./public/doc/schema.html).

Check [CONTRIBUTING.md](./CONTRIBUTING.md) for more information.

## Poster

Poster are generated on demand only (quite long process) via the Actions > Generate Poster workflow.

Nevertheless, you can also generate the poster locally via this set of commands :

```python
pip -r requirements.txt
python bin/livecode_ontology.py
python generate_user_poster.py
```
Poster are available here : 

## "Radio" Bonzomatic Shader
**Experimental**

Using the NuSan's version of [bonzomatic](https://github.com/TheNuSan/Bonzomatic), we created a "radio" that is streaming bonzomatic shader. You can visualize this radio using this command :

```
.\Bonzomatic_W64_GLFW.exe  skipdialog networkMode=grabber serverURL=ws://drone.alkama.com:9000/livecode/radio
```
(Windows here, similar call parameters for Linux/MacOs)
