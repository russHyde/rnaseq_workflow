Add requirements to cover:

- requirements for `get_ensembl_gene_details.smk.R`
    - biomaRt
    - magrittr
    - readr
    - rtracklayer
    - reeq

- requirements for reeq:
    - bioconductor-[edger|biobase|biomart|tidyr]

- requirements for `rmarkdown.smk`
    - rpy2
    - r-rmarkdown

- requirements for notebook.Rmd
    - r-here
    - r-readr
    - r-ggplot2
    - r-plotly (for html)

- requirements for working in rstudio
    - r-catools
    - r-formatr

- requirements for running the workflow
    - snakemake etc
