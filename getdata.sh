#!/usr/bin/env bash
set -eo pipefail

if [[ ! -f SRR5944233-R1.fastq ]]; then
    if [[ ! -f  SRR5944233.1.sra ]]; then
        curl -L https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos2/sra-pub-run-11/SRR5944233/SRR5944233.1 > SRR5944233.1.sra
    fi
    fastq-dump --split-files --defline-seq '@Sample057.$si/$ri' --defline-qual '+' SRR5944233.1.sra
    mv SRR5944233.1_1.fastq sample057-R1.fastq
    mv SRR5944233.1_2.fastq sample057-R2.fastq
fi
