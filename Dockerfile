# Dockerfile per DESeq2 compatibile con l'ambiente HPC esistente
# Base minimale con R 4.4.0 per essere compatibile con lo script rstudio-run esistente

FROM r-base:4.4.0

LABEL maintainer="User <user@example.com>"
LABEL description="Docker image with R 4.4.0 and DESeq2 for RNA-Seq analysis, compatibile con HPC"

# Installa le dipendenze di sistema necessarie
RUN apt-get update && apt-get install -y --no-install-recommends \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libbz2-dev \
    liblzma-dev \
    libpcre3-dev \
    libhdf5-dev \
    zlib1g-dev \
    libpng-dev \
    libcairo2-dev \
    libxt-dev \
    libgit2-dev \
    libglpk-dev \
    libgfortran5 \
    libreadline-dev \
    libblas-dev \
    liblapack-dev \
    libopenblas-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installa BiocManager
RUN R -e "install.packages('BiocManager', repos='https://cran.rstudio.com/')"

# Installa DESeq2 e le sue dipendenze
RUN R -e "BiocManager::install('DESeq2', dependencies=TRUE)"

# Installa pacchetti aggiuntivi utili per l'analisi RNA-Seq
RUN R -e "BiocManager::install(c('apeglm', 'IHW', 'vsn', 'EnhancedVolcano', 'pheatmap', 'genefilter', 'RColorBrewer'))"

# Installa alcuni database di annotazione comuni
RUN R -e "BiocManager::install(c('AnnotationDbi', 'org.Hs.eg.db', 'org.Mm.eg.db'))"

# Installa pacchetti per la manipolazione dei dati e visualizzazione
RUN R -e "install.packages(c('tidyverse', 'data.table', 'here', 'BiocParallel'), repos='https://cran.rstudio.com/')"

# Verifica che DESeq2 sia stato installato correttamente
RUN R -e "library(DESeq2); cat('DESeq2 versione:', as.character(packageVersion('DESeq2')), '\n')"

# Crea directory per i dati
RUN mkdir -p /data
WORKDIR /data

# Imposta variabili d'ambiente
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Comando predefinito quando si avvia il container (R interattivo)
CMD ["R"]
