# -- subworkflows

subworkflow filter_and_align:
    workdir:
        "substeps/filter_and_align"
    snakefile:
        "substeps/filter_and_align/Snakefile"
    configfile:
        "substeps/filter_and_align/conf/snake_config.yaml"

# --

rule all:
    input:
        "doc/filter_and_align/fake_report.pdf"

rule filter__and_align_fake:
    input:
        filter_and_align("doc/fake_report.pdf")
    output:
        "doc/filter_and_align/fake_report.pdf"
    shell:
        """
        ln -rs {input} {output}
        """
