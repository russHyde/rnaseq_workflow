# This script should only be called by snakemake

library(biomaRt)
library(magrittr)
library(readr)
library(rtracklayer)
library(reeq)

# ----

parse_gtf <- function(gtf_path){
  gtf <- rtracklayer::import(gtf_path)
}

get_genes_from_gtf <- function(gtf){
  gtf[which(gtf$type == "gene"), ]
}

get_database <- function(smk){
  biomaRt::useEnsembl(
    "ensembl",
    version = smk@params[["ensembl_version"]],
    dataset = smk@params[["ensembl_dataset"]]
  )
}

get_gene_df_from_gtf <- function(smk, reqd_columns){
  gene_df <- smk@input[["gtf_gz"]] %>%
    parse_gtf() %>%
    get_genes_from_gtf() %>%
    as.data.frame()

  gene_df[, reqd_columns]
}

main <- function(smk){
  # extract a subset of the metadata for gene builds from the transcriptome
  # definition
  gtf_columns <- paste(
    "gene", c("id", "version", "name", "source", "biotype"), sep = "_"
  )
  gene_df <- get_gene_df_from_gtf(smk, gtf_columns)

  # extract gc content from a biomaRt database
  mart <- get_database(smk)
  gc_percent <- reeq::get_gc_percent(
    gene_df$gene_id, mart
  )

  # join the gc content to the gene-build metadata and write it to a file
  results <- merge(
    gc_percent,
    gene_df,
    by.x = "feature_id",
    by.y = "gene_id"
  )

  readr::write_tsv(
    results,
    path = smk@output[["tsv"]]
  )
}

# ----

main(snakemake)

