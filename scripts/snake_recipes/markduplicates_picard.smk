from os.path import join

rule mark_duplicates_picard:
    message:
        """
        --- Mark (or remove) duplicate read-pairs using `picard`.

            To remove duplicates, the user should set `REMOVE_DUPLICATES=true`
            in the picard::MarkDuplicates entry of the `program_params.yaml`
            file.
        """

    input:
        join(
            align_dirs["merge"], "{sequencing_sample_id}.bam"
        )

    output:
        bam = join(
            align_dirs["markdup"], "{sequencing_sample_id}.bam"
        ),
        metrics = join(
            align_dirs["markdup"], "{sequencing_sample_id}.metrics"
        ),
        bai = join(
            align_dirs["markdup"], "{sequencing_sample_id}.bai"
        )

    resources:
        mem=4

    params:
        lambda wildcards, resources: \
            "-Xmx{}G {} {} {} {}".format(
                resources["mem"],
                program_params["picard"]["MarkDuplicates"],
                "TMP_DIR=temp",
                "ASSUME_SORT_ORDER=coordinate",
                "CREATE_INDEX=true"
            )

    log:
        "logs/markdup/{sequencing_sample_id}.log"

    wrapper:
        "0.34.0/bio/picard/markduplicates"

