rule copyseq:
    input:
        r1=config["reads1"],
        r2=config["reads2"],
    output:
        left="seq/reads-R1.fastq",
        right="seq/reads-R2.fastq",
    shell:
        """
        cp {input.r1} {output.left}
        cp {input.r2} {output.right}
        """


rule downsample:
    input:
        r1=rules.copyseq.output.left,
        r2=rules.copyseq.output.right,
    output:
        left="seq/reads-subset-R1.fastq",
        right="seq/reads-subset-R2.fastq",
    params:
        numreads=config["sample_numreads"],
        seed=config["sample_seed"],
    shell:
        """
        seqtk sample -s{params.seed} {input.r1} {params.numreads} > {output.left}
        seqtk sample -s{params.seed} {input.r2} {params.numreads} > {output.right}
        """


rule spades:
    input:
        r1=rules.downsample.output.left,
        r2=rules.downsample.output.right,
    output:
        asmbl="analysis/spades/scaffolds.fasta",
    params:
        outdir="analysis/spades/",
    threads: 32
    shell:
        "spades.py -1 {input.r1} -2 {input.r2} -t {threads} -o {params.outdir} --careful"
