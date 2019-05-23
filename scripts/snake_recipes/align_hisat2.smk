rule hisat2:
    # Assumes paired-ended reads
    input:
        reads = [
            os.path.join(
                read_dirs["trimmed"], "{sequencing_sample_id}_1.fastq.gz"
            ),
            os.path.join(
                read_dirs["trimmed"], "{sequencing_sample_id}_2.fastq.gz"
            )
        ]

    output:
        temp(
            os.path.join(
                align_dirs["initial"], "{sequencing_sample_id}.bam"
            )
        )

    log:
        # log and qc summary are the same; therefore output to the alignment
        # data directory rather than the log directory
        os.path.join(
            align_dirs["initial"], "{sequencing_sample_id}.log"
        )

    params:
        # `idx` is required, `extra` is optional
        idx = reference_params["hisat2_index"],
        extra = "--new-summary {}".format(
            program_params["hisat2"]
        )

    threads: 4

    resources:
        bigfile = 3,
        mem = 4

    wrapper:
        # hisat2 ==2.1.0, samtools == 1.5
        "0.27.1/bio/hisat2"
