package com.capgemini.mf2hadoop;

import java.util.List;

import com.capgemini.mf2hadoop.domain.Field;
import com.capgemini.mf2hadoop.mfreader.MFDataReader;
import com.capgemini.mf2hadoop.parser.MFCopyBookParser;
import com.capgemini.mf2hadoop.reader.MFCopyBookReader;
import com.capgemini.mf2hadoop.reader.MFDataFileReaderWriter;

public class Mf2HadoopHDFS {
	public static void main(String[] args) throws Exception {
//		String layoutFileName = "gpdcgim.incl.txt";
//		String mfDataFileName="GPFCGIM_POC_PARTIAL.DAT";
//		String outputFileName="mf.txt";

		
		String layoutFileName = args[0];
		String mfDataFileName=args[1];
		String outputFileName=args[2];
		
		
		//Read the MF layout (copybook file)
		MFCopyBookReader reader = new MFCopyBookReader(); 
		StringBuffer layoutFileBuffer = reader.readLayoutFile(layoutFileName);
		
		//Parse the read layout file to retrieve the field list
		MFCopyBookParser parser = new MFCopyBookParser(); 
		List<Field> fieldList = parser.parseLayoutFile(layoutFileBuffer);
		
		MFDataFileReaderWriter mfDataFileReaderWriter = new MFDataFileReaderWriter(mfDataFileName, outputFileName);
		//Read the data from the mainframe ebcdic file
		MFDataReader mfReader = new MFDataReader();
		mfReader.readData(fieldList, mfDataFileReaderWriter);
		mfDataFileReaderWriter.closeFileStreams();
		
		
	}
}
