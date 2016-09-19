import java.io.*;
import java.util.*;

public class GenePileup{
    public static void main(String[] args) throws FileNotFoundException, IOException{
	Hashtable<String, HashSet<String>> howManyPatientsInEachKey = new Hashtable<String, HashSet<String>>();
	Hashtable<String, ArrayList<String>> hashTable = new Hashtable<String, ArrayList<String>>();
	HashSet<String> allSampleIDs = new HashSet<String>(); // those samples which don't have any variants (mutdriver is empty only has header) 
							      //or don't have any variants which are one of exonic, splicing, ncRNA, UTR5, UTR3 will also be included in the result (with all values are 0s)
	String inputPatientLibraryIDsFile = args[0];
	BufferedReader br = new BufferedReader(new FileReader(inputPatientLibraryIDsFile));		
	String s;
	while((s = br.readLine()) != null) {
	    String[] array0 = s.split(" ");
	    String patient = array0[0];
	    String normal = array0[1];
	    for(int i = 2; i< array0.length; i++) {
		String tumor = array0[i];
		allSampleIDs.add(patient+"_"+tumor);
		// reader of the final .mutdriver file generated by annovar annotation and VOGELSTEIN mut driver 
		BufferedReader annotationFileReader = new BufferedReader(new FileReader("/mnt/pnsg10_projects/liuxl/ctso4_projects/liuxl/naharrr/strelka_annovar_no_Merged_deep_sequence/new/"+patient+"/"+normal+"_"+tumor+"/strelka_out/results/passed.somatic.indels.vcf_filtered.vcf_SNV_hg19_multianno.txt.mutdriver"));
		String line = annotationFileReader.readLine(); // feed the header line (remove)
		while((line = annotationFileReader.readLine()) != null) {
		    line = line.trim(); 
		    String[] array = line.split("\t");
		    
		    for(int iii = 0; iii< array.length; iii++) {
		        array[iii] = array[iii].trim();		
		    }
		
		    if(array[5].equals("exonic") || array[5].equals("splicing") || array[5].equals("ncRNA") || array[5].equals("UTR5") || array[5].equals("UTR3")) 
		    {
			String key = array[5] + "\t" + array[6].toLowerCase();
		        if(!hashTable.containsKey(key)) {
			   ArrayList<String> libraryIDs = new ArrayList<String>();
			   libraryIDs.add(patient+"_"+tumor);
			   hashTable.put(key,libraryIDs);
			   HashSet<String> patientSetForEachKey = new HashSet<String>();
			   patientSetForEachKey.add(patient);
			   howManyPatientsInEachKey.put(key, patientSetForEachKey);
		        } else {
			   hashTable.get(key).add(patient+"_"+tumor);
			   howManyPatientsInEachKey.get(key).add(patient);
		        }
		    }
		}
		annotationFileReader.close();
	    }
	}
	br.close();	
	
	ArrayList<String> arrayList = new ArrayList<String>(allSampleIDs);
	Collections.sort(arrayList);

	String header = "Func\tGene";
	for(String a : arrayList) {
	    header += "\t" + a; 
	}
	header += "\t" + "Number_Of_Patients" + "\t" + "Number_Of_Samples";
	System.out.println(header);
		
	Iterator<Map.Entry<String, ArrayList<String>>> itr = hashTable.entrySet().iterator();
	while(itr.hasNext()) {
	    Map.Entry<String, ArrayList<String>> entry = (Map.Entry<String, ArrayList<String>>) itr.next();
	    String key = entry.getKey();
	    ArrayList<String> libraryIDs = entry.getValue();
	    String ss = key;
	    int numberOfSamples = 0;
	    for(String ee : arrayList) {
		if(libraryIDs.contains(ee)) {
		    ss += "\t" + "1";
		    numberOfSamples++;
		}
		else 
		    ss += "\t" + "0";	
	    }
	    int numberOfPatients = howManyPatientsInEachKey.get(key).size();
	    ss += "\t" + numberOfPatients + "\t" + numberOfSamples;
	    System.out.println(ss); 
	}
    }
}
