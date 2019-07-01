rule feature_counts:
    message:
        """
        Quantify the counts of aligned reads/fragments for each feature (gene)
        """

    input:
        bam = os.path.join(
            quantify_dirs["input"], "{sequencing_sample_id}.bam"
        ),
        gtf_gz = ancient(reference_params["annotation"])

    output:
        # For typical RNA-Seq analysis we want to quantify singly-mapping reads
        # and include any readpairs that are marked as PCR duplicates (because
        # they are typically due to high coverage over short highly-expressed
        # genes, rather that to PCR-duplication)
        with_dups = [
            os.path.join(
                quantify_dirs["with_dups"],
                "{sequencing_sample_id}.fcount"
            ),
            os.path.join(
                quantify_dirs["with_dups"],
                "{sequencing_sample_id}.fcount.summary"
            )
        ],
        # But for QC purposes, we want to know whether there are any genes that
        # have wildly different coverage when we remove PCR-duplicates;
        without_dups = [
            os.path.join(
                quantify_dirs["without_dups"],
                "{sequencing_sample_id}.fcount"
            ),
            os.path.join(
                quantify_dirs["without_dups"],
                "{sequencing_sample_id}.fcount.summary"
            )
        ],
        # And, by quantifying the primary alignments of all read pairs,
        # including multi-mapping reads, we can assess the contribution of rRNA
        # contamination etc to the total coverage (since rRNA reads align to
        # various places in the genome)
        with_multimaps = [
            os.path.join(
                quantify_dirs["with_multimaps"],
                "{sequencing_sample_id}.fcount"
            ),
            os.path.join(
                quantify_dirs["with_multimaps"],
                "{sequencing_sample_id}.fcount.summary"
            )
        ]

    params:
        "{paired} {extra}".format(
            paired = "-p", extra = program_params["featureCounts"]
        )

    conda:
        "../../envs/featureCounts.yaml"

    resources:
        bigfile = 1

    shell:
        # We only count multimapping reads once when summarising using
        # featureCOunts (--primary); this is for use in the QC report. We do
        # this even if the multimapping reads don't enter into the output
        # featureCounts tables
        """
        featureCounts --primary {params} \
            -a {input.gtf_gz} -o {output.with_dups[0]} {input.bam};

        featureCounts --ignoreDup --primary {params} \
            -a {input.gtf_gz} -o {output.without_dups[0]} {input.bam};

        featureCounts -M --primary {params} \
            -a {input.gtf_gz} -o {output.with_multimaps[0]} {input.bam};
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
        # Note that `cut -f789-` takes all columns from 789 onwards
        """
        cat {input} | cut -f1,6- > {output}
        """
