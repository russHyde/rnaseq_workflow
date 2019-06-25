def mergesam_input(wildcards):
    """
    Determine the set of lane-specific sequencing files for a given sequencing
    sample. The lane-specific, aligned sequencing files will be merged to
    generate a sample/run-specific .bam file

    Aligned samples should be coordinate-sorted
    """

    # TODO: user can define whether aligned files should be merged at
    #   - sample-level (combining all runs and all lanes for a sample),
    #   - run-level (combining all lanes for a run)
    index_tuple = (
        wildcards.study_id, wildcards.sample_id, wildcards.run_id
    )

    samples_by_run = sequencing_samples.set_index(
        ["study_id", "sample_id", "run_id"], drop=False
    )

    lanes = samples_by_run.loc[index_tuple, "lane_id"]

    template = os.path.join(
        align_dirs["coordsort"],
        "{study_id}",
        "{sample_id}",
        "{run_id}_{lane_id}.bam"
    )

    mergeable_bams = expand(
        template,
        study_id = wildcards.study_id,
        sample_id = wildcards.sample_id,
        run_id = wildcards.run_id,
        lane_id = lanes
    )
    return mergeable_bams


rule mergesam_picard:
    message:
        """
        --- Merge multiple coordinate-sorted `.bam`s for the same sample / run
            across lanes
        """

    input:
        mergesam_input

    output:
        temp(
            os.path.join(
                align_dirs["merge"],
                "{study_id}", "{sample_id}", "{run_id}.bam"
            )
        )

    log:
        "logs/mergesam/{study_id}/{sample_id}/{run_id}.bam"

    params:
        "VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=true TMP_DIR=temp"

    wrapper:
        "0.34.0/bio/picard/mergesamfiles"
