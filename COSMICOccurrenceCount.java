import java.io.*;
import java.util.*;
import java.util.regex.*;

public class COSMICOccurrenceCount {
    public static void main(String[] args) throws IOException{
        HashMap<Integer, ArrayList<String>> occurrenceCosmicFullInfoMap = new HashMap<Integer, ArrayList<String>>();
        BufferedReader br = new BufferedReader(new FileReader("Cosmic70_hg19_mutations_fullinfo"));
        Pattern p = Pattern.compile("(\\d+)\\([^()]+\\)"); 
        Matcher m = null;
        String line = null;
        while((line = br.readLine()) != null) {
            String[] arr = line.split("\t");
            String occurrence = arr[6];
            m = p.matcher(occurrence);
            int count = 0;
            while(m.find()) {
                count += Integer.parseInt(m.group(1));
            }
            // if(occurrenceCosmicFullInfoMap.containsKey(count)) {
            //     occurrenceCosmicFullInfoMap.get(count).add(line);
            // } else {
            //     ArrayList<String> list = new ArrayList<String>();
            //     list.add(line);
            //     occurrenceCosmicFullInfoMap.put(count, list); 
            // }
        }
        br.close();
        
        // ArrayList<Integer> countList = new ArrayList<Integer>(occurrenceCosmicFullInfoMap.keySet());
        // Collections.sort(countList);
        // Collections.reverse(countList);
        // int counter = 0;
        // for(int count : countList) {
        //     ArrayList<String> cosmicFullInfos = occurrenceCosmicFullInfoMap.get(count);
        //     for(String fullInfo : cosmicFullInfos) {
        //         System.out.println(fullInfo);
        //     }
        //     
        //     counter++;
        //     if(counter >=50) {
        //         break;
        //     }
        // }
    }
}
