# ADMX Linter Docker Image

This repository contains the Dockerfile to build a Docker image for `admx-lint`, a command-line tool for linting ADMX (Administrative Template) files.

The image is built using a multi-stage Docker build.
*   The first stage (`builder`) compiles `admx-lint` from source and packages it into a `.deb` file.
*   The second stage creates a slim final image based on `debian:sid-slim`, installs the necessary runtime dependencies, and then installs the `admx-lint` `.deb` package.

## Prerequisites

*   Docker installed on your system.

## Building the Image

To build the Docker image, navigate to the directory containing the `Dockerfile` and run:

```bash
docker build -t admx-lint-image .
```

You can replace `admx-lint-image` with your preferred image name and tag.

## How to Use

The primary executable in this image is `admx-lint`. You'll typically run the container, mount a directory containing your ADMX/ADML files, and then execute `admx-lint` against those files.

**Example: Linting a single ADMX file**

If you have an ADMX file located at `/path/to/your/templates/my_template.admx` on your host machine, you can lint it using the following command:

```bash
docker run --rm \
  -v /path/to/your/templates:/data \
  admx-lint-image \
  admx-lint /data/my_template.admx
```

**Explanation:**
*   `docker run --rm`: Runs the container and automatically removes it when it exits.
*   `-v /path/to/your/templates:/data`: Mounts the host directory `/path/to/your/templates` to the `/data` directory inside the container. This makes your ADMX files accessible to the linter.
*   `admx-lint-image`: The name of the Docker image you built.
*   `admx-lint /data/my_template.admx`: The command executed inside the container. `admx-lint` is the linter, and `/data/my_template.admx` is the path to the file *inside the container*.


## Image Details

*   **Source Project:** Harvester57/admx-lint
*   **Builder Base Image:** `fstossesds/cmake:latest`
*   **Final Base Image:** `debian:sid-slim`
*   **Installed Tool:** `admx-lint`

## Dockerfile Labels

The image includes the following metadata labels:

*   `maintainer`: "florian.stosse@gmail.com"
*   `lastupdate`: "2025-05-29"
*   `author`: "Florian Stosse"
*   `description`: "ADMX linter, built with CMake 4.0.2 base image"
*   `license`: "MIT license"

## Development Dependencies (Builder Stage)

*   `libxerces-c-dev`
*   `xsdcxx`
*   `git`
*   `libboost-program-options-dev`
*   `checkinstall`

## Runtime Dependencies (Final Image)

*   `libxerces-c3.2`
*   `xsdcxx`
*   `libboost-program-options1.83.0`

## License

The Dockerfile and associated scripts are available under the MIT license. The `admx-lint` tool itself has its own license, which should be consulted from its source repository.
