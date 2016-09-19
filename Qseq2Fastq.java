import java.io.*;
import java.util.*;

public class Qseq2Fastq {
    public static void main(String[] args) throws IOException {
        final int DEFAULT_BUFFER_SIZE = 1 * 1024 * 1024 * 1024; // 1G
        BufferedReader br = new BufferedReader(new FileReader(args[0]),DEFAULT_BUFFER_SIZE); 
        BufferedWriter bw = new BufferedWriter(new FileWriter(args[1]),DEFAULT_BUFFER_SIZE);  
        String line = null;
        while((line = br.readLine()) != null) {
            String[] arr = line.split("\t");
            if(arr[arr.length - 1].equals("0")) { // failed reads
                continue;
            }
            String id = arr[0] + "_" + arr[1] + "_" + arr[2] + "_" + arr[3] + "_" + arr[4] + "_" + arr[5];
            String seq = arr[8];
            String qual = arr[9];
            bw.append("@" + id); 
            bw.newLine();
            bw.append(seq); 
            bw.newLine();
            bw.append("+" + id); 
            bw.newLine();
            bw.append(qual); 
            bw.newLine();
        }
        br.close();
        bw.close();
    }
}
