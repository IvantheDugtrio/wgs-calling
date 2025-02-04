rule sra_prefetch:
    """
    Prefetch spot data from an sra project.
    """
    output:
        temp(directory("results/sra/{srid}-spots/{srid}")),
    benchmark:
        "results/performance_benchmarks/sra_prefetch/{srid}.tsv"
    conda:
        "../envs/sra.yaml"
    threads: config_resources["default"]["threads"]
    resources:
        mem_mb=config_resources["default"]["memory"],
        slurm_partition=rc.select_partition(
            config_resources["default"]["partition"], config_resources["partitions"]
        ),
        tmpdir=tempDir,
    shell:
        "prefetch {wildcards.srid} -O {output} --max-size u"


rule sra_fasterq_dump:
    """
    Convert prefetched spot data from an sra project into fastqs.
    """
    input:
        "results/sra/{srid}-spots/{srid}",
    output:
        single_reads=temp("results/sra/{srid}-fastqs/{srid}.fastq"),
        read1=temp("results/sra/{srid}-fastqs/{srid}_1.fastq"),
        read2=temp("results/sra/{srid}-fastqs/{srid}_2.fastq"),
    params:
        tmpdir=tempDir,
    benchmark:
        "results/performance_benchmarks/sra_fasterq_dump/{srid}.tsv"
    conda:
        "../envs/sra.yaml"
    threads: config_resources["sra_tools"]["threads"]
    resources:
        mem_mb=config_resources["sra_tools"]["memory"],
        slurm_partition=rc.select_partition(
            config_resources["sra_tools"]["partition"], config_resources["partitions"]
        ),
        tmpdir=tempDir,
    shell:
        "fasterq-dump {input}/{wildcards.srid} --outdir results/sra/{wildcards.srid}-fastqs -e {threads} -t {params.tmpdir} && "
        'if [[ ! -f "{output.single_reads}" ]] ; then touch {output.single_reads} ; fi'


rule sra_compress_read_file:
    """
    Take the uncompressed fastq output from sra-tools fasterq-dump and bgzip it.
    """
    input:
        "results/sra/{srid}-fastqs/{srid}_{rg}.fastq",
    output:
        "results/fastqs/{srid}/{srid}_L001_R{rg}_001.fastq.gz",
    benchmark:
        "results/performance_benchmarks/sra_compress_read_file/{srid}_{rg}.tsv"
    conda:
        "../envs/bcftools.yaml"
    threads: config_resources["default"]["threads"]
    resources:
        mem_mb=config_resources["default"]["memory"],
        slurm_partition=rc.select_partition(
            config_resources["default"]["partition"], config_resources["partitions"]
        ),
    shell:
        "bgzip -c {input} > {output}"
