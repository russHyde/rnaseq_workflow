rule queryname_sort_picard:
    message:
        """
        --- Sort a `.bam` file by queryname using `picard`
        """

    input:
        os.path.join(
            align_dirs["markdup"], "{sequencing_sample_id}.bam"
        )

    output:
        bam = temp(
            os.path.join(
                align_dirs["querysort"], "{sequencing_sample_id}.bam"
            ))

    params:
        sort_order = "queryname",
        extra = "TMP_DIR=temp"

    log:
        "logs/querysort/{sequencing_sample_id}.log"

    wrapper:
        "0.34.0/bio/picard/sortsam"

