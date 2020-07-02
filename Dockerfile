FROM rocker/verse

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    lbzip2 \
    libgdal-dev \
    libgeos-dev \
    libjq-dev \
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

# Add Python environment
ENV WORKON_HOME /opt/virtualenvs
ENV PYTHON_VENV_PATH $WORKON_HOME/r-python

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpython3-dev \
    python3-venv \
    language-pack-nb && \
    rm -rf /var/lib/apt/lists/*
  
RUN python3 -m venv ${PYTHON_VENV_PATH}
RUN chown -R rstudio:rstudio ${WORKON_HOME}
ENV PATH ${PYTHON_VENV_PATH}/bin:${PATH}
RUN echo "PATH=${PATH}" >> /usr/local/lib/R/etc/Renviron && \
    echo "WORKON_HOME=${WORKON_HOME}" >> /usr/local/lib/R/etc/Renviron && \
    echo "RETICULATE_PYTHON_ENV=${PYTHON_VENV_PATH}" >> /usr/local/lib/R/etc/Renviron

# Add pip-packages
RUN pip install --upgrade pip && \
  pip install --no-cache-dir pandas==1.0.5 pyYAML==5.3.1 requests==2.24.0 openpyxl==3.0.4 xlrd==1.2.0 lxml==4.5.1

# Install reticulate
RUN install2.r \ 
  reticulate
