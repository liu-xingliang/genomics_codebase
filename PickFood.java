import java.util.*;
import java.text.*;


public class PickFood {
	public static void main(String[] args) {
		Random rd = new Random(); // the seed is a value very likely to be distinct from any other invocation of this constructor.
		Calendar c = Calendar.getInstance(); // calendar of current time
		GregorianCalendar lunchtime = new GregorianCalendar(c.get(Calendar.YEAR), c.get(Calendar.MONTH), c.get(Calendar.DAY_OF_MONTH), 12, 30); // 12:30 of today
		Calendar currentDay = null;
		// after lunch time, current date is from tomorrow
		if(c.compareTo(lunchtime) < 0) {
			currentDay = c;
		} else {
			currentDay = new GregorianCalendar(c.get(Calendar.YEAR), c.get(Calendar.MONTH), c.get(Calendar.DAY_OF_MONTH) + 1);
		}
		int days = c.getActualMaximum(Calendar.DAY_OF_MONTH) - currentDay.get(Calendar.DAY_OF_MONTH) + 1;
		
		int counter = 0;
		int total = 14; // total number of unique integer the random number generator could generate, start from 1
		while(counter < days) {
			GregorianCalendar calendar = new GregorianCalendar(currentDay.get(Calendar.YEAR), currentDay.get(Calendar.MONTH), currentDay.get(Calendar.DAY_OF_MONTH) + counter);

			// skip weekend
			if(calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY || calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SUNDAY) {
				counter++;
				if(calendar.get(Calendar.DAY_OF_WEEK) == Calendar.SATURDAY) {
					System.out.println("--------------Weekend--------------");
				}
				continue;
			}

			Date date = calendar.getTime();
			
			int current = rd.nextInt(total) + 1; // original start from 0
			switch(current) {
				case 1:
				case 2:
				case 3:
					System.out.println(PickFood.outputFormatter("Chinese", date));
					break;
				case 4:
				case 5:
				case 6:
					System.out.println(PickFood.outputFormatter("YTF", date));
					break;
				case 7:
				case 8:
					System.out.println(PickFood.outputFormatter("Veg", date));
					break;
				case 9:
				case 10:
					System.out.println(PickFood.outputFormatter("Malay", date));
					break;
				case 11:
				case 12:
					System.out.println(PickFood.outputFormatter("Jap", date));
					break;
				case 13:
					System.out.println(PickFood.outputFormatter("Indian", date));
					break;
				case 14:
					System.out.println(PickFood.outputFormatter("Western", date));
					break;
				default:
					break;
			}
			counter++;
		}
	}
	
	public static String outputFormatter(String storeName, Date date /*the date go to the store*/) {
		SimpleDateFormat formatter = new SimpleDateFormat();
		formatter.applyPattern("EEE,YYYY-MMM-dd");

		return String.format("%1$s%2$20s", formatter.format(date),storeName);
	}
}
