import java.io.*;
import java.util.*;

public class ItvlRate_AvgCov {
    public static void main(String[] args) throws IOException {
        ArrayList<String> fileList = new ArrayList<String>();
        BufferedReader brFileList = new BufferedReader(new FileReader("filelist")); // each file is sample_interval_summary
        String lineFileList = null;
        while((lineFileList = brFileList.readLine()) != null) {
            fileList.add(lineFileList);
        }
        brFileList.close();

        for(String file : fileList) {
            ArrayList<Double> list0 = new ArrayList<Double>();
            ArrayList<Double> list50 = new ArrayList<Double>();
            ArrayList<Double> list100 = new ArrayList<Double>();
            ArrayList<Double> list500 = new ArrayList<Double>();
            ArrayList<Double> list1000 = new ArrayList<Double>();
            ArrayList<Double> list2000 = new ArrayList<Double>();
            ArrayList<Double> listGt2000 = new ArrayList<Double>(); 
            
            BufferedReader br = new BufferedReader(new FileReader(file));
            String line = br.readLine(); // header 
            int num = 0;
            while((line = br.readLine()) != null) {
                String[] arr = line.split("\t");
                double avgCov = Double.parseDouble(arr[2]);
                
                if(avgCov == 0) {
                    list0.add(avgCov);
                } else if(avgCov >0 && avgCov <= 50) {
                    list50.add(avgCov);
                } else if(avgCov >50 && avgCov <= 100) {
                    list100.add(avgCov);
                } else if (avgCov >100 && avgCov <= 500) {
                    list500.add(avgCov);
                } else if (avgCov > 500 && avgCov <= 1000) {
                    list1000.add(avgCov);
                } else if(avgCov > 1000 && avgCov <=2000) {
                    list2000.add(avgCov);
                } else if (avgCov > 2000) {
                    listGt2000.add(avgCov);
                } else {
                    System.err.println("ERROR: average coverage shouldn't be negative!");
                }
                num++;
            }
            
            String lib = file.split("\\.")[0];
            PrintWriter pw = new PrintWriter(lib + ".itvlrate");

            pw.println("average_coverage\tintervals_rate\tintervals_count" ); // header

            pw.println("0\t" + (double)list0.size()/(double)num*100 + "\t" + list0.size());
            pw.println("(0-50]\t" + (double)list50.size()/(double)num*100 + "\t" + list50.size());
            pw.println("(50-100]\t" + (double)list100.size()/(double)num*100 + "\t" + list100.size());
            pw.println("(100-500]\t" + (double)list500.size()/(double)num*100 + "\t" + list500.size());
            pw.println("(500-1000]\t" + (double)list1000.size()/(double)num*100 + "\t" + list1000.size());
            pw.println("(1000-2000]\t" + (double)list2000.size()/(double)num*100 + "\t" + list2000.size());
            pw.println(">2000\t" + (double)listGt2000.size()/(double)num*100 + "\t" + listGt2000.size());
            pw.close();
            
            br.close();
        }
    }
}
