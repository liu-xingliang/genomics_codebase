cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/ovlp_and_rmprimer_splitchr/submit_merge_aquila.sh
cp /mnt/projects/liuxl/ctso4_projects/liuxl/scripts/ovlp_and_rmprimer_splitchr/submit_ovlp_and_rmprimer_splitchr_aquila.sh

bamlist=XXX
primer_dir=XXX #/mnt/projects/liuxl/ctso4_projects/liuxl/SayLi/CTC_Proj/SayLiCTC_primers/locusbased/not_empty/human_g1k_v37/
bash submit_ovlp_and_rmprimer_splitchr_aquila.sh $bamlist $primer_dir 
bash submit_merge_aquila.sh $bamlist 30G 20G
