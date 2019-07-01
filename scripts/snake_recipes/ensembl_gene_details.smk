rule ensembl_gene_details:
    message:
        """
        --- Extract gene-information from ensembl database and ensembl gtf: GC
            content, gene-type etc
        """

    input:
        gtf_gz = ancient(reference_params["annotation"])

    output:
        tsv = os.path.join(
            job_dir, "annotations", "ensembl_gene_details.tsv"
        )

    params:
        ensembl_version = reference_params["annotation_version"],
        ensembl_dataset = reference_params["biomart_dataset"]

    script:
        "../snake_scripts/get_ensembl_gene_details.smk.R"
