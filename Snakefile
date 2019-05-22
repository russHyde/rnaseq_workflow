# -- subworkflows

subworkflow filter_and_align:
    workdir:
        "substeps/filter_and_align"
    snakefile:
        "substeps/filter_and_align/Snakefile"
    configfile:
        "substeps/filter_and_align/conf/snake_config.yaml"

subworkflow qc:
    workdir:
        "substeps/qc"
    snakefile:
        "substeps/qc/Snakefile"

# --

rule all:
    input:
        "doc/filter_and_align/fake_report.pdf",
        "doc/qc/fake_report.pdf"

make_link_wrapper = \
    """
    ln -rs {input} {output}
    touch -h {output}
    """

rule filter_and_align_fake:
    input:
        filter_and_align("doc/fake_report.pdf")
    output:
        "doc/filter_and_align/fake_report.pdf"
    shell:
        make_link_wrapper

rule qc_fake:
    input:
        qc("doc/fake_report.pdf")
    output:
        "doc/qc/fake_report.pdf"
    shell:
        make_link_wrapper
