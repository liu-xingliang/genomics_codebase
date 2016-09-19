#!usr/bin/perl

$input_file = $ARGV[0];
open(read_input_file, "<", $input_file) or die "Cannot read $input_file\n";;

$list_of_tsg_genes = '/mnt/projects/liuxl/ctso4_projects/liuxl/scripts/VOGELSTEIN/list_of_TSG_oncogenes_Vogelstein_Science_2013.txt';
open(readfile, "<", $list_of_tsg_genes) or die "Cannot open $list_of_tsg_genes";

$output_file = $input_file.".mutdriver";
open(w, ">", $output_file) or die "Cannot open $output_file\n"; #over write

%tsg_genes = ();

LINE1:while($line = <readfile>)
{
	chomp($line);
	if($line =~ "#"){next LINE1;}
	else
	{
		@a = split('\t', $line);
		$g_symbol = $a[0];
		$g_class = $a[4];
		$g_mut_typ = $a[5];
		$g_core_pro = $a[6];
		$g_process = $a[7];
		if(exists $tsg_genes{$g_symbol}){print "$g_symbol_exists\n";}
		else
		{
			$tsg_genes{$g_symbol}= "$g_class\t$g_mut_typ\t$g_core_pro\t$g_process";
		}
	}
}

while($line1 = <read_input_file>)
{
	chomp($line1);
	if($line1 =~ "Func.refGene")
	{
		print w "$line1\tVogel_classification\tVogel_mutation_type\tVogel_core_pathway\tVogel_process\n";
	}
	else
	{
		@info = split('\t', $line1);
		$gene = $info[6];
		if(exists $tsg_genes{$gene})
		{
			$annotations = $tsg_genes{$gene};
			print w "$line1\t$annotations\n";
		}
		else
		{
			print w "$line1\tNA\tNA\tNA\tNA\n";
		}
	}
}
