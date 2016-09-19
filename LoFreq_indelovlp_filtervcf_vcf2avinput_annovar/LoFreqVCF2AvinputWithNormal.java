import java.io.*;
import java.util.*;

public class LoFreqVCF2AvinputWithNormal {
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
                // for normal information
                String normalinfo = arr[9];
            
                // tumour info
                int rawDepth = Integer.parseInt(infoArr[0].split("=")[1]);
                double altFreq = Double.parseDouble(infoArr[1].split("=")[1]);
                int altForwardDepth = Integer.parseInt(infoArr[3].split("[=,]")[3]);
                int altBackwardDepth = Integer.parseInt(infoArr[3].split("[=,]")[4]);
                int altDepth = altForwardDepth + altBackwardDepth;

                // normal info
                String[] normalinfoArr = normalinfo.split(":");
                int normalDepth = Integer.parseInt(normalinfoArr[0]);
                int normalAltDepth = Integer.parseInt(normalinfoArr[2]);
                double normalAltFreq = (double)normalAltDepth/(double)normalDepth;
              
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
                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + rawDepth + "\t" + altDepth + "\t" + altFreq + "\t" + "INDEL";
                        if(info.contains("CONSVAR")) {
                            outputLine += "\t" + "consensus_variant";
                        } else {
                            outputLine += "\t" + "low_frequency_variant";
                        }
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
                        outputLine = outputChr + "\t" + outputStartPos + "\t" + outputEndPos + "\t" + outputRef + "\t" + outputAlt + "\t" + normalDepth + "\t" + normalAltDepth + "\t" + normalAltFreq + "\t" + rawDepth + "\t" + altDepth + "\t" + altFreq + "\t" + "SNV";
                        if(info.contains("CONSVAR")) {
                            outputLine += "\t" + "consensus_variant";
                        } else {
                            outputLine += "\t" + "low_frequency_variant";
                        }
                        System.out.println(outputLine);  
                    }
                }
            }
        }
        br.close();
    }
}
