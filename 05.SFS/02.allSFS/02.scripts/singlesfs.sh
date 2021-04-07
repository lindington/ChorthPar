for pop in POR CSY PHZ AHZ DOB SLO; do #use for leftover pops 


#for pop in ERY PAR TAR GOM; do	#use for first batch of pops
	~/programs/Angsd/angsd/misc/realSFS -P 24 ../../01.saf/03.output/saf_${pop}.saf.idx > ../03.output/SFS_${pop}.sfs

done
