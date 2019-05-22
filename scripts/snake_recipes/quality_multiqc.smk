rule multiqc:
    message:
        """
        --- Make a report summarising all QC reports generated while running
            the current workflow / workflow-substep.

            input: {input}
            output: {output}
        """

    input:
        # Any Snakefile that calls this rule should define a variable called
        # `qc_reports` that defines all the individual QC reports generated
        # during that Snakefile's workflow
        qc_reports

    output:
        # Any Snakefile that calls this rule should define a filepath called
        # `multiqc_report`. This `.html` file will be overwritten. The
        # constructed report summarises all data present in any of the input
        # files.
        multiqc_report

    log:
        "logs/multiqc.log"

    wrapper:
        # The snakemake wrapper uses the `--force` option, so any preexisting
        # report file will be overwritten.
        #
        # multiqc ==1.2, networkx <2.0
        "0.34.0/bio/multiqc"
