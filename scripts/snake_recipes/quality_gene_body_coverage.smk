import re


def get_subsampled_bed():
    return os.path.join(qc_dirs["rseqc"]["prefix"], "subsampled.bed12")


def gene_body_coverage_input(wildcards):
    """
    `gene_body_coverage` takes a set of "*.bam" files, each with a "*.bai",
    index and a `.bed12`-file defining a set of transcripts.

    The program geneBody_coverage.py requires samtools-style indexes
    (`*.bam.bai`) rather than the picard-style indexes (`*.bai`) that we use
    here; and so we make links from `*.bam.bai` to `*.bai` within the
    `gene_body_coverage` rule
    """

    samples = get_samples_by_run(sequencing_samples)

    prefixes = expand(
        os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}"
        ),
        sequencing_sample_id=samples
    )

    bams = [s + ".bam" for s in prefixes]
    bam_indexes = [s + ".bai" for s in prefixes]

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
        # bais are specified in picard format (*.bai) but used in samtools
        # format (*.bam.bai) within `geneBody_coverage.py`
        unpack(gene_body_coverage_input)

    output:
        # If multiple bams are passed in, this rule also makes *.heatmap.pdf
        get_rseqc_reports(sequencing_samples, qc_dirs["rseqc"])

    params:
        # TODO: extract program-specific parameters
        # compute a comma-separated string of bam files
        bam_string = \
            lambda wildcards, input: ",".join(input["bams"]),
        bam_prefixes = \
            lambda wildcards, input: [re.sub("\.bam$", "", bam) for bam in input["bams"]],
        output_prefix = os.path.join(
            qc_dirs["rseqc"]["gene_body_coverage"], "rnaseq"
        )

    conda:
        "../../envs/rseqc.yaml"

    shell:
        # geneBody_coverage requires samtools-style *.bam.bai indexes for each
        # bam file, but we only create picard-style *.bai indexes. Hence, to
        # get this rule to run, we make a link from a samtools-style bam index
        # to the picard-style index before calling geneBody_coverage
        #
        # We do this here, rather than adding a rule that creates the
        # samtools-style link because if I add a rule that creates *.bam.bai
        # given *.bai it creates weird dependencies in the workflow. For
        # example, snakemake might start looking for a sample with
        # run_id="some_prefix.bam"
        """
        for file_prefix in {params.bam_prefixes};
        do
          picard="${{file_prefix}}.bai";
          samtools="${{file_prefix}}.bam.bai";
          if [[ ! -f "${{samtools}}" ]];
          then
            ln -rs "${{picard}}" "${{samtools}}";
          fi
        done;

        geneBody_coverage.py \
          -r {input.bed12} \
          -i {params.bam_string} \
          -o {params.output_prefix}
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
