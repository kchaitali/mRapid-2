package com.capgemini.mf2hadoop.reader;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;

import com.capgemini.mf2hadoop.domain.ByteDataDTO;

public class MFDataFileReaderWriter {
	private FileInputStream fileInputStream;
	private FileOutputStream fileOutputStream;
	
	public MFDataFileReaderWriter(String inputFileName, String outputFilename) throws FileNotFoundException{
		fileInputStream = new FileInputStream(inputFileName);
		fileOutputStream = new FileOutputStream(outputFilename);
	}
		
	public ByteDataDTO readBytesFromTheDataFile(int noOfBytesToBeRead) throws IOException{
		ByteDataDTO dto = null;
        int bytesRead;

        byte[] byteArray = new byte[noOfBytesToBeRead];
        bytesRead = fileInputStream.read(byteArray);
        if(bytesRead != -1){
        	dto = new ByteDataDTO();
            if(bytesRead<noOfBytesToBeRead){
            	byteArray=Arrays.copyOf(byteArray, bytesRead);
            	dto.setEndOfFileFlag(true);
            }
           	dto.setByteArray(byteArray);
        }
		return dto;
	}

	public void write(String value, String seperator) throws IOException {
		if(value!=null && !value.isEmpty()){
			fileOutputStream.write(value.getBytes());
		}
		fileOutputStream.write(seperator.getBytes());
	}
	
	public void closeFileStreams() throws IOException{
		fileInputStream.close();
		fileOutputStream.close();
	}
	
}
