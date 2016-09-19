import java.io.*;
import java.util.*;

public class GCContentLoFreqPlp {
    public static void main(String[] args) throws IOException{
        BufferedReader br = new BufferedReader(new FileReader(args[0]));
        String line = null;
       
        long totalA = 0L;
        long totalC = 0L;
        long totalG = 0L;
        long totalT = 0L; 
        long totalN = 0L;
        while((line = br.readLine()) != null) {
            String[] lineArr = line.split("\t");
            String A = lineArr[4];
            String C = lineArr[5];
            String G = lineArr[6];
            String T = lineArr[7];
            String N = lineArr[8];
    
            String[] arr = A.split("[:/]");
            totalA += (Long.parseLong(arr[1]) + Long.parseLong(arr[2]));

            arr = C.split("[:/]");
            totalC += (Long.parseLong(arr[1]) + Long.parseLong(arr[2]));
            
            arr = G.split("[:/]");
            totalG += (Long.parseLong(arr[1]) + Long.parseLong(arr[2]));

            arr = T.split("[:/]");
            totalT += (Long.parseLong(arr[1]) + Long.parseLong(arr[2]));

            arr = N.split("[:/]");
            totalN += (Long.parseLong(arr[1]) + Long.parseLong(arr[2]));
        }
        br.close();

        double averageLocusCoverage = (double)(totalC + totalG) / (double)(totalA + totalC + totalG + totalT + totalN);

        System.out.println(averageLocusCoverage);
    }
}
