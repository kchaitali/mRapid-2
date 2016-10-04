package com.capgemini.mf2hadoop.validation;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Mf2HadoopValidator {
	public static boolean isNotANumber(String token) {
		boolean valid=true;
		String regex = "[^0-9]";
		Pattern pattern = Pattern.compile(regex);
	    Matcher match = pattern.matcher(token);
	    if (match.find( )){
	    	valid=true;
	    } else {
	       valid=false;
	    }
		return valid;
	}

}
