# based on
# https://github.com/snakemake-workflows/rna-seq-star-deseq2/blob/master/rules/trim.smk

rule cutadapt_pe:
    message:
        """
        Run `cutadapt` on a pair of paired-end `fastq` files
        """

    input:
        fastq1 = \
            "data/job/raw_fastqs/{study_id}/{sample_id}/{run_id}_{lane_id}_1.fastq.gz",
        fastq2 = \
            "data/job/raw_fastqs/{study_id}/{sample_id}/{run_id}_{lane_id}_2.fastq.gz"

    output:
        fastq1=temp(
            "data/job/trimmed_fastqs/{study_id}/{sample_id}/{run_id}_{lane_id}_1.fastq.gz"
        ),
        fastq2=temp(
            "data/job/trimmed_fastqs/{study_id}/{sample_id}/{run_id}_{lane_id}_2.fastq.gz"
        ),
        qc="data/job/trimmed_fastqs/{study_id}/{sample_id}/{run_id}_{lane_id}.qc.txt"

    params:
        rnaseq_program_params["cutadapt-pe"]

    log:
        "logs/cutadapt/{study_id}/{sample_id}/{run_id}_{lane_id}.log"

    resources:
        bigfile=4

    wrapper:
        # cutadapt_v1.13
        "0.27.1/bio/cutadapt/pe"
