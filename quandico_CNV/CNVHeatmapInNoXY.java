import java.io.*;
import java.util.*;

public class CNVHeatmapInNoXY {
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(args[0])); // input file, get from merged quandico CNV csv result, lib<TAB>gene<TAB>copies, no header

        HashSet<String> unionLibSet = new HashSet<String>(); // lib set get from user, just in case there are some libs don't have any CNVs (no entry for it in args[0])
        BufferedReader brLib = new BufferedReader(new FileReader(args[1]));
        String lineLib = null;
        while((lineLib = brLib.readLine()) != null) {
            String lib = lineLib.toUpperCase();
            unionLibSet.add(lib);
        }
        brLib.close();

        HashSet<String> unionGeneSet = new HashSet<String>(); // get from pass CNV csv file
        
        HashMap<String, HashMap<String, Double>> gene_lib_CNV_map = new HashMap<String, HashMap<String, Double>>();
        String line = null;
        while((line = br.readLine()) != null) {
            String[] arr = line.split("\t");
            String lib = arr[0].toUpperCase();
            String gene = arr[1].toUpperCase(); 
            double copies = Double.parseDouble(arr[2]);
            if(gene_lib_CNV_map.containsKey(gene)) {
                if(gene_lib_CNV_map.get(gene).containsKey(lib)) {
                    System.err.println("ERROR: duplicate gene entries within one lib");
                    System.exit(1);
                } else {
                    gene_lib_CNV_map.get(gene).put(lib, copies);
                }

                unionGeneSet.add(gene);
                unionLibSet.add(lib); // just in case user missed some libraries in args[1]
            } else {
                HashMap<String, Double> singlegene_lib_CNV_map = new HashMap<String, Double>(); 
                singlegene_lib_CNV_map.put(lib, copies);
                gene_lib_CNV_map.put(gene, singlegene_lib_CNV_map);

                unionGeneSet.add(gene);
                unionLibSet.add(lib); // just in case user missed some libraries in args[1]
            }
        }
        br.close();

        // output
        //
        ArrayList<String> unionLibList = new ArrayList<String>(unionLibSet);
        Collections.sort(unionLibList);
        ArrayList<String> unionGeneList = new ArrayList<String>(unionGeneSet);
        Collections.sort(unionGeneList);

        // header
        String header = "";
        for(String lib : unionLibList) {
            header += "\t" + lib;
        }
        header = "Gene\t" + header.trim();
        System.out.println(header);

        for(String gene : unionGeneList) {
            HashMap<String, Double> singlegene_lib_CNV_map = gene_lib_CNV_map.get(gene);
            String oneLine = gene;
            if(singlegene_lib_CNV_map == null) {
                for(int i = 0; i< unionLibList.size(); i++) {
                    oneLine += "\t2";
                }
            } else {
                for(int i = 0; i< unionLibList.size(); i++) {
                    String lib = unionLibList.get(i);
                    if(singlegene_lib_CNV_map.containsKey(lib)) {
                        oneLine += "\t" + singlegene_lib_CNV_map.get(lib);
                    } else {
                        oneLine += "\t2";
                    }
                }
            }
            System.out.println(oneLine);
        }
    }
}
