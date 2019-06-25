def get_subsampled_bed():
    return os.path.join(qc_dirs["rseqc"], "subsampled.bed12")


def gene_body_coverage_input(wildcards):
    """
    `gene_body_coverage` takes a set of bam files, each with a ".bam.bai",
    samtools-style, index and a .bed12-file defining a set of transcripts.
    """

    samples = get_samples_by_run(sequencing_samples)

    bams = expand(
        os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}.bam",
            sequencing_sample_id=samples
        )
    )

    bam_indexes = [s + ".bai" for s in bams]

    bed12 = get_subsampled_bed()

    return {
        "bams": bams,
        "bais": bam_indexes,
        "bed12": bed12
    }


rule gene_body_coverage:
    message:
        """
        --- Compute how coverage varies from 5' to 3' across a random sample of
            transcripts

            input: {input}
            output: {output}
        """

    input:
        # bais must be specified in samtools format (*.bam.bai) to be
        # recognised by `geneBody_coverage.py`
        gene_body_coverage_input

    output:
        # TODO: determine explicit files that are output by
        # `geneBody_coverage.py` for a set of bams
        directory(
            os.path.join(qc_dirs["rseqc"]["prefix"], "gene_body_coverage")
        )

    params:
        # TODO: extract program-specific parameters
        # compute a comma-separated string of bam files
        bam_string = lambda wildcards, input: ",".join(input["bams"])

    conda:
        "../../envs/rseqc.yaml"

    shell:
        """
        geneBody_coverage.py -r {bed12} -i {params.bam_string} -o {output}
        """


rule samtools_formatted_bai_links:
    message:
        """
        --- Our default index for a `*.bam` file is of form `*.bai`, but some
            programs require a `samtools`-style index `*.bam.bai`
        """

    input:
        bam = os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}.bam"
        ),
        bai = os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}.bai"
        )

    output:
        bai = os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}.bam.bai"
        )

    shell:
        """
        ln -rs {input.bai} {output.bai} && touch -h {output.bai}
        """


rule subsample_bed12_transcriptome:
    message:
        """
        --- `geneBody_coverage.py` takes ~~ages~~ to assess coverage on every
            one of the transcripts defined in the human transcriptome; but we
            only really need coverage info for a few of these transcripts to
            gauge whether there are biases in the coverage for a given sample

            input: {input}
            params: {params}
            output: {output}
        """

    input:
        reference_params["transcript_bed12"]

    output:
        get_subsampled_bed()

    params:
        n_transcripts = 3000

    shell:
        """
        shuf -n {params.n_transcripts} {input} -o {output}
        """
