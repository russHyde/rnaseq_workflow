# based on
# https://github.com/snakemake-workflows/rna-seq-star-deseq2/blob/master/rules/trim.smk

def get_raw_fastq(wildcards):
    """
    The index into the `rnaseq_samples` table is the tuple
    (study_id, sample_id, run_id, lane_id). The raw fastq files are
    present in the `fq1` and `fq2` columns of that table.
    """
    index_tuple = (
        wildcards.study_id, wildcards.sample_id, wildcards.run_id,
        wildcards.lane_id
    )
    raw_fastqs = rnaseq_samples.loc[index_tuple, ["fq1", "fq2"]]
    return raw_fastqs


rule cutadapt_pe:
    input:
        get_raw_fastq

    output:
        fastq1=temp(
            "data/job/{study_id}/{sample_id}/{run_id}_{lane_id}_1.fastq.gz"
        ),
        fastq2=temp(
            "data/job/{study_id}/{sample_id}/{run_id}_{lane_id}_2.fastq.gz"
        ),
        qc="data/job/{study_id}/{sample_id}/{run_id}_{lane_id}.qc.txt"

    params:
        rnaseq_program_params["cutadapt-pe"]

    log:
        "logs/cutadapt/{study_id}/{sample_id}/{run_id}_{lane_id}.log"

    resources:
        bigfile=4

    wrapper:
        # cutadapt_v1.13
        "0.27.1/bio/cutadapt/pe"
