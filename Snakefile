# -- subworkflows

subworkflow prefilter:
    workdir:
        "substeps/prefilter"
    snakefile:
        "substeps/prefilter/Snakefile"
    configfile:
        "substeps/prefilter/conf/snake_config.yaml"

subworkflow align:
    workdir:
        "substeps/align"
    snakefile:
        "substeps/align/Snakefile"
    configfile:
        "substeps/align/conf/snake_config.yaml"

# --

rule all:
    input:
        "doc/prefilter/fake_report.pdf",
        "doc/align/fake_report.pdf"

rule prefilter_fake:
    input:
        prefilter("doc/fake_report.pdf")
    output:
        "doc/prefilter/fake_report.pdf"
    shell:
        """
        ln -rs {input} {output}
        """

rule align_fake:
    input:
        align("doc/fake_report.pdf")
    output:
        "doc/align/fake_report.pdf"
    shell:
        """
        ln -rs {input} {output}
        """
