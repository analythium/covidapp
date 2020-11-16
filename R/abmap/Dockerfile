# R > 4.0.x on Ubuntu 18.04 (bionic)
FROM openanalytics/r-shiny

LABEL org.label-schema.license="MIT" \
      org.label-schema.vcs-url="https://analythium.io" \
      org.label-schema.vendor="Analythium Solutions Inc." \
      maintainer="Peter Solymos <peter@analythium.io>"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    software-properties-common
RUN add-apt-repository ppa:ubuntugis/ubuntugis-unstable \
  && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libgdal-dev \
    libgeos-dev \
    libproj-dev \
  && rm -rf /var/lib/apt/lists/*

RUN install2.r -e remotes renv

# Set Shiny address and port in Rprofile.site
RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0', renv.consent = TRUE, HTTPUserAgent = sprintf('R/%s R (%s)', getRversion(), paste(getRversion(), R.version$platform, R.version$arch, R.version$os))))" > /usr/lib/R/etc/Rprofile.site

## non-root user

# Create a non-root user
RUN addgroup --system app \
    && adduser --system --ingroup app app

WORKDIR /home/app

# copying only the app folder avoid copying non-intended info
COPY app .

# Copy lock file for renv
# repos is set to bionic RSPM
COPY ./renv.lock .
RUN Rscript -e "renv::restore(lockfile = '/home/app/renv.lock', repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/bionic/latest'), library = '/usr/local/lib/R/site-library', prompt = FALSE)"
RUN rm -f renv.lock

WORKDIR /home/app

RUN chown app:app -R /home/app

USER app

# Expose Shiny port
EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/home/app')"]
