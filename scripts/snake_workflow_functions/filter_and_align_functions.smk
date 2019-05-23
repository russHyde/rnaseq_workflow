# Helper functions for use in the snakemake workflow for the `filter_and_align`
# substep.

def get_cutadapt_reports(sequencing_samples, read_dirs):
    """
    Each cutadapt run generates a pair of trimmed fastq files and a report
    file. If the trimmed fastqs are `xxx_<read_direction>.fastq.gz` then the
    log file is `xxx_.qc.txt`.

    This returns the file paths for all cutadapt reports generated during
    trimming of the current dataset.
    """
    cutadapt_reports = expand(
        join(
            "{directory_prefix}", "{unit.study_id}", "{unit.sample_id}",
            "{unit.run_id}_{unit.lane_id}.qc.txt"
        ),
        directory_prefix=read_dirs["trimmed"],
        unit=sequencing_samples.itertuples()
    )
    return cutadapt_reports


def get_fastqc_reports(sequencing_samples, fastqc_dirs):
    fastqc_reports = expand(
        join(
            "{directory_prefix}", "{unit.study_id}", "{unit.sample_id}",
            "{unit.run_id}_{unit.lane_id}_{read}_fastqc.{ext}"
        ),
        directory_prefix=[fastqc_dirs["raw"], fastqc_dirs["trimmed"]],
        unit=sequencing_samples.itertuples(),
        read=[1, 2],
        ext=["html", "zip"]
    )
    return fastqc_reports


def get_hisat2_reports(sequencing_samples, align_dirs):
    """
    The log from each hisat2 run is put into the same directory as the
    alignment bam files (xxx.bam -> xxx.log)

    This returns the file paths for all hisat2 reports generated during
    alignment.
    """
    hisat2_reports = expand(
        join(
            "{directory_prefix}", "{unit.study_id}", "{unit.sample_id}",
            "{unit.run_id}_{unit.lane_id}.log"
        ),
        directory_prefix=align_dirs["initial"],
        unit=sequencing_samples.itertuples()
    )
    return hisat2_reports


def get_filter_and_align_reports(
        sequencing_samples, read_dirs, fastqc_dirs, align_dirs
    ):
    """
    A `fastqc` report for each fastq.gz in the current dataset is generated
    (one for each untrimmed and one for each trimmed file);

    A `cutadapt` report is generated for each pair of `fastq.gz` files in the
    current dataset.

    A `hisat2` alignment report is generated for each pair of `fastq.gz` files
    in the current dataset.

    This returns the combined set of filepaths for these reports across all
    `fastq` files in this dataset.
    """
    fastqc_reports = get_fastqc_reports(
        sequencing_samples=sequencing_samples, fastqc_dirs=fastqc_dirs
    )
    cutadapt_reports = get_cutadapt_reports(
        sequencing_samples=sequencing_samples, read_dirs=read_dirs
    )
    hisat2_reports = get_hisat2_reports(
        sequencing_samples=sequencing_samples, align_dirs=align_dirs
    )
    return fastqc_reports + cutadapt_reports + hisat2_reports
