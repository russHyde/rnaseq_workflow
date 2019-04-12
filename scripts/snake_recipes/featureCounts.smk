rule feature_counts:
    message:
        """
        Quantify the counts of aligned reads/fragments for each feature (gene)
        """

    input:
        bam = "{prefix}.bam",
        gtf_gz = rnaseq_reference_params["annotation"]

    output:
        fcount = "{prefix}.fcount",
        fcount_summary = "{prefix}.fcount.summary"

    params:
        "{paired} {extra}".format(
            paired = "-p", extra = rnaseq_program_params["featureCounts"]
        )

    conda:
        "../../envs/featureCounts.yaml"

    resources:
        bigfile = 1

    shell:
        """
        featureCounts {params} -a {input.gtf_gz} -o {output.fcount} {input.bam}
        """


rule shorten_feature_counts:
    message:
        """
        Shorten the output from `featureCounts` for use in `R`
        """

    input:
        "{prefix}.fcount"

    output:
        "{prefix}.fcount.short"

    shell:
        """
        cat {input} | cut -f1,6 > {output}
        """