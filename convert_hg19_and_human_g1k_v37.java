import java.io.*;
import java.util.*;

/**
 * convert between hg19 and human_g1k_v37
 * only for 1-22,X,Y,MT
 * */
public class convert_hg19_and_human_g1k_v37 {
    public static void main(String[] args) throws IOException{
        String inputFilePath = args[0];
        String outputFilePath = args[1];
        int chrIdx = Integer.parseInt(args[2]); // tab, 1-based
        String fromRefGenome = args[3]; // hg19 or human_g1k_v37
        String toRefGenome = args[4]; // hg19 or human_g1k_v37

        String[] hg19_chr_arr = new String[]{"chr1", "chr2", "chr3", "chr4", "chr5", "chr6", "chr7", "chr8", "chr9", "chr10", "chr11", "chr12", "chr13", "chr14", "chr15", "chr16", "chr17", "chr18", "chr19", "chr20", "chr21", "chr22", "chrX", "chrY", "chrM"};
        String[] human_g1k_v37_chr_arr = new String[]{"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "X", "Y", "MT"};

        // build map from chr to index
        HashMap<String, Integer> hg19_chr_idx_map = new HashMap<String, Integer>();
        int idx = 0;
        for(String chr : hg19_chr_arr) {
            hg19_chr_idx_map.put(chr.toUpperCase(), idx++); 
        }

        HashMap<String, Integer> human_g1k_v37_chr_idx_map = new HashMap<String, Integer>();
        idx = 0;
        for(String chr : human_g1k_v37_chr_arr) {
            human_g1k_v37_chr_idx_map.put(chr.toUpperCase(), idx++); 
        }

        if(fromRefGenome.equals("hg19") && toRefGenome.equals("human_g1k_v37")) {
            BufferedReader br = new BufferedReader(new FileReader(inputFilePath));
            BufferedWriter bw = new BufferedWriter(new FileWriter(outputFilePath));
            String line = null;
            while((line = br.readLine()) != null) {
                String[] arr = line.split("\t", -1);
                String chr = arr[chrIdx - 1].toUpperCase();
                if(hg19_chr_idx_map.containsKey(chr)) {
                    arr[chrIdx - 1] = human_g1k_v37_chr_arr[hg19_chr_idx_map.get(chr)];
                    String outLine = "";
                    boolean isFirst = true;
                    for(String e : arr) {
                        if(isFirst) {
                            outLine = e;
                            isFirst = false;
                        } else {
                            outLine += "\t" + e;
                        }
                    }

                    bw.append(outLine);
                    bw.newLine();
                }
            }
            br.close();
            bw.close();
        } else if (fromRefGenome.equals("human_g1k_v37") && toRefGenome.equals("hg19")) {
            BufferedReader br = new BufferedReader(new FileReader(inputFilePath));
            BufferedWriter bw = new BufferedWriter(new FileWriter(outputFilePath));
            String line = null;
            while((line = br.readLine()) != null) {
                String[] arr = line.split("\t", -1);
                String chr = arr[chrIdx - 1].toUpperCase();
                if(human_g1k_v37_chr_idx_map.containsKey(chr)) {
                    arr[chrIdx - 1] = hg19_chr_arr[human_g1k_v37_chr_idx_map.get(chr)];
                    String outLine = "";
                    boolean isFirst = true;
                    for(String e : arr) {
                        if(isFirst) {
                            outLine = e;
                            isFirst = false;
                        } else {
                            outLine += "\t" + e;
                        }
                    }

                    bw.append(outLine);
                    bw.newLine();
                }
            }
            br.close();
            bw.close();
        } else {
            System.err.println("ERROR: fromRefGenome or toRefGenome name is not correct");
            System.exit(-1);
        }
    }
}
