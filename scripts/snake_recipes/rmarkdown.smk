###############################################################################
#
# User should specify a variable `rmarkdown_prereqs` in the calling Snakefile.
# User should specify a variable `rmarkdown_results` in the calling Snakefile.
# Any .Rmd that is called using this rule should use library(here)
#
###############################################################################

from os import getcwd
from os.path import basename
from snakemake.utils import R

###############################################################################
rule compile_markdown:
    message:
        """
        --- Compile R-markdown to .pdf or .docx in job `{params.job}`

        - Use *.Rmd as first input argument and put any additional dependencies
          into `rmarkdown_prereqs`
        - The output .pdf or .docx is the first output argument, and any
          additionally-constructed files should be implicitly named in
          `rmarkdown_result_regexes`. Each entry in the latter should have a
          {{doc_name}} and a {{ext}} wildcard in their definition.
        """

    input:
        ["doc/{doc_name}.Rmd"] + rmarkdown_prereqs

    output:
        ["doc/{doc_name}.{ext}"] + rmarkdown_result_regexes

    wildcard_constraints:
        ext = "pdf|docx|html"

    params:
        job = os.path.basename(os.getcwd())

    run:
        R("""
            library(rmarkdown)
            library(tools)
            doctype <- list(pdf  = "pdf_document",
                            docx = "word_document",
                            html = "html_document"
                            )[["{wildcards.ext}"]]
            rmd.script <- "{input[0]}"
            render(rmd.script,
                   output_format = doctype,
                   output_file   = "{output[0]}",
                   output_dir    = "doc",
                   quiet = TRUE)
        """)

###############################################################################

