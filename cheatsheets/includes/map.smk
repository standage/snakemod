rule index_assembly:
    input:
        asmbl=rules.spades.output.asmbl,
    output:
        index=expand(
            rules.spades.output.asmbl + ".{ext}",
            ext=("1.bt2", "2.bt2", "3.bt2", "4.bt2", "rev.1.bt2", "rev.2.bt2"),
        ),
    shell:
        "bowtie2-build {input.asmbl} {input.asmbl}"


rule map_back_reads:
    input:
        asmbl=rules.spades.output.asmbl,
        r1=rules.copyseq.output.left,
        r2=rules.copyseq.output.right,
        index=rules.index_assembly.output.index,
    output:
        bam=pipe("analysis/unsorted.bam"),
    threads: workflow.cores - 1
    shell:
        """
        bowtie2 -p {threads} -x {input.asmbl} -1 {input.r1} -2 {input.r2} \
            | samtools view -q 10 -Sbh > {output.bam}
        """


rule map_sort:
    input:
        bam=rules.map_back_reads.output.bam,
    output:
        bam="analysis/sorted.bam",
    shell:
        "samtools sort -o {output} {input}"


rule index_bam:
    input:
        bam=rules.map_sort.output.bam,
    output:
        bai=f"{rules.map_sort.output.bam}.bai",
    shell:
        "samtools index {input}"


rule bam_stats:
    input:
        bam=rules.map_sort.output.bam,
        bai=rules.index_bam.output.bai,
    output:
        stats=f"{rules.map_sort.output.bam}.idxstats",
    shell:
        "samtools idxstats {input.bam} > {output.stats}"