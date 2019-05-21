rule hisat2:
    # Assumes paired-ended reads
    input:
        reads = [
            os.path.join(
                read_dirs["trimmed"],
                "{study_id}/{sample_id}/{run_id}_{lane_id}_1.fastq.gz"
            ),
            os.path.join(
                read_dirs["trimmed"],
                "{study_id}/{sample_id}/{run_id}_{lane_id}_2.fastq.gz"
            )
        ]

    output:
        temp("data/job/align/{study_id}/{sample_id}/{run_id}_{lane_id}.bam")

    log:
        "logs/hisat2/{study_id}/{sample_id}/{run_id}_{lane_id}.bam"

    params:
        # `idx` is required, `extra` is optional
        idx = reference_params["hisat2_index"],
        extra = rnaseq_program_params["hisat2"]

    threads: 4

    resources:
        bigfile = 3,
        mem = 4

    wrapper:
        # hisat2 ==2.1.0, samtools == 1.5
        "0.27.1/bio/hisat2"
