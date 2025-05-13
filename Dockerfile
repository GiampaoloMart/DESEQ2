# Dockerfile per DESeq2 usando l'immagine Rocker, più stabile per l'ambiente R
FROM rocker/r-ver:4.3.2

LABEL org.opencontainers.image.authors="Giampaolo <your-email@example.com>"
LABEL org.opencontainers.image.description="Docker image with R and DESeq2 for RNA-Seq analysis"

# Imposta i repository APT non-interattivi
ENV DEBIAN_FRONTEND=noninteractive

# Aggiorna i repository e installa le dipendenze essenziali
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-utils \
        ca-certificates \
        locales \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Imposta la localizzazione per evitare problemi con caratteri non-ASCII
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    /usr/sbin/update-locale LANG=en_US.UTF-8

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Installa le librerie di sistema essenziali per R e i pacchetti Bioconductor
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        file \
        gfortran \
        git \
        libcurl4-openssl-dev \
        libssl-dev \
        libxml2-dev \
        libudunits2-dev \
        libmariadb-dev \
        libpq-dev \
        xorg \
        libx11-dev \
        libglu1-mesa-dev \
        libpng-dev \
        libcairo2-dev \
        libhdf5-dev \
        libpcre2-dev \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Installa BiocManager (che è necessario per installare DESeq2 e altri pacchetti Bioconductor)
RUN R -e "install.packages('BiocManager', repos='https://cran.rstudio.com/')"

# Installa prima le principali dipendenze di DESeq2
RUN R -e "BiocManager::install(c('S4Vectors', 'IRanges', 'GenomicRanges', 'SummarizedExperiment'), update = FALSE, ask = FALSE)"

# Installa DESeq2 con le sue dipendenze
RUN R -e "BiocManager::install('DESeq2', update = FALSE, ask = FALSE)"

# Verifica che DESeq2 sia stato installato correttamente
RUN R -e "library(DESeq2); cat('DESeq2 versione:', as.character(packageVersion('DESeq2')), '\n')"

# Installa pacchetti essenziali per l'analisi RNA-Seq
RUN R -e "BiocManager::install(c(\
    'apeglm', \
    'IHW', \
    'vsn', \
    'AnnotationDbi', \
    'org.Hs.eg.db', \
    'org.Mm.eg.db'), \
    update = FALSE, \
    ask = FALSE)"

# Installa pacchetti per visualizzazione e manipolazione dati
RUN R -e "install.packages(c(\
    'ggplot2', \
    'pheatmap', \
    'RColorBrewer', \
    'data.table', \
    'dplyr'), \
    repos='https://cran.rstudio.com/')"

# Crea directory per i dati
RUN mkdir -p /data
WORKDIR /data

# Comando predefinito quando si avvia il container
CMD ["R"]
