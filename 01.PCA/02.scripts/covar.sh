#gzip -d .geno file

#count the number of variable sites

#zcat ../../00.beagle/03.output/final.mafs.gz | tail -n+2 | wc -l
#2057836 variable sites

~/programs/ngsTools/ngsCovar -probfile ../../00.beagle/03.output/newbeagle50.geno -outfile ../03.output/beagle50.covar -nind 50 -nsites 1494335 -call 0 -norm 0
