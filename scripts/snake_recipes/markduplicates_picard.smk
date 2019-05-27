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
            align_dirs["dedup"], "{sequencing_sample_id}.bam"
        ),
        metrics = join(
            align_dirs["dedup"], "{sequencing_sample_id}.metrics.txt"
        ),
        bai = join(
            align_dirs["dedup"], "{sequencing_sample_id}.bai"
        )

    params:
        "{} {} {} {}".format(
            program_params["picard"]["MarkDuplicates"],
            "TMP_DIR=temp", "ASSUME_SORT_ORDER=coordinate", "CREATE_INDEX=true"
        )

    log:
        "logs/dedup/{sequencing_sample_id}.log"

    wrapper:
        "0.34.0/bio/picard/markduplicates"

