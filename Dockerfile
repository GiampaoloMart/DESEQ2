# Dockerfile per DESeq2 con gestione robusta delle dipendenze
# Utilizziamo un tag specifico per r-base per maggiore stabilità
FROM r-base:4.3.2

LABEL org.opencontainers.image.authors="Giampaolo <your-email@example.com>"
LABEL org.opencontainers.image.description="Docker image with R and DESeq2 for RNA-Seq analysis"

# Aggiorniamo prima il sistema e installiamo software-properties-common
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    gpg-agent \
    apt-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Installiamo le dipendenze di sistema un gruppo alla volta per individuare eventuali problemi
# Prima le dipendenze essenziali per R
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    libcurl4 \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Poi le librerie di compressione e utilità
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Librerie per PCRE e HDF5
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpcre2-dev \
    libpcre3-dev \
    libhdf5-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Librerie grafiche e interfaccia utente X11
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    libpng-dev \
    libcairo2-dev \
    libxt-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Librerie matematiche e scientifiche
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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

# Installa prima le dipendenze di base di DESeq2
RUN R -e "BiocManager::install(c('S4Vectors', 'IRanges', 'GenomicRanges', 'SummarizedExperiment'), dependencies=TRUE)"

# Installa DESeq2
RUN R -e "BiocManager::install('DESeq2', dependencies=TRUE)"

# Verifica che DESeq2 sia stato installato correttamente
RUN R -e "library(DESeq2); cat('DESeq2 versione:', as.character(packageVersion('DESeq2')), '\n')"

# Installa pacchetti aggiuntivi utili per l'analisi RNA-Seq in gruppi separati
# per gestire meglio gli errori di installazione

# Gruppo 1: Pacchetti base per analisi RNA-Seq
RUN R -e "BiocManager::install(c('apeglm', 'IHW', 'vsn'), dependencies=TRUE)"

# Gruppo 2: Pacchetti per visualizzazione
RUN R -e "BiocManager::install(c('EnhancedVolcano', 'pheatmap', 'genefilter', 'RColorBrewer'), dependencies=TRUE)"

# Gruppo 3: Pacchetti per importazione dati
RUN R -e "BiocManager::install(c('tximport', 'tximportData', 'GenomicFeatures'), dependencies=TRUE)"

# Gruppo 4: Database di annotazione
RUN R -e "BiocManager::install(c('AnnotationDbi', 'org.Hs.eg.db', 'org.Mm.eg.db'), dependencies=TRUE)"

# Gruppo 5: Pacchetti CRAN per manipolazione dei dati
RUN R -e "install.packages(c('tidyverse', 'data.table', 'here'), repos='https://cran.rstudio.com/')"

# Gruppo 6: Pacchetti CRAN per visualizzazione e parallelizzazione
RUN R -e "install.packages(c('BiocParallel', 'ggplot2', 'ggrepel'), repos='https://cran.rstudio.com/')"

# Crea directory per i dati
RUN mkdir -p /data
WORKDIR /data

# Imposta variabili d'ambiente
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Comando predefinito quando si avvia il container (R interattivo)
CMD ["R"]
