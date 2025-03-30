# Revision 2025 :: Extra textures

## How to install
* Download this here: [https://livecode.demozoo.org/extra/revision_2025_extra_textures.zip](/extra/revision_2025_extra_textures.zip).
* Extract the content of the zip in your bonzomatic directory
    * The textures should be installed like that : 

```
    c:\...\bonzomatic\textures\
                          texAcorn1.png
                          texAcorn2.png
                          texLeafs.png
                          texRevisionBW.png
```

* Open your `config.json`
* Edit the `textures` key, it should be like this (the zip contain a `config_textures.json` that contains the what need to be copied):

```json
{
  ...
  "textures": {
      "texChecker": "textures/checker.png",
      "texNoise": "textures/noise.png",
      "texTex1": "textures/tex1.jpg",
      "texTex2": "textures/tex2.jpg",
      "texTex3": "textures/tex3.jpg",
      "texTex4": "textures/tex4.jpg",
      "texAcorn1": "textures/texAcorn1.png",
      "texAcorn2": "textures/texAcorn2.png",
      "texLeafs": "textures/texLeafs.png",
      "texRevisionBW": "textures/texRevisionBW.png"
  },
  ...
}
```

* Delete or Move your `shader.glsl` or `sender_revision_jam_2025_<your_nickname>.glsl`
* Start bonzomatic
* You can verify that it works by replacing the cotnent of `test_textures.glsl` inside bonzomatic: 