rule run_mosdepth:
    """
    Use mosdepth to compute base coverage.
    """
    input:
        bam="results/aligned_bams/{projectid}/{prefix}.bam",
        bai="results/aligned_bams/{projectid}/{prefix}.bai",
    output:
        assorted_files=expand(
            "results/mosdepth/{{projectid}}/{{prefix}}.{suffix}",
            suffix=[
                "mosdepth.global.dist.txt",
                "mosdepth.summary.txt",
                "mosdepth.region.dist.txt",
                "per-base.bed.gz",
                "regions.bed.gz",
                "thresholds.bed.gz",
                "per-base.bed.gz.csi",
                "regions.bed.gz.csi",
                "thresholds.bed.gz.csi",
            ],
        ),
    benchmark:
        "results/performance_benchmarks/run_mosdepth/{projectid}/{prefix}.tsv"
    params:
        outprefix="results/mosdepth/{projectid}/{prefix}",
        probes_bed=config["references"][reference_build]["targets-bed"],
        library_type=config["behaviors"]["library-type"].lower(),
        win_size=params.probes_bed if params.library_type == "wes" else 200,
        mapq=20,
        T="0,10,15,20,30",
    conda:
        "../envs/mosdepth.yaml" if not use_containers else None
    container:
        "docker://brentp/mosdepth:v0.3.3" if use_containers else None
    threads: config_resources["mosdepth"]["threads"]
    resources:
        mem_mb=config_resources["mosdepth"]["memory"],
        slurm_partition=lambda wildcards: rc.select_partition(
            config_resources["mosdepth"]["partition"], config_resources["partitions"]
        ),
    shell:
        "mosdepth --threads {threads} "
        "--by {params.win_size} "
        "--fast-mode "
        "--mapq {params.mapq} "
        "-T {params.T} "
        "{params.outprefix} {input.bam}"
