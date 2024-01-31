# Introduction to Docker

## About Docker

When building a system consisting of multiple components like a database, a processing server, a messaging application, etc., we need to always track the dependencies of these components with each other and with the underlying OS and hardware on which the system is run. This matrix of compatibilities is called the *Matrix from Hell* because it is difficult to track and time-consuming.

*Docker* provides an easier way to manage such a system wherein each component can be put inside a container with the required libraries and dependencies.

A Docker *container* is an isolated environment with its own processes, networks, and file system mounts similar to a virtual machine (VM). A key difference to VMs is that all containers share the OS kernel.

If Docker is running on an Ubuntu machine, it can install any operating system in its container as long as they share the same OS kernel i.e. Linux.

When we create a Linux Docker container on a Windows machine, it is run on a Linux VM as the underlying Windows kernel is different.

Initially, the Docker Toolbox was available for Mac. It used to run a container on a Linux VM installed in VirtualBox on the Mac OS. This toolbox consisted of:

- Oracle VirtualBox
- Docker Engine
- Docker Machine
- Docker Compose
- Kitematic GUI
- With Docker Desktop, a Linux VM is created using Apple’s HyperKit visualisation technology.

As a technology, containers have been around for more than a decade. Docker’s key contribution is to provide a high-level tools that ease the process of creating and maintaining containers.

## Advantages

Using Docker contains is beneficial in the development and maintenance of problem because:

- It allows us to experiment locally with the same configuration that is used in production.
- Integration testing of various components of our data processing pipeline is made easier with the use of containers (CI/CD).
- If we encounter any issues in our pipeline, we can reproduce them easily using a container which already has a similar environment to production.
- Docker also makes it convenient to run data pipelines in the cloud (AWS Batch, Kubernetes jobs).
- It also supports Apache Spark and Serverless (AWS Lambda, Google Functions) conveniently.

## Testing Docker installation

