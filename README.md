# 🦋 DSEA Infrastructure

This repository contains infrastructure and orchestration for the DSEA system.

# Getting Started 🚀
To run the project locally, you would have to download zip file with the repository or clone it to your computer. ✨

## Setup and Running ⚠️

What things do you need to do in order to run our project locally?

* Docker
* Installed [.git](https://git-scm.com/) on your computer.
* Code Editor of your choice.
* (optional) Make sure submodules are initialized

```bash
git submodule update --init --recursive
```

## Installation And Preparation 🔮

1. Make sure you have all the things listed in the previous section. Then clone our repository to your computer:

```
git clone https://github.com/Quiddlee/dsea-infra.git
```

2. Navigate into project root and create a local environment file:

``` bash
cp .env.example .env
```

3. Edit `.env` and fill in required values:
* PostgreSQL credentials
* OpenAI API key
* Telegram bot token

You can find ```.env.example``` as an example file in the project root.

## Running the Stack 🥑

From the repository root:
``` bash
./scripts/up.sh
```

This will:
* Generate runtime .env.docker files for services
* Start all services using Docker Compose
