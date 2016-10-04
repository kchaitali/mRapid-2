package com.capgemini.mf2hadoop.utils;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;


public class MF2HadoopUtils {
	public static final int UNSIGNED_BYTE = 0xff;
	public static final int BITS_RIGHT = 0xf;
	  
	
	public static int extractAtomicFieldLength(String dataType){
		int fieldLengthInBytes =0;
		if(dataType.startsWith("X")){
			fieldLengthInBytes = getStringFieldLength(dataType);
		}else if(dataType.startsWith("S")){
			fieldLengthInBytes = getSignedNumberFieldLength(dataType);
		}else{
			fieldLengthInBytes = getUnsignedNumberFieldLength(dataType);
		}
		return fieldLengthInBytes;
	}
	
	public static String fieldType(String dataType){
		String type;
		if(dataType.startsWith("X")){
			type = Mf2HadoopConstants.STRING_FIELD;
		}else if(dataType.startsWith("S")){
			type = Mf2HadoopConstants.SIGNED_NUMBER;
		}else{
			type = Mf2HadoopConstants.UNSIGNED_NUMBER;
		}
		return type;
	}
	
	public static int isComputational(String dataType){
		return dataType.indexOf("COMP-");
	}
	
	public static String unpackData(byte[] packedData, int decimalPointLocation) {
        String unpackedData = "";
        final int negativeSign = 13;
        for (int currentByteIndex = 0; currentByteIndex < packedData.length; currentByteIndex++) {

            int firstDigit = ((packedData[currentByteIndex] >> 4) & 0x0f);
            int secondDigit = (packedData[currentByteIndex] & 0x0F);
            unpackedData += String.valueOf(firstDigit);
            if (currentByteIndex == (packedData.length - 1)) {
                if (secondDigit == negativeSign) {
                    unpackedData = "-" + unpackedData;
                }
            } else {
                unpackedData += String.valueOf(secondDigit);
            }
        }
        if (decimalPointLocation > 0) {
            unpackedData = unpackedData.substring(0, (decimalPointLocation - 1)) +
                            "." +
                            unpackedData.substring(decimalPointLocation);
        }
        return unpackedData;
    }
		
	private static int getSignedNumberFieldLength(String dataType) {
		return (getUnsignedNumberFieldLength(dataType.substring(1)));
	}

	private static int getStringFieldLength(String dataType) {
		int len =0;
		len = getParameterizedAndNonParameterizedLength(dataType);
		return len;
	}

	private static int getUnsignedNumberFieldLength(String dataType) {
		int len =0;
		int computational= isComputational(dataType);
		dataType= computational>=0?dataType.substring(0, computational).trim():dataType;
		if(dataType.contains("V")){
			String[] split = dataType.split("V");
			int len1= getParameterizedAndNonParameterizedLength(split[0]);
			int len2= getParameterizedAndNonParameterizedLength(split[1]);
			len+= len1+len2;
		}else{
			len+= getParameterizedAndNonParameterizedLength(dataType);
		}
		
		if(computational>=0){
			double doubleLength = (double)(len+1)/2;
			double ceil = Math.ceil(doubleLength);
//			System.out.println(dataType+"|len="+len +"doublelength=|" +doubleLength+"|ceil="+ceil);
			len=(int)ceil;
		}
		
		return len;
	}
	
	private static int getParameterizedAndNonParameterizedLength(String dataType){
		int len=0;
		if(dataType.indexOf(Mf2HadoopConstants.OPENING_PARENTHESIS)!=-1){
			int openParan = dataType.indexOf(Mf2HadoopConstants.OPENING_PARENTHESIS);
			int closeParan = dataType.indexOf(Mf2HadoopConstants.CLOSING_PARENTHESIS);
			if(closeParan-openParan==2){
				len = Integer.parseInt(dataType.substring(openParan +1, openParan +2));
			}else{
				len = Integer.parseInt(dataType.substring(dataType.indexOf(Mf2HadoopConstants.OPENING_PARENTHESIS) + 1, dataType.indexOf(Mf2HadoopConstants.CLOSING_PARENTHESIS)));
			}
		}else{
			len = dataType.trim().length();
		}
		return len;
	}

	public static int getDecimalPosition(String dataType) {
		int pos=0;
		if(dataType.contains("V")){
			String[] split = dataType.split("V");
			int len1= getParameterizedAndNonParameterizedLength(split[0]);
			pos=len1+1;
		}
		return pos;
	}
    


}