On a Mac, we can install [Docker Desktop](https://www.docker.com/products/docker-desktop), sign in to our free Docker account, and then start the application. To test the installation, open a terminal and run the following command:

```bash
docker run hello-world

```

If the installation was successful, we should see the following message:

```bash
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 <https://hub.docker.com/>

For more examples and ideas, visit:
 <https://docs.docker.com/get-started/>

```

## Running a container

Let us run Python 3.8 in a container. We can do this using the `docker run` command as follows:

```bash
docker run -it python:3.8

```

There are a few things to pay attention to in the command above. The `docker run` command first checks if a Docker image for the application we are trying to run is available locally. If not, it automatically downloads (formally known as *pull*s) it for us.

The `-i` flag makes the container start in interactive mode. If we do not specify it, the container will start and stop immediately without waiting for any input from us.

- `t` allocates a terminal, also called a *pseudo-TTY*, to our container.

We specify the type of container we want to create after specifying all the arguments. Here, we want a `python` container and specifically, version `3.8`. In Docker parlance, the former is known as a *tag* and the latter is a *sub-tag*.

If the above code is run correctly, the output we should see is as follows:

```bash
Python 3.8.12 (default, Dec 21 2021, 07:14:57)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>>

```

If we wish to install specific packages (like Pandas), we can specify a separate entry point to our container. Here, we specify the `bash` shell as an entry point:

```bash
docker run -it --entrypoint=bash python:3.8

```

We can then first execute

```bash
pip install pandas

```

and then launch Python, import `pandas`, and check its version.

```bash
Python 3.8.12 (default, Dec 21 2021, 07:14:57)
[GCC 10.2.1 20210110] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import pandas as pd
>>> pd.__version__
'1.3.5'
>>>

```

## Exit a container

We can exit a container using the `Cmd + D` keyboard shortcut. When we then run the container again, it will create a new container by default which will not include any modifications, like externally installed packages, we did in the previous run.

## `Dockerfile`

If we are creating data pipelines in Python that always need the Pandas library, we can create a new image based on the Python image using a special file called `Dockerfile`. Following is a Dockerfile that installs Pandas.

```
FROM python:3.8

RUN pip install pandas

ENTRYPOINT [ "bash" ]

```

In the first line of this file, we specify the base image to use for creating a new image. With `RUN`, we list the commands to execute before launching a container. Finally, we specify the default entry point for our container.

To build an image using this Dockerfile, we run the command:

```bash
docker build -t test:pandas .

```

In this command, the assumption is that we are running it from the same location as the Dockerfile. Hence, we specify the path to Dockerfile as `.`. The `-t` flag is used to specify tags and sub-tags for our new image.

When we run it for the first time, the output should look as follows:

```bash
[+] Building 12.9s (6/6) FINISHED
 => [internal] load build definition from Dockerfile                                                                                                0.1s
 => => transferring dockerfile: 149B                                                                                                                0.0s
 => [internal] load .dockerignore                                                                                                                   0.0s
 => => transferring context: 2B                                                                                                                     0.0s
 => [internal] load metadata for docker.io/library/python:3.8                                                                                       0.0s
 => [1/2] FROM docker.io/library/python:3.8                                                                                                         0.1s
 => [2/2] RUN pip install pandas                                                                                                                   11.7s
 => exporting to image                                                                                                                              1.0s
 => => exporting layers                                                                                                                             1.0s
 => => writing image sha256:915e03413fe28b54454ba03262dd2419deaeb1e331513360e1ae0c3fdac3f25a                                                        0.0s
 => => naming to docker.io/library/test:pandas                                                                                                      0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them

```

We can run our newly created image as follows:

```bash
docker run -it test:pandas

```

Doing so will open a bash shell in which we can run Python and check if Pandas is installed.

## Simple pipeline

Let us now create a simple Python script that we will execute with Docker. In this script called `pipeline.py`, we will take two arguments (mean and standard deviation) while running the container, generate 10 random number from a Gaussian distribution, create a Pandas data frame, and print it out.

```python
import numpy as np
import pandas as pd
import sys
from tabulate import tabulate

mu: float = float(sys.argv[1])
sigma: float = float(sys.argv[2])

np.random.seed(42)
df = pd.DataFrame({
    'date': pd.date_range('2022-01-01', periods=10, freq='1D'),
    'value': mu + sigma * np.random.randn(10)
})

print(tabulate(df, headers='keys', tablefmt='psql'))

```

In the code above, we specify the seed so that we can reproduce the same output during our experimentation.

The Dockerfile to run this script will look as follows:

```
FROM python:3.8

RUN pip install numpy pandas tabulate

WORKDIR /app
COPY generate_random_df.py generate_random_df.py

ENTRYPOINT ["python", "generate_random_df.py"]

```

Here, after specifying the base image, we install the required packages - NumPy, Pandas, and tabulate. Then, we specify the working directory (`/app`) in our container. If this directory does not exist, Docker will create one for us.

Next, we copy our script into the container. Here, the assumption is that the script is located in the same directory as the Dockerfile. If not, we need to specify the complete path. Inside the container, the script will be placed inside the specified working directory (`/app`).

When we run the container, we want it to execute our Python script. Hence, we specify the entry point as `[“python”, “generate_random_df.py”]`. While running the container, we can specify the mean and standard deviation values as follows:

```bash
docker run -it test:simple_random_df 4 2

```

Before run this container, we need to ensure that we build an image using our Dockerfile. In the command above, we have assumed the image to have the tag `test:simple_random_df`. The output should look as follows:

```bash
+----+---------------------+---------+
|    | date                |   value |
|----+---------------------+---------|
|  0 | 2022-01-01 00:00:00 | 4.99343 |
|  1 | 2022-01-02 00:00:00 | 3.72347 |
|  2 | 2022-01-03 00:00:00 | 5.29538 |
|  3 | 2022-01-04 00:00:00 | 7.04606 |
|  4 | 2022-01-05 00:00:00 | 3.53169 |
|  5 | 2022-01-06 00:00:00 | 3.53173 |
|  6 | 2022-01-07 00:00:00 | 7.15843 |
|  7 | 2022-01-08 00:00:00 | 5.53487 |
|  8 | 2022-01-09 00:00:00 | 3.06105 |
|  9 | 2022-01-10 00:00:00 | 5.08512 |
+----+---------------------+---------+

```

## References

- [Introduction to Docker](https://www.youtube.com/watch?v=EYNwNlOrpr0&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=4)
- [Docker Tutorial for Beginners - A Full DevOps Course on How to Run Applications in Containers](https://www.youtube.com/watch?v=fqMOX6JJhGo)