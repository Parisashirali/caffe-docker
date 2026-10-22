# caffe-docker

A Dockerfile that builds the original [BVLC Caffe](https://github.com/BVLC/caffe) (CPU only, with the Python bindings, `pycaffe`) on Ubuntu 20.04.

Caffe is no longer maintained and is missing from current Ubuntu releases, so installing it directly on a modern system is painful. This image avoids that: it uses Ubuntu 20.04 (Python 3.8, OpenCV 4.2, GCC 9), applies the small source patches Caffe needs for OpenCV 4 and newer Boost.Python, and builds everything inside a container.

## Do you need Caffe?

If you only want to run a pretrained `.caffemodel`, you do not need to build Caffe. OpenCV can load it:

```python
import cv2
net = cv2.dnn.readNetFromCaffe("deploy.prototxt", "model.caffemodel")
```

Use this repo if you need training, `pycaffe`, Python layers, or a project that calls `import caffe`.

## Official image

Caffe's own repository has [Dockerfiles](https://github.com/BVLC/caffe/tree/master/docker) and prebuilt images:

```
docker run -ti bvlc/caffe:cpu caffe --version
```

That image uses Ubuntu 16.04 and Python 2, and the Dockerfiles were last changed in April 2017. This repo exists for people who need Python 3 (`import caffe` from `python3`) on a newer base.

## Requirements

- [Docker](https://docs.docker.com/get-docker/). On Windows, use Docker Desktop with the WSL 2 backend (Windows Subsystem for Linux, version 2).
- A few GB of free disk space and some time.
- The `Dockerfile` must use LF line endings (Line Feed), not CRLF (Carriage Return + Line Feed). Windows editors sometimes save CRLF, which breaks the build.

## Build

From the folder that contains the `Dockerfile`:

```
docker build -t caffe-cpu .
```

`-t` (tag) names the image `caffe-cpu`.

## Run

```
docker run -it --rm -v "$PWD":/work caffe-cpu
```

On Windows PowerShell, to share the current folder:

```
docker run -it --rm -v ${PWD}:/work caffe-cpu
```

To share a specific folder on any drive, put its full path before the colon:

```
docker run -it --rm -v C:\path\to\your\folder:/work caffe-cpu
```

- `-it`: interactive terminal.
- `--rm`: delete the container when you exit.
- `-v`: volume, a folder shared between your computer and the container. It appears as `/work`, and files saved there stay on your computer.

## Check that it works

Inside the container:

```
caffe --version
python3 -c "import caffe; print(caffe.__file__)"
```

## Remove it

```
docker rmi caffe-cpu
docker builder prune
```

The first command deletes the image and the second clears the build cache (several GB).

## Not included

- **GPU (CUDA) support.** CUDA stands for Compute Unified Device Architecture. The official GPU Dockerfile in Caffe's repository uses CUDA 8.0 with cuDNN 6 (CUDA Deep Neural Network library) on Ubuntu 16.04, which supports graphics cards only up to the Pascal generation, and its base image may no longer be available.
- **Pinned Caffe version.** The Dockerfile clones the latest `BVLC/caffe` master.

## Credits

Based on my own install notes and on these guides:

- [BVLC/caffe issue #6680](https://github.com/BVLC/caffe/issues/6680)
- [Q-engineering: Install Caffe on Ubuntu 20.04 with OpenCV 4.4](https://qengineering.eu/install-caffe-on-ubuntu-20.04-with-opencv-4.4.html)
- [Q-engineering: Caffe configuration](https://qengineering.eu/caffe-configuration.html)
- [Totemi1324/caffe-installation-guide](https://github.com/Totemi1324/caffe-installation-guide)
