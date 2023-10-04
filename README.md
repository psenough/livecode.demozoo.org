# Shader Summary / Demoscene Livecode Events (livecode.demozoo.org)

List of demoscene livecoding events (Shader Showdown, Shader Jam, Shader Royale, Byte Battle, Byte Jam, etc).

## How to Contribute

Contribute missing data by submitting a Pull Request of the JSON file in `/data`.

The JSON schema is in [./meta/event.schema.json](./meta/event.schema.json), but you can also take any other file in [./public/data](./public/data) as a base example.

A more readable version of the schema is available at [https://livecode.demozoo.org/doc/schema.html](https://livecode.demozoo.org/doc/schema.html).

Check [CONTRIBUTING.md](./CONTRIBUTING.md) for more information.

## "Radio" Bonzomatic Shader
**Experimental**

Using the NuSan's version of [bonzomatic](https://github.com/TheNuSan/Bonzomatic), we created a "radio" that is streaming bonzomatic shader. You can visualize this radio using this command :

```
.\Bonzomatic_W64_GLFW.exe  skipdialog networkMode=grabber serverURL=ws://drone.alkama.com:9000/livecode/radio
```
(Windows here, similar call parameters for Linux/MacOs)
