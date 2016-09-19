import java.io.*;
import java.util.*;

public class Run {
    public static void main(String[] args) throws IOException{
        BufferedReader brAnno = new BufferedReader(new FileReader("hg19_cosmic70.tsv"));// from annovar annotation db
        String lineAnno = null;
        HashMap<String, String> mapAnno = new HashMap<String, String>();
        while((lineAnno = brAnno.readLine()) != null) {
            String[] arr = lineAnno.split("\t");
            String value = arr[0] + "\t" + arr[1] + "\t" + arr[2] + "\t" + arr[3] + "\t" + arr[4] + "\t" + arr[6];
            String cosmicId = arr[5];
            if(cosmicId.contains(",")) {
                String[] cosmicIdArr = cosmicId.split(",");
                for(String id : cosmicIdArr) {
                    mapAnno.put(id, value);
                }
            } else {
                mapAnno.put(cosmicId, value);
            }
        }
        brAnno.close();

        // output
        BufferedWriter bwOutput = new BufferedWriter(new FileWriter("Cosmic70_fullinfo"));
        bwOutput.append("COSMICID\tCHR\tSTART\tEND\tREF\tALT\tOCCURENCE\tAA\tCDS\tGENE\tSTRAND");
        bwOutput.newLine();

        BufferedReader brCos = new BufferedReader(new FileReader("Cosmic70_hg19_noUn.tsv")); // from COSMIC db
        String lineCos = null;
        while((lineCos = brCos.readLine()) != null) {
            String[] arr = lineCos.split("\t");
            String cosmicId = arr[0];
            String AA = "NA";
            String CDS = "NA";
            String GENE = "NA";
            String STRAND = "NA";
            for(int i = 1; i< arr.length; i++) {
                if(arr[i].startsWith("AA=")) {
                    AA = (new StringBuilder(arr[i])).substring("AA=".length()).toString();
                } else if(arr[i].startsWith("CDS=")) {
                    CDS = (new StringBuilder(arr[i])).substring("CDS=".length()).toString();   
                } else if(arr[i].startsWith("GENE=")) {
                    GENE = (new StringBuilder(arr[i])).substring("GENE=".length()).toString();    
                } else if(arr[i].startsWith("STRAND=")) {
                    STRAND =(new StringBuilder(arr[i])).substring("STRAND=".length()).toString();  
                }
            }
            String value = AA + "\t" + CDS + "\t" + GENE + "\t" + STRAND;
            String infoAnno = (mapAnno.get(cosmicId) != null) ? mapAnno.get(cosmicId) : "NA\tNA\tNA\tNA\tNA\tNA";
            bwOutput.append(cosmicId + "\t" + infoAnno + "\t" + value);
            bwOutput.newLine();
        }
        brCos.close();

        bwOutput.close();
    }
}
