import java.io.*;
import java.util.*;

public class LoFreqVCF2Avinput_lofreq2_1_2 {
    public static void main(String[] args) throws IOException{
        String vcfPath = args[0];
        BufferedReader br = new BufferedReader(new FileReader(vcfPath));
        String line = null;
        while((line = br.readLine()) != null) {
            if(!line.startsWith("#")) {
                String[] arr = line.split("\t");
                String chr = arr[0];
                int startPos = Integer.parseInt(arr[1]);
                String ref = arr[3];
                String alt = arr[4];
                String info = arr[7];
                String[] infoArr = info.split(";");

                // all about tumour
                int refForwardCount = Integer.parseInt(infoArr[3].split("[=,]")[1]);
                int refBackwardCount = Integer.parseInt(infoArr[3].split("[=,]")[2]);
                int altForwardCount = Integer.parseInt(infoArr[3].split("[=,]")[3]);
                int altBackwardCount = Integer.parseInt(infoArr[3].split("[=,]")[4]);

                // Don't use DP and AF fields, just use DP4 to calculate, since AF (seems to be calculated by (DP4[3] + DP4[4]/DP)) will > 1 sometimes
                int totalDepth = refForwardCount + refBackwardCount + altForwardCount + altBackwardCount;
                int altCount = altForwardCount + altBackwardCount;
                double altAlleleFrequency = (double)altCount/(double)totalDepth;
              
                String outputChr = chr;
                int outputStartPos = startPos;
                int outputEndPos = startPos;
                String outputRef = ref;
                if(info.contains("INDEL")) {
                    // convert the indel ref alt format for annovar
                    String[] altArr = alt.split(",");
                    for(String altE : altArr) {
                        String outputLine = "";
                        String outputAlt = altE;
                        if(altE.equals("*")) {
                            // do as annovar tool convert2annovar.pl
                            outputEndPos = startPos + (ref.length() - 1);
                            outputAlt = "0";
                        } 
                        else if(altE.length() > ref.length()) // insertion
                        { 
                            if (altE.startsWith(ref)) {
                                outputStartPos = startPos + (ref.length() - 1);
                                outputEndPos = outputStartPos;
                                outputRef = "-";
                                outputAlt = altE.substring(ref.length());
                            } else {
                                // convert2annovar.pl
                                outputEndPos = startPos + (ref.length() - 1);
                            }
                        } 
                        else // deletion
                        {
                            if (ref.startsWith(altE)) {
                                outputStartPos = startPos + altE.length();
                                outputEndPos = outputStartPos + (ref.length() - altE.length()) - 1;
                                outputRef = ref.substring(altE.length());
                                outputAlt = "-";
                            } else {
                                // convert2annovar.pl
                                outputEndPos = startPos + (ref.length() - 1);
                            }
                        }
                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + totalDepth + "\t" + altCount + "\t" + altAlleleFrequency + "\t" + "INDEL";

                        // Removed options (and use of) cons-as-ref and skip-n. now reference
                        // is always used by default to call against and n's are always
                        // skipped. also means the consensus variants (CONSVAR) concept
                        // disappeared
                        //
                        // if(info.contains("CONSVAR")) {
                        //     outputLine += "\t" + "consensus_variant";
                        // } else {
                        //     outputLine += "\t" + "low_frequency_variant";
                        // }
                        System.out.println(outputLine);
                    }
                } 
                else // SNV
                {
                    String[] altArr = alt.split(",");
                    for(String altE : altArr) {
                        String outputLine = "";
                        String outputAlt = altE;
                        if(altE.equals("*")) {
                            // do as annovar tool convert2annovar.pl
                            outputAlt = "0";
                        }
                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + totalDepth + "\t" + altCount + "\t" + altAlleleFrequency + "\t" + "SNV";

                        // Removed options (and use of) cons-as-ref and skip-n. now reference
                        // is always used by default to call against and n's are always
                        // skipped. also means the consensus variants (CONSVAR) concept
                        // disappeared
                        //
                        // if(info.contains("CONSVAR")) {
                        //     outputLine += "\t" + "consensus_variant";
                        // } else {
                        //     outputLine += "\t" + "low_frequency_variant";
                        // }
                        System.out.println(outputLine);  
                    }
                }
            }
        }
        br.close();
    }
}
