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

get_gene_df_from_gtf <- function(gtf_path, reqd_columns){
  gene_df <- gtf_path %>%
    parse_gtf() %>%
    get_genes_from_gtf() %>%
    as.data.frame()

  gene_df[, reqd_columns]
}

#' Use biomaRt to convert our primary IDs (ensembl-gene IDs) to entrez gene
#' IDs, since clusterProfiler, fgsea and ReactomePA use entrez gene IDs to
#' access annotations.
#'
#' Disregard any ensembl ID that maps to multiple entrez gene IDs
#' Disregard and entrez ID that maps to multiple ensembl gene IDs
#'
get_entrez_id_mapping <- function(feature_ids, mart){
  # returns data-frame (feature_id, entrez_id), where `feature_id` is an
  # ensembl gene id

  # TODO: use homologiser functions within `get_ensembl_gene_details`
  ens_to_ent <- biomaRt::getBM(
    attributes = c("ensembl_gene_id", "entrezgene"),
    filters = "ensembl_gene_id",
    values = feature_ids,
    mart = mart,
    uniqueRows = TRUE
  ) %>%
    dplyr::mutate(entrezgene = as.character(entrezgene)) %>%
    dplyr::rename(
      feature_id = ensembl_gene_id,
      entrez_id = entrezgene
    )

  duplicated_ens_ids <- with(
    ens_to_ent, feature_id[duplicated(feature_id)]
  )
  duplicated_ent_ids <- with(
    ens_to_ent, entrez_id[duplicated(entrez_id)]
  )
  keep_rows <- with(
    ens_to_ent,
    !(feature_id %in% duplicated_ens_ids |
      entrez_id %in% duplicated_ent_ids
    )
  )

  ens_to_ent[keep_rows, ]
}

main <- function(smk){
  # extract a subset of the metadata for gene builds from the transcriptome
  # definition
  gtf_columns <- paste(
    "gene", c("id", "version", "name", "source", "biotype"), sep = "_"
  )
  gene_df <- get_gene_df_from_gtf(smk@input[["gtf_gz"]], gtf_columns)

  # extract gc content from a biomaRt database
  mart <- get_database(smk)
  gc_percent <- reeq::get_gc_percent(
    gene_df[["gene_id"]], mart
  )

  entrez_id_df <- get_entrez_id_mapping(
    feature_ids = gc_percent[["feature_id"]],
    mart = mart
  )

  # join the gc content to the gene-build metadata and write it to a file
  results <- merge(
    gc_percent, gene_df, by.x = "feature_id", by.y = "gene_id"
  ) %>%
  merge(
    ens_annots, entrez_id_df, by = "feature_id", all.x = TRUE
  )

  readr::write_tsv(
    results,
    path = smk@output[["tsv"]]
  )
}

# ----

main(snakemake)

