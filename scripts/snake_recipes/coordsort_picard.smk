rule coordinate_sort_picard:
    message:
        """
        --- Sort a `.bam` file by coordinate using `picard`
        """

    input:
        os.path.join(
            align_dirs["initial"], "{sequencing_sample_id}.bam"
        )

    output:
        bam = temp(
            os.path.join(
                align_dirs["coordsort"], "{sequencing_sample_id}.bam"
            ))

    params:
        sort_order = "coordinate",
        extra = "TMP_DIR=temp"

    log:
        "logs/coordsort/{sequencing_sample_id}.log"

    wrapper:
        "0.34.0/bio/picard/sortsam"

