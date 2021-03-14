# Flei
**Caution: This is in a very early stage. We might introduce major structural changes at any time, so don't use it
in production yet. You're welcome to try and start [discussions](https://github.com/quietschfidel/flei/discussions)
if you need help or have ideas on how Flei could be improved.**

Flei is a concept for dockerized dev and CI environments. The main goals are:
* Reliability and reproducibility for the execution of scripts in development and CI pipelines.
* Minimize prerequisites for developer machines and CI runners.
* Keep actual CI configuration slim to be as independent as possible from the used CI system. This makes
  it easy to switch to another one and also makes most of the pipeline steps simple to execute locally,
  which improves debugging issues.
* Developer workflows that give meaningful feedback to the developers if something goes wrong and help
  them to get everything up and running in a comfortable way.
* Keep all flexibility for the developers. They should still be able to run everything natively, as they
  are used to for debugging, performance reasons and similar.
* Reduce redundancy for development and build scripts in multiple projects.
  
We try to solve those problems with Flei by providing tools and recommended practices, that can be used to
create the development and build scripts.

## Getting Started
### Prerequisites
* [docker](https://docs.docker.com/get-started/)
* [Docker Compose](https://docs.docker.com/compose/)
* [Bash](https://savannah.gnu.org/projects/bash/)
* [curl](https://curl.se/) (optional for more simple setup)

### Setup
The most simple way to setup Flei is to run the following command in the root directory of the project
you want to use Flei in. Be aware, that you need `curl` for that.
```bash
  mkdir -p ./flei && \
  curl -L "https://raw.githubusercontent.com/quietschfidel/flei/main/src/runner/run.sh" -o ./flei/run.sh && \
  chmod +x ./flei/run.sh
```

If you don't have `curl` you can do the steps manually:
* Create a subdirectory called `flei` (usually `mkdir -p ./flei`)
* Download the `run.sh` script from https://raw.githubusercontent.com/quietschfidel/flei/main/src/runner/run.sh
* Copy the downloaded `run.sh` file into the created `flei` directory
* Make the script executable (usually `chmod +x ./flei/run.sh`)

### Create Your First Command
* Create a subdirectory inside of the `flei` directory called `commands` (usually `mkdir -p ./flei/commands`)
* Create a file inside of the `commands` directory. In our example we call it `hello.sh`
* Put the following content inside of the `hello.sh`
  ```bash
  flei_command() {
    echo "hello world!"
  }
  ```
* Test your new command by running `./flei/run.sh hello`

To quickly do all the steps run the following script in your project root:
```bash
mkdir -p ./flei/commands && \
printf 'flei_command() {\n  echo "hello world!"\n}' > ./flei/commands/hello.sh && \
./flei/run.sh hello
```

### Which Files to Add to Version Control
All files beside the ones inside of the `.flei` directory should be added to version control. You should still
not change anything in the `run.sh`, since it might get overwritten while doing updates. But it's required inside
of the repository as an entry point for Flei.