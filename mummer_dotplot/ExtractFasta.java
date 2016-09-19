import java.io.*;
import java.util.*;

public class ExtractFasta {
    public static void main(String[] args) throws IOException {
        String fastaPath = args[0];
        String id = args[1]; 
        
        BufferedReader br = new BufferedReader(new FileReader(fastaPath));
        BufferedWriter bw = new BufferedWriter(new FileWriter(id + ".fasta"));
        String line = null;
        while((line = br.readLine()) != null) {
            if(line.matches(">" + id + "\\s.*")) {
                bw.append(line);
                bw.newLine();

                while((line = br.readLine()) != null && !(line.startsWith(">"))) {
                    bw.append(line);
                    bw.newLine();
                }

                break;
            }
        }
        br.close();
        bw.close();
    }
}
