package com.capgemini.mf2hadoop.converter;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.nio.charset.Charset;
import java.util.Arrays;

import org.apache.commons.io.FileUtils;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.utils.MF2HadoopUtils;

public class EbcdicToAsciiConverter {
	
	public String convertToAscii(byte[] source, String dataType) throws Exception {
		String asciiString = null;
		if(Mf2HadoopConstants.STRING_FIELD.equalsIgnoreCase(MF2HadoopUtils.fieldType(dataType))){
			byte[] asciiArray = convert(source, java.nio.charset.Charset.forName("ebcdic-cp-us"), java.nio.charset.Charset.forName("ascii"));
			asciiString = new String(asciiArray, "UTF-8");
		}else{
			int decimalPosition = MF2HadoopUtils.getDecimalPosition(dataType);
			if(decimalPosition>0){
				if(MF2HadoopUtils.isComputational(dataType)>0){
					asciiString = MF2HadoopUtils.unpackData(source, decimalPosition);
				}else{
					byte[] asciiArray = convert(source, java.nio.charset.Charset.forName("ebcdic-cp-us"), java.nio.charset.Charset.forName("ascii"));
					asciiString = new String(Arrays.copyOfRange(asciiArray, 0, decimalPosition-1), "UTF-8") + new String(".") + 
							new String(Arrays.copyOfRange(asciiArray, decimalPosition, asciiArray.length-1), "UTF-8");
				}
			}else{
				if(MF2HadoopUtils.isComputational(dataType)>0){
					asciiString = MF2HadoopUtils.unpackData(source, 0);
				}else{
					byte[] asciiArray = convert(source, java.nio.charset.Charset.forName("ebcdic-cp-us"), java.nio.charset.Charset.forName("ascii"));
					asciiString = new String(asciiArray, "UTF-8");
				}
			}
		}
		return asciiString;
	}
	
	@SuppressWarnings("deprecation")
	private byte[] convert(byte[] source, Charset from, Charset to) {
		  byte[] result = new String(source, from).getBytes(to);
		  if (result.length != source.length) {
		    throw new AssertionError(result.length + "!=" + source.length);
		  }
//		  try {
//			FileUtils.writeByteArrayToFile(file, result, true);
//			FileUtils.writeStringToFile(new File("mf.txt"), "|", true);
//		} catch (IOException e) {
//			// TODO Auto-generated catch block
//			e.printStackTrace();
//		}
		  return result;
	}
}
