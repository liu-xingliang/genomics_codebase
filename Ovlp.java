import java.io.*;
import java.util.*;

public class Ovlp {
    public static void main(String[] args) throws IOException {
        String file1Path = args[0];
        String file2Path = args[1];
        String indices1S = args[2];
        String indices2S = args[3];

        String[] indices1SArr = indices1S.split(","); 
        String[] indices2SArr = indices2S.split(",");

        int[] indices1 = new int[indices1SArr.length];
        for(int i = 0; i< indices1SArr.length; i++) {
            indices1[i] = Integer.parseInt(indices1SArr[i]);
        }

        int[] indices2 = new int[indices2SArr.length];
        for(int i = 0; i< indices2SArr.length; i++) {
            indices2[i] = Integer.parseInt(indices2SArr[i]);
        }

        String line = null;

        HashSet<String> keySet1 = new HashSet<String>();
        HashSet<String> keySet2 = new HashSet<String>();

        BufferedReader br1 = new BufferedReader(new FileReader(file1Path));
        while((line = br1.readLine()) != null) {
            String[] arr = line.split("\t");
            String key="";
            for(int i = 0; i< indices1.length; i++) {
                key += arr[indices1[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
            keySet1.add(key);
        }
        br1.close();

        BufferedReader br2 = new BufferedReader(new FileReader(file2Path));
        while((line = br2.readLine()) != null) {
            String[] arr = line.split("\t");
            String key = "";
            for(int i = 0; i< indices2.length; i++) {
                key += arr[indices2[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
            keySet2.add(key);
        }
        br2.close();

        // overlap
        Set<String> ovlp = new HashSet<String>(keySet1);
        ovlp.retainAll(keySet2);

        System.out.println(ovlp.size());

        // 1 only
        Set<String> only1 = new HashSet<String>(keySet1);
        only1.removeAll(keySet2);

        // 2 only
        Set<String> only2 = new HashSet<String>(keySet2);
        only2.removeAll(keySet1);

        // output (add as required)
        BufferedWriter bwOvlpIn1 = new BufferedWriter(new FileWriter(file1Path + ".ovlp"));
        BufferedWriter bwOvlpIn2 = new BufferedWriter(new FileWriter(file2Path + ".ovlp"));
        
        br1 = new BufferedReader(new FileReader(file1Path));
        while((line = br1.readLine()) != null) {
            String[] arr = line.split("\t");
            String key="";
            for(int i = 0; i< indices1.length; i++) {
                key += arr[indices1[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
           
            if(ovlp.contains(key)) {
                bwOvlpIn1.append(line);
                bwOvlpIn1.newLine();
            }
        }
        br1.close();

        br2 = new BufferedReader(new FileReader(file2Path));
        while((line = br2.readLine()) != null) {
            String[] arr = line.split("\t");
            String key = "";
            for(int i = 0; i< indices2.length; i++) {
                key += arr[indices2[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
           
            if(ovlp.contains(key)) {
                bwOvlpIn2.append(line);
                bwOvlpIn2.newLine();
            }
        }
        br2.close();
        
        bwOvlpIn1.close();
        bwOvlpIn2.close();
        

        BufferedWriter bwUniq1 = new BufferedWriter(new FileWriter(file1Path + ".uniq"));
        BufferedWriter bwUniq2 = new BufferedWriter(new FileWriter(file2Path + ".uniq"));

        br1 = new BufferedReader(new FileReader(file1Path));
        while((line = br1.readLine()) != null) {
            String[] arr = line.split("\t");
            String key="";
            for(int i = 0; i< indices1.length; i++) {
                key += arr[indices1[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
           
            if(only1.contains(key)) {
                bwUniq1.append(line);
                bwUniq1.newLine();
            }
        }
        br1.close();

        br2 = new BufferedReader(new FileReader(file2Path));
        while((line = br2.readLine()) != null) {
            String[] arr = line.split("\t");
            String key = "";
            for(int i = 0; i< indices2.length; i++) {
                key += arr[indices2[i] - 1] + "\t";
            }
            key = key.trim().toUpperCase();
           
            if(only2.contains(key)) {
                bwUniq2.append(line);
                bwUniq2.newLine();
            }
        }
        br2.close();

        bwUniq1.close();
        bwUniq2.close();
    }
}
