package com.capgemini.mf2hadoop.reader;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.nio.charset.Charset;
import java.util.Arrays;
import java.util.Scanner;

import org.apache.commons.io.FileUtils;

public class MFCopyBookReader {
	
	public StringBuffer readLayoutFile(String fileName) {
		StringBuffer buffer = new StringBuffer();
		try {
			File inputFile = new File(fileName);
			FileReader reader = new FileReader(inputFile);
			BufferedReader bufferedReader = new BufferedReader(reader);
			String line;
			while ((line = bufferedReader.readLine()) != null) {
				if(!line.trim().startsWith("*")){
					buffer.append(line);
				}
			}
			reader.close();
			if(buffer.length()==0){
				throw new IOException();
			}
		} catch (IOException e) {
			System.out.println("Error occured while reading the file from the source or the file is empty!");
			e.printStackTrace();
		}
		return buffer;
	}
	

}
