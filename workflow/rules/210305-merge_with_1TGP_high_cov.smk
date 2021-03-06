# Merge 50 genomes with 1TGP high coverage data
# note that I merge the phased bialleic snps from the 50 MXB genomes

from os import path

path_to_1TGP = config['path_to_1TGP']
oneTGP_pops = config['oneTGP_pops']


rule subset_pop_list:
    #list with populations to subset from 1TGP
    input:
        pop_meta = "resources/1TGP-samples-meta-data/igsr-1000genomes.tsv"
    output:
        "results/data/210305-merged-with-1TGP/pops-to-subset.txt"
    shell:
        """
        cut -f1,4 {input} |\
            grep -E '{oneTGP_pops}' |\
            cut -f1 >{output}
        """


rule file_to_rename_chromosomes:
    output:
        "results/data/210305-merged-with-1TGP/rename-chromosomes.txt"
    shell:
        """
        touch {output}
        for i in {{1..22}}
        do
          echo "chr$i $i" >>{output}
        done
        """


rule oneTGP_get_biallelic_and_subset_pops:
    # subset the population from 1TGP data
    # filter biallelic snps
    # also changes the name of the chromosome from chrN to N
    # to  match the chromosome names in the MXB genomes
    input:
        vcf = path.join(path_to_1TGP, "CCDG_14151_B01_GRM_WGS_2020-08-05_chr{chrn}.filtered.shapeit2-duohmm-phased.vcf.gz"),
        pops = "results/data/210305-merged-with-1TGP/pops-to-subset.txt",
        chr_names = "results/data/210305-merged-with-1TGP/rename-chromosomes.txt"
    output:
        temp("results/data/210305-merged-with-1TGP/1TGP-chr{chrn}-biallelic-subset.vcf.gz"),
        temp("results/data/210305-merged-with-1TGP/1TGP-chr{chrn}-biallelic-subset.vcf.gz.tbi")
    shell:
        """
        bcftools view -m2 -M2 -v snps {input.vcf} |\
            bcftools view -S {input.pops} |\
            bcftools annotate --rename-chrs {input.chr_names} -Oz -o {output[0]}
        bcftools index {output[0]} --tbi
        """

        
        

    
