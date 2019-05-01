# -- subworkflows

subworkflow filter_and_align:
    workdir:
        "substeps/filter"
    snakefile:
        "substeps/filter/Snakefile"
    configfile:
        "substeps/filter/conf/snake_config.yaml"

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
