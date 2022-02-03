## 02.SFS

A site frequency spectrum (SFS) is a summary statistic, which describes the distribution of allele frequencies in a sample. This can be used to infer demographic parameters for a population, such as gene flow. For this project, I use two population SFS (2D SFS) to fit demographic models in dadi.

To build the 2D SFS, I first make a SAF file in ANGSD.

### Creating SAF files

SAF files are large files that contain information on the allele frequencies of ones samples. Each population will need its own SAF file, in my case I have to built 2 for each of the two pairs of populations that will be compared (4 SAF files). The SAF file information depends on the individuals included in the list of bam files.

### SAF command and SLURM script

The SAF files are built in angsd, submitted as a batch job like this:

```
#!/bin/bash
#SBATCH -J saf_alp
#SBATCH --output=../02.output/saf_alp.out
#SBATCH --clusters=mpp3
#SBATCH --partition=mpp3_batch
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=ALL
#SBATCH --mail-user=Linda.Hagberg@campus.lmu.de
#SBATCH -t 48:00:00

STARTTIME=$(date +"%s")

angsd -b ./bamlist_alp.txt -ref ./grasshopperRef.fasta -anc ./grasshopperRef.fasta -doSaf 1 -doCounts 1 -DoMaf 1 -doMajorMinor 1 -GL 1 -r chr1: -sites ./neutral_sites -minInd 8 -minMapQ 15 -only_proper_pairs 0 -minQ 20 -remove_bads 1 -uniqueOnly 1 -C 50 -baq 1 -setMinDepth 20 -fold 0 -SNP_pval 1 -out ../02.output/saf_alp

ENDTIME=$(date +%s)
TIMESPEND=$(($ENDTIME - $STARTTIME))
((sec=TIMESPEND%60,TIMESPEND/=60, min=TIMESPEND%60, hrs=TIMESPEND/60))
timestamp=$(printf "%d:%02d:%02d" $hrs $min $sec)
echo "Took $timestamp hours:minutes:seconds to complete..."
```

#### SAF file command line options

See [General ANGSD Options](README.md#general-angsd-options) at the beginning of supplementary material for options not mentioned below.

<table>
<colgroup>
<col width="46%" />
<col width="54%" />
</colgroup>
<thead>
<tr class="header">
<th>Option</th>
<th>Description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td><code>-anc ../input_files/grasshopperRef.fasta</code></td>
<td>A fasta file containing the outgroup used to determine ancestral and derived states. I use the <em>C. parallelus</em> reference. Since only folded SFS will be used downstream, this polarization does not matter for the results.</td>
</tr>
<tr class="even">
<td><code>-doSaf 1</code></td>
<td>Setting to 1 indicates that allele frequency likelihoods will be determined by individual genotype likelihoods assuming Hardy-Weinberg Equilibrium.</td>
</tr>
<tr class="odd">
<td><code>-fold 0</code></td>
<td>Determines whether the SFS will be unfolded (0) or folded (1). If you are not confident in the ancestral states defined by your outgroup, it may be best to fold. However, for SAF file production, I left the SFS unfolded, as they will be folded later.</td>
</tr>
<tr class="even">
<td><code>SNP_pval 1</code></td>
<td>Defines the intensity of filtering on SNPs in the SAF file. A p-value of 1 indicates inclusion of all sites, also sites with no polymorphisms. Lowering the value increasingly removes fixed sites and low frequency SNPs. Here, fixed sites do not need to be filtered, as they will be removed automatically in the demographic analysis.</td>
</tr>
</tbody>
</table>

