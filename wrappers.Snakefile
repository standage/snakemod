all:
    input: 'sorted.bam'
    run: print('Yay, all done!')


rule downsample:
    input:
        r1=config['r1'],
        r2=config['r2'],
    output:
        left='subset_1.fastq',
        right='subset_2.fastq',
    threads: 2
    shell:
        '''
        seqtk sample -s100 {input.r1} {config[numreads]} > {output.left} &
        seqtk sample -s100 {input.r2} {config[numreads]} > {output.right}
        '''


rule spades:
    input:
        r1='subset_1.fastq',
        r2='subset_2.fastq',
    output: 'contigs.fasta'
    params:
        outdir='analysis/spades/{SAMPLE}'
    threads: 32
    shell: 'spades.py -1 {input.r1} -2 {input.r2} -t {threads} -o . --careful'



rule index_assembly:
    input:
        asm='contigs.fasta'
    output:
        index=expand('contigs.{ext}', ext=('1.bt2', '2.bt2', '3.bt2', '4.bt2', 'rev.1.bt2', 'rev.2.bt2'))
    shell: 'bowtie2-build {input.asm} contigs'


rule map_back_reads:
    input:
        sample=[config['r1'], config['r2']]
        index=expand('contigs.{ext}', ext=('1.bt2', '2.bt2', '3.bt2', '4.bt2', 'rev.1.bt2', 'rev.2.bt2')),
    output:
        pipe('unsorted.bam')
    params:
        index='contigs',
        extra='',
    threads: 32
    wrapper: '0.64.0/bio/bowtie2/align'


rule map_sort:
    input: 'unsorted.bam'
    output: 'sorted.bam'
    wrapper: '0.64.0/bio/samtools/sort'


rule index_bam:
    input: 'sorted.bam'
    output: 'sorted.bam.bai'
    wrapper: '0.64.0/bio/samtools/index'


rule bam_stats:
    input:
        bam='sorted.bam',
        idx='sorted.bam.bai'
    output: 'sorted.bam.idxstats'
    wrapper: '0.64.0/bio/samtools/idxstats'
