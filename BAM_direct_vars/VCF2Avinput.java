import java.io.*;
import java.util.*;

/**
 * 1. Extract total depth, alt-allele depth, alt-allele frequency
 * 
 * Test for samtools 1.3 (VCF v4.2)
 */

public class VCF2Avinput {
    public static void main(String[] args) throws IOException {
        String vcfPath = args[0];
        String varType = args[1]; // SNV, INDEL
        String ADField = args[2]; // AD field: Allelic depths for the ref and alt alleles in the order listed
                                    // format: "main:sub", main is the index (1-based) of main field which contains "AD" field and sub is the idx of "AD" field in the main field
        String otherInfoField = args[3]; // format is same as AD field or "NA", not in use

        String mainSep = args[4]; // separator of main fields
        String subSep = args[5]; // separator of sub fields
        String ADSep = args[6]; // separator in the "AD" fields
        String otherInfoSep = args[7]; // separator in the "AD" fields or "NA" not in use

        BufferedReader br = new BufferedReader(new FileReader(vcfPath));
        String line = null;
        while((line = br.readLine()) != null) {
            if(!line.startsWith("#")) {
                String[] arr = line.split(mainSep, -1);

                // variants coordinates
                
                String chr = arr[0];
                int startPos = Integer.parseInt(arr[1]);
                String ref = arr[3];
                String[] altArr = arr[4].split(",");

                // based on VCF4.2 (http://samtools.github.io/hts-specs/VCFv4.2.pdf)
                // if no alt allele is found, use missing value "."
                if(altArr[0].equals(".")) { // equals, checked
                    continue; 
                }

                // "AD" fields
                int ADmain = Integer.parseInt(ADField.split(":")[0]) - 1;
                int ADsub = Integer.parseInt(ADField.split(":")[1]) - 1;

                String[] ADArr = arr[ADmain].split(subSep, -1)[ADsub].split(ADSep, -1);
                int rawDepth = 0;
                for(String d : ADArr) {
                    rawDepth += Integer.parseInt(d);
                }

                String outputChr = chr;
                int outputStartPos = startPos;
                int outputEndPos = startPos;
                String outputRef = ref;

                if(varType.equals("SNV")) {
                    for(int i=0; i< altArr.length; i++) {
                        String altE = altArr[i];

                        // based on VCF4.2 (http://samtools.github.io/hts-specs/VCFv4.2.pdf)
                        // * means the allele is missing due to upstream deletion
                        // in samtools mpileup vcf output, use "<*>"
                        if(altE.contains("*")) {
                            continue;
                        }

                        String outputLine = "";
                        String outputAlt = altE;
                        int altCount = Integer.parseInt(ADArr[i+1]);
                        double altAlleleFrequency = (double) altCount / (double) rawDepth;

                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + rawDepth + "\t" + altCount + "\t" + altAlleleFrequency + "\t" + "SNV";

                        System.out.println(outputLine);  
                    }
                }

                if(varType.equals("INDEL")) {
                    for(int i=0; i< altArr.length; i++) {
                        String altE = altArr[i];

                        // based on VCF4.2 (http://samtools.github.io/hts-specs/VCFv4.2.pdf)
                        // * means the allele is missing due to upstream deletion
                        // in samtools mpileup vcf output, use "<*>"
                        if(altE.contains("*")) {
                            continue;
                        }

                        String outputLine = "";
                        String outputAlt = altE;

                        int altCount = Integer.parseInt(ADArr[i+1]);
                        double altAlleleFrequency = (double) altCount / (double) rawDepth;
                         
                        if(altE.length() > ref.length()) // insertion
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
                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + rawDepth + "\t" + altCount + "\t" + altAlleleFrequency + "\t" + "INDEL";

                        System.out.println(outputLine); 
                    }
                }
            }
        }
    }
}
