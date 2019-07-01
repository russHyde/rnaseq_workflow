include: "readgroups_hisat2_bowtie2.smk"


def extra_hisat2_params(wildcards):
    """
    --- Obtains parameters for use during hisat2 alignment.

        The parameters are
        - command-line options (obtained from a config file via a dictionary
          `program_params` that the user should setup);
        - read-group info (constructed from the sample_id, run_id, lane_id etc
          that are present in the `sequencing_samples` dictionary that the user
          should construct);
        - genomic / transcriptomic references do not need to be included here.
    """
    cli_args = program_params["hisat2"]
    rg = " ".join(read_group(wildcards, sequencing_samples))

    return "--new-summary {} {}".format(cli_args, rg)


rule hisat2:
    # Assumes paired-ended reads
    input:
        reads = [
            os.path.join(
                read_dirs["trimmed"],
                "{study_id}", "{sample_id}", "{run_id}_{lane_id}_1.fastq.gz"
            ),
            os.path.join(
                read_dirs["trimmed"],
                "{study_id}", "{sample_id}", "{run_id}_{lane_id}_2.fastq.gz"
            )
        ]

    output:
        temp(
            os.path.join(
                align_dirs["initial"],
                "{study_id}", "{sample_id}", "{run_id}_{lane_id}.bam"
            )
        )

    log:
        # log and qc summary are the same; therefore output to the alignment
        # data directory rather than the log directory
        os.path.join(
            align_dirs["initial"],
            "{study_id}", "{sample_id}", "{run_id}_{lane_id}.log"
        )

    params:
        # `idx` is required, `extra` is optional
        idx = reference_params["hisat2_index"],
        extra = extra_hisat2_params

    threads: 4

    resources:
        bigfile = 3,
        mem = 4

    wrapper:
        # hisat2 ==2.1.0, samtools == 1.5
        "0.27.1/bio/hisat2"
