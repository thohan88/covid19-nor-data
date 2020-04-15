FROM rocker/verse

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lbzip2 \
    libgdal-dev \
    libgeos-dev \
    libjq-dev \
    liblwgeom-dev \
    libssl-dev \
    libudunits2-dev \
    libpoppler-cpp-dev \
    qpdf

RUN install2.r \ 
    AzureStor \
    crosstalk \
    DT \
    flexdashboard \
    gt \
    here \
    leaflet \
    leaflet.extras \
    pbapply \
    pdftools \
    sf \
    sparkline \
    writexl

RUN Rscript -e 'devtools::install_github("kent37/summarywidget")'