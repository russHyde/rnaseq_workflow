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
        temp(align_dirs["initial"], "{sequencing_sample_id}.bam")

    log:
        "logs/hisat2/{sequencing_sample_id}.bam"

    params:
        # `idx` is required, `extra` is optional
        idx = reference_params["hisat2_index"],
        extra = program_params["hisat2"]

    threads: 4

    resources:
        bigfile = 3,
        mem = 4

    wrapper:
        # hisat2 ==2.1.0, samtools == 1.5
        "0.27.1/bio/hisat2"
