import java.util.*;
import java.io.*;

public class mpilupresult_bin_mean {
    public static void main(String[] args) throws IOException {
        final int DEFAULT_BUFFER_SIZE = 1 * 1024 * 1024 * 1024;
        BufferedReader br = new BufferedReader(new FileReader(args[0]),DEFAULT_BUFFER_SIZE); // the unit of DEFAULT_BUFFER_SIZE is byte
        int binSize = Integer.parseInt(args[1]);
        BufferedWriter bw = new BufferedWriter(new FileWriter(args[0] + ".bin" + binSize + ".mpileup"), DEFAULT_BUFFER_SIZE);

        String line = null;
        int binSizeCounter = 0;
        int binSizePileupSum = 0;
        int[] single_base_pileup_arr = new int[binSize];
        while((line = br.readLine()) != null) {
            String[] arr = line.split("\t");
            int single_base_pileup = Integer.parseInt(arr[3]);
            
            binSizePileupSum += single_base_pileup;

            binSizeCounter++;

            if(binSizeCounter == binSize) {
                             
                double binAvgPileup = (double)binSizePileupSum/(double)binSize;
                bw.append(binAvgPileup + "");
                bw.newLine();

                binSizePileupSum = 0;
                binSizeCounter = 0;  
            }
        }

        if(binSizeCounter != 0) {
            double binAvgPileup = (double)binSizePileupSum/(double)binSizeCounter;
            bw.append(binAvgPileup + "");
            bw.newLine();
        }

        br.close();
        bw.close();
    }
}
