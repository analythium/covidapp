# App

App template to base Analythium Shiny apps on.

## Features

- Use shinydashboard
- MIT license
- Footer with Disclaimer and Limitations
- GA tracking
- GitLab CICD
- project setup [using renv](https://rstudio.github.io/renv/articles/docker.html#creating-docker-images-with-renv)
- [non-root user](https://engineering.bitnami.com/articles/why-non-root-containers-are-important-for-security.html) in Docker

## Workflow

1. Add all app related files to `/app` folder
2. Use `renv::snapshot(type="explicit")` to record dependencies/versions from the `DESCRIPTION` file

## Docker

Pull:

```
docker pull docker.pkg.github.com/analythium/covidapp/abmap
```

Build:

```
docker login docker.pkg.github.com

docker build -t docker.pkg.github.com/analythium/covidapp/abmap .
```

Test locally:

```
docker run -p 4000:3838 docker.pkg.github.com/analythium/covidapp/abmap
```

then visit `127.0.0.1:4000`.

MIT (c) 2019-2020 [Analythium Solutions Inc.](https://analythium.io)
