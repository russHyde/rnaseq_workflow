# Helper functions for use in the snakemake workflow for the `filter_and_align`
# substep.

def get_samples_by_lane(sequencing_samples):
    samples = expand(
        join(
            "{unit.study_id}", "{unit.sample_id}",
            "{unit.run_id}_{unit.lane_id}"
        ),
        unit=sequencing_samples.itertuples()
    )
    return list(set(samples))


def get_samples_by_run(sequencing_samples):
    # a sequencing sample identifier is of the form:
    # "<study_id>/<sample_id>/<run_id>"
    samples = expand(
        join(
            "{unit.study_id}", "{unit.sample_id}", "{unit.run_id}",
        ),
        unit=sequencing_samples.itertuples()
    )
    return list(set(samples))

###############################################################################

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
            "{directory_prefix}", "{sample}.qc.txt"
        ),
        directory_prefix=read_dirs["trimmed"],
        sample=get_samples_by_lane(sequencing_samples)
    )
    return cutadapt_reports


def get_fastqc_reports(sequencing_samples, fastqc_dirs):
    fastqc_reports = expand(
        join(
            "{directory_prefix}", "{sample}_{read}_fastqc.{ext}",
        ),
        directory_prefix=[fastqc_dirs["raw"], fastqc_dirs["trimmed"]],
        sample=get_samples_by_lane(sequencing_samples),
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
            "{directory_prefix}", "{sample}.log"
        ),
        directory_prefix=align_dirs["initial"],
        sample=get_samples_by_lane(sequencing_samples)
    )
    return hisat2_reports


def get_mark_duplicates_reports(sequencing_samples, align_dirs):
    """
    The metrics file from picard MarkDuplicates is put into the same directory
    as the duplicate-marked bam file

    This returns the file paths for all metrics files generated during
    duplicate-marking.
    """
    mark_duplicates_reports = expand(
        join(
            "{directory_prefix}", "{sample}.metrics"
        ),
        directory_prefix=align_dirs["markdup"],
        sample=get_samples_by_run(sequencing_samples)
    )
    return mark_duplicates_reports


def get_feature_counts_reports(sequencing_samples, quantify_dirs):
    """
    """
    fcounts_reports = expand(
        join(
            "{directory_prefix}", "{sample}.fcount.summary"
        ),
        directory_prefix=quantify_dirs["with_dups"],
        sample=get_samples_by_run(sequencing_samples)
    )
    return fcounts_reports


def get_rseqc_reports(sequencing_samples, rseqc_dirs):
    """
    gene-body coverage figures and data

    TODO: Update when we know what the output filenames will be
    """
    rseqc_report = join(
        rseqc_dirs["prefix"], "unknown_output"
    )
    return [rseqc_report]


###############################################################################


def get_filter_and_align_reports(
        sequencing_samples, read_dirs, fastqc_dirs, align_dirs, quantify_dirs,
        rseqc_dirs
    ):
    """
    A `fastqc` report for each fastq.gz in the current dataset is generated
    (one for each untrimmed and one for each trimmed file);

    A `cutadapt` report is generated for each pair of `fastq.gz` files in the
    current dataset.

    A `hisat2` alignment report is generated for each pair of `fastq.gz` files
    in the current dataset.

    A `picard MarkDuplicates` report for each merged bam.

    A `featureCounts` report for each quantified, merged, bam

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
    markdup_reports = get_mark_duplicates_reports(
        sequencing_samples=sequencing_samples, align_dirs=align_dirs
    )
    fcounts_reports = get_feature_counts_reports(
        sequencing_samples=sequencing_samples, quantify_dirs=quantify_dirs
    )
    rseqc_reports = get_rseqc_reports(
        sequencing_samples=sequencing_samples, rseqc_dirs=rseqc_dirs
    )
    return fastqc_reports + cutadapt_reports + hisat2_reports + \
        markdup_reports + fcounts_reports + rseqc_reports


###############################################################################
