# based on
# https://github.com/snakemake-workflows/rna-seq-star-deseq2/blob/master/rules/trim.smk

rule cutadapt_pe:
    message:
        """
        Run `cutadapt` on a pair of paired-end `fastq` files
        """

    input:
        fastq1 = os.path.join(
            read_dirs["raw"], "{sequencing_sample_id}_1.fastq.gz"
        ),
        fastq2 = os.path.join(
            read_dirs["raw"], "{sequencing_sample_id}_2.fastq.gz"
        )

    output:
        fastq1 = temp(
            os.path.join(
                read_dirs["trimmed"], "{sequencing_sample_id}_1.fastq.gz"
            )
        ),
        fastq2 = temp(
            os.path.join(
                read_dirs["trimmed"], "{sequencing_sample_id}_2.fastq.gz"
            )
        ),
        qc = os.path.join(
            read_dirs["trimmed"], "{sequencing_sample_id}.qc.txt"
        )

    params:
        program_params["cutadapt-pe"]

    log:
        "logs/cutadapt/{sequencing_sample_id}.log"

    resources:
        bigfile=4

    wrapper:
        # cutadapt_v1.13
        "0.27.1/bio/cutadapt/pe"
