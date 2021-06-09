# How to contribute

## As a participant 
If you have some backup of your productions that arn't listed (source file, shadertoy link, tic80.com cart etc... ) you can either contact the admin of the repo or create a Pull Request.

When you're participating to an event, ask if the organiser is aware of the website and willing to contribute.

## As an organiser
We are aware that organising an event takes time and you can't be fully dedicated to the task.

But no worries, with a little bit of preparation, the admins of this repo can integrate your data.

To help the task to be as smooth as possible here is what you should prepare :

The minimum information needed is 
* The name, type and date of the event
* The entries performance with the people handle

But, we highly recommand also to bring:
* The source code of the production (if it's fine for everybody)
* The custom configuration of the software used 
* The custom texture used
* The result information in case of a showdown / battle (bracket, points etc... )


## Doing a PR
If you are brave enough, you can sumbit a PR to the `main` branch.

* `/data` : Mantadory. The event information in json. You can look at other event to see how to fill the data. The schema of the json is defined here https://psenough.github.io/shader_summary/doc/schema.html .  

* `/media`: Optional. All preview image materials.
Note : If you registered a shadertoy link or a tic80 cart id to an entry, the image preview will be generated automatically.

* `/shader_file_sources` : Optional. All files sources.

One day, promise, we will have a proper formular to ease the process :)


### Add preview image

Capturing image from Bonzomatic:
```bash
ffmpeg -f gdigrab -i 'title=BONZOMATIC - GLFW' -vframes 1 -q:v 2 -y outfile.jpg 
```

Make sure image is 1280x720 (or any ratio of it).

Try to focus on jpg image (smaller) with some optimisation. We advise using `jpegoptim -m75 --strip-all file.jpg`

