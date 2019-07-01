# Read groups are required for correct use of picard MarkDuplicates /
# MergeSamFiles

# In bowtie2, read groups are added using cli flags:
# `--rg-id <text>`
# Set the read group ID to <text>. This causes the SAM @RG header line to be
# printed, with <text> as the value associated with the ID: tag. It also causes
# the RG:Z: extra field to be attached to each SAM output record, with value
# set to <text>.

# `--rg <text>`
# Add <text> (usually of the form TAG:VAL, e.g. SM:Pool1) as a field on the @RG
# header line. Note: in order for the @RG line to appear, --rg-id must also be
# specified. This is because the ID tag is required by the SAM Spec. Specify
# --rg multiple times to set multiple fields. See the SAM Spec for details
# about what fields are legal.

# GATK standards: ID, PU, SM, PL, LB
# - see https://gatkforums.broadinstitute.org/gatk/discussion/6472/read-groups

def read_group(wildcards, sequencing_samples):
    """
    --- Setup GATK-style read groups

        We use 'run_id' instead of library/sample-barcode (this isn't strictly
        correct; and maybe we ought to define a library_id column in
        sequencing_samples).
        We assume platform is always ILLUMINA
    """

    # `wildcards` should contain `study_id`, `sample_id`, `run_id`, and
    # `lane_id`
    # `sequencing_samples` should exist and use (study_id, sample_id, run_id,
    # lane_id) as index

    index_tuple = (
        wildcards.study_id, wildcards.sample_id, wildcards.run_id,
        wildcards.lane_id
    )
    sample = wildcards.sample_id
    flowcell_id = sequencing_samples.loc[index_tuple, "flowcell_id"]
    platform_unit = "{FLOWCELL_BARCODE}.{LANE}.{SAMPLE_BARCODE}".format(
      FLOWCELL_BARCODE = flowcell_id,
      LANE = wildcards.lane_id,
      SAMPLE_BARCODE = wildcards.run_id
    )
    platform = "ILLUMINA"
    library = wildcards.run_id
    read_group = platform_unit

    return [
        "--rg-id {}".format(read_group),
        "--rg PU:{}".format(platform_unit),
        "--rg SM:{}".format(sample),
        "--rg PL:{}".format(platform),
        "--rg LB:{}".format(library)
    ]
