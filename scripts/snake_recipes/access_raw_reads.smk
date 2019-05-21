from snakemake.remote.FTP import RemoteProvider as FTPRemoteProvider

FTP = FTPRemoteProvider()


def define_input_fastqs(wildcards):
    """
    For a given sample/run, obtain the URL/filepath to the initial fastq files.

    Assumes that
    - the raw fastqs are defined in the `fq1` and `fq2` columns of a
    table called `sequencing_samples`
    - the `sequencing_samples` table is indexed with the tuple (study_id,
      sample_id, run_id, lane_id)
    - the wildcards define each of study_id, sample_id, run_id, lane_id
    """
    index_tuple = (
        wildcards.study_id, wildcards.sample_id, wildcards.run_id,
        wildcards.lane_id
    )
    raw_fastqs = sequencing_samples.loc[index_tuple, ["fq1", "fq2"]]

    # TODO: implement for FTP-downloads
    return raw_fastqs


def access_method_for_input_fastqs(wildcards):
    """
    For a given sample/run determine whether the raw fastq for that sample is
    to be downloaded from an FTP site (returns `ftp`) or is available in local
    storage (returns `local`)
    """

    # TODO: implement for FTP-downloads
    return "local"


rule access_raw_reads:
    message:
        """
        Download (if external) or make a link to local copy of the `fastq`s for
        this workflow

        - The downloaded fastq or the link will be deleted at the end of this
        (sub)workflow.
        - Assumes paired-end reads
        - Assumes input files are gzipped
        """

    input:
        define_input_fastqs

    output:
        fastq1 = temp(
            os.path.join(
                read_dirs["raw"],
                "{study_id}/{sample_id}/{run_id}_{lane_id}_1.fastq.gz"
            )
        ),
        fastq2 = temp(
            os.path.join(
                read_dirs["raw"],
                "{study_id}/{sample_id}/{run_id}_{lane_id}_2.fastq.gz"
            )
        )

    params:
        access_method = access_method_for_input_fastqs

    shell:
        # TODO: implement for FTP-downloads
        """
        ln -sr {input[0]} {output.fastq1}
        ln -sr {input[1]} {output.fastq2}
        touch -h {output}
        """
