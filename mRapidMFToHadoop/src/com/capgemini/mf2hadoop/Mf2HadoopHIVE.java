package com.capgemini.mf2hadoop;

import java.util.List;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.domain.Field;
import com.capgemini.mf2hadoop.hive.HiveCreateTableGenerator;
import com.capgemini.mf2hadoop.mfreader.MFDataReader;
import com.capgemini.mf2hadoop.parser.MFCopyBookParser;
import com.capgemini.mf2hadoop.reader.MFCopyBookReader;
import com.capgemini.mf2hadoop.reader.MFDataFileReaderWriter;

public class Mf2HadoopHIVE {
	
	public static void main(String[] args) throws Exception {
//		String layoutFileName = "gpdcgim.incl.txt";
//		String tableName = "mRapidTable";
//		String comment="mRapid";
//		String rowFormat="DELIMITED";
//		String fieldsTerminatedBy ="\\t";
//		String linesTerminatedBy ="\\n";
//		String storedAs = "TEXTFILE";
//		String mfDataFileName="GPFCGIM_POC_PARTIAL.DAT";
//		String outputFileName="mf.txt";
//		String tablelocation="/user/babar_user/test_table";
		
		if(args.length!=8){
			printCommandError();
			return;
		}
		
		String layoutFileName = args[0];
		String tableName = args[1];
		String comment=args[2];
		String rowFormat=args[3];
		String fieldsTerminatedBy =Mf2HadoopConstants.OUTPUT_FIELDS_SEPERATOR;
		String linesTerminatedBy ="\\n";
		String storedAs = args[4];
		String mfDataFileName=args[5];
		String outputFileName=args[6];
		String tablelocation=args[7];
		
		//printCommandlineArguments(layoutFileName, tableName, comment, rowFormat, fieldsTerminatedBy, linesTerminatedBy, storedAs, mfDataFileName, outputFileName, tablelocation);
		
		//Read the MF layout (copybook file)
		MFCopyBookReader reader = new MFCopyBookReader(); 
		StringBuffer layoutFileBuffer = reader.readLayoutFile(layoutFileName);
		
		//Parse the read layout file to retrieve the field list
		MFCopyBookParser parser = new MFCopyBookParser(); 
		List<Field> fieldList = parser.parseLayoutFile(layoutFileBuffer);
		
		HiveCreateTableGenerator hiveCreateTableGenerator = new HiveCreateTableGenerator(); 
		StringBuffer hiveCreateTableQuery= hiveCreateTableGenerator.generateCreateTableQuery(fieldList, tableName, comment, rowFormat, fieldsTerminatedBy, linesTerminatedBy, storedAs,tablelocation);
		System.out.println(hiveCreateTableQuery);
		
		
		MFDataFileReaderWriter mfDataFileReaderWriter = new MFDataFileReaderWriter(mfDataFileName, outputFileName);
		//Read the data from the mainframe ebcdic file
		MFDataReader mfReader = new MFDataReader();
		mfReader.readData(fieldList, mfDataFileReaderWriter);
		mfDataFileReaderWriter.closeFileStreams();
		
		
//		ConvertedFileWriter writer = new ConvertedFileWriter();
//		writer.writeToFile(outputFileName, readData);
		
	}

	private static void printCommandlineArguments(String layoutFileName,
			String tableName, String comment, String rowFormat,
			String fieldsTerminatedBy, String linesTerminatedBy, String storedAs, String mfDataFileName, String outputFileName,String tablelocation) {
		System.out.println("fileName=[" + layoutFileName + "]");
		System.out.println("tableName=[" + tableName + "]");
		System.out.println("comment=[" + comment + "]");
		System.out.println("rowFormat=[" + rowFormat + "]");
		System.out.println("fieldsTerminatedBy=[" + fieldsTerminatedBy + "]");
		System.out.println("linesTerminatedBy[" + linesTerminatedBy + "]");
		System.out.println("storedAs=[" + storedAs + "]");
		System.out.println("mfDataFileName=[" + mfDataFileName + "]");
		System.out.println("outputFileName=[" + outputFileName + "]");
		System.out.println("tableLocation=[" + tablelocation + "]");
		
	}

	private static void printCommandError() {
		System.out.println("Invalid arguments!");
		System.out.println("SYNTAX:");
		System.out.println("java -jar Mf2Hadoop.jar <cbFileName> <hiveMf2HadoopConstants.TABleName> <comment> <rowFormat> <fieldsTerminatedBy> <linesTerminatedBy> <storedAs> <mfDataFileName> <outputFileName>");
		System.out.println("Sample usage:");
		System.out.println("java -jar Mf2Hadoop.jar hgduserm.copyc2.txt mRapidTable mRapid DELIMITED \\t \\n TEXTFILE hguserm.txt mf.txt");
	}
	
	
	
	

	

}
