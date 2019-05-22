rule fastqc:
    message:
        """
        --- Run `fastqc` on a `.fastq.gz` file.

        input: {input}
        output: {output}
        """

    # eg, fastqc report for
    # `data/job/reads/raw/<study>/<sample>/<run>_<lane>_<read>.fastq.gz`
    # gets put into
    # `data/job/fastqc/raw/<study>/<sample>/<run>_<lane>_<read>_fastqc.html`

    input:
        os.path.join(read_dirs["prefix"], "{prefix}.fastq.gz")

    output:
        html = os.path.join(fastqc_dirs["prefix"], "{prefix}_fastqc.html"),
        zip = os.path.join(fastqc_dirs["prefix"], "{prefix}_fastqc.zip")

    log:
        "logs/fastqc/{prefix}_fastqc.log"

    wrapper:
        # fastqc ==0.11.8
        "0.34.0/bio/fastqc"
