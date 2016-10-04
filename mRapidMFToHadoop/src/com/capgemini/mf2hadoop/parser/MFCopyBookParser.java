package com.capgemini.mf2hadoop.parser;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.domain.Field;
import com.capgemini.mf2hadoop.validation.Mf2HadoopValidator;

public class MFCopyBookParser {
	
	//change code
	public static int fcount = 0;
	
	public List<Field> parseLayoutFile(StringBuffer layoutFileBuffer) {
		List<Field> fieldList= new ArrayList<Field>();
		boolean readOneRecord=false;
		Field field=null;
		String layoutString = layoutFileBuffer.toString();
		String[] lines = layoutString.split("\\.");
		
		for(int i=0;i<lines.length;i++){
			String line = lines[i];
			if(isCommented(line)||!isFieldDeclaration(line)){
				continue;
			}
			int levelNo= readLevelNoFromTheLine(line);
			if(levelNo == Mf2HadoopConstants.ROOT_LEVEL_NO){
				if(readOneRecord){
					break;
				}else{
					readOneRecord=true;
				}
			}
			int filterValue= findFilterValue(line);
			
			if(filterValue==Mf2HadoopConstants.REDEFINES){
				i++;
				while((i<lines.length) && levelNo<readLevelNoFromTheLine(lines[i])){
					i++;
				}
				i--;
				continue;
			}else if(filterValue==Mf2HadoopConstants.OCCURS_ONLY){
				field = extractFieldInformation(line, filterValue);
				List<Field> childList= new ArrayList<Field>();
				i++;
				while((i<lines.length) && levelNo<readLevelNoFromTheLine(lines[i])){
					if(!isFieldDeclaration(lines[i])){
						i++;
						continue;
					}
					Field childField = extractFieldInformation(lines[i], findFilterValue(lines[i]));
					childList.add(childField);
					i++;
				}
				i--;
				field.setChildList(childList);
			}else if(filterValue==Mf2HadoopConstants.PIC_ONLY){
				field = extractFieldInformation(line, filterValue);
			} else if(filterValue==Mf2HadoopConstants.OCCURS_AND_PIC){
				field = extractFieldInformation(line, filterValue);
			}
			fieldList.add(field);
		}
		return fieldList;
	}
	
	//Method to ignore the comments in the layout file
	private boolean isCommented(final String line){
		return line.trim().startsWith("*");
	}
	
	//Method to check if its the field declaration which is to be picked up for hive query formation
	private boolean isFieldDeclaration(final String line){
		boolean valid=true;
		String regex = "(PIC|OCCURS)";
		Pattern pattern = Pattern.compile(regex);
	    Matcher match = pattern.matcher(line.toUpperCase());
	    if (match.find( )){
	    	valid=true;
	    } else {
	       valid=false;
	    }
		return valid;
	}
	
	private int findFilterValue(String line) {
		if(line.toUpperCase().contains("REDEFINES")){
			return Mf2HadoopConstants.REDEFINES;
		}else if(line.toUpperCase().contains("OCCURS") && line.toUpperCase().contains("PIC")){
			return Mf2HadoopConstants.OCCURS_AND_PIC;
		}else if(line.toUpperCase().contains("OCCURS")){
			return Mf2HadoopConstants.OCCURS_ONLY;
		}else if(line.toUpperCase().contains("PIC")){
			return Mf2HadoopConstants.PIC_ONLY;
		}
		return -1;
	}

	private int readLevelNoFromTheLine(String line) {
		int levelNo=0;
		String[] lineTokens= line.trim().split("\\s+");
		for(int i=0;i<lineTokens.length;i++){
			if(lineTokens[i].length()!=2 || Mf2HadoopValidator.isNotANumber(lineTokens[i])){
				continue;
			}
			else{
				levelNo= Integer.parseInt(lineTokens[i]);
				break;
			}
		}
		return levelNo;
	}

	private Field extractFieldInformation(String line, int filterValue) {
		Field field = new Field();
		int i=0;
		
		String[] lineTokens= line.trim().split("\\s+");
		for(i=0;i<lineTokens.length;i++){
			if(lineTokens[i].length()!=2 || Mf2HadoopValidator.isNotANumber(lineTokens[i])){
				continue;
			}
			else{
				break;
			}
		}
		
		int levelNo= Integer.parseInt(lineTokens[i]);
		String fieldName= lineTokens[i+1];
		
		if(fieldName.equalsIgnoreCase("filler")){
			fieldName = fieldName + "_" + fcount;
			fcount++;
		}
		
		
		boolean computational = false;
		int noOfTokens = lineTokens.length;
		if(filterValue==Mf2HadoopConstants.OCCURS_ONLY){
			int occursCount= Integer.parseInt(lineTokens[i+3]);
			field.setOccursCount(occursCount);
		}else{
			String dataType = lineTokens[i+3];
			if((i+4)<noOfTokens && lineTokens[i+4].startsWith("COMP-")){
				dataType+=(Mf2HadoopConstants.WHITE_SPACE + lineTokens[i+4]);
				computational=true;
			}
			field.setDataType(dataType);
		}
		if(filterValue==Mf2HadoopConstants.OCCURS_AND_PIC){
			int occursCount=0;
			if(computational && (i+6)<noOfTokens){
				occursCount= Integer.parseInt(lineTokens[i+6]);
			}else{
				if((i+5)<noOfTokens){
					occursCount= Integer.parseInt(lineTokens[i+5]);
				}
			}
			field.setOccursCount(occursCount);
		}
		
		//Map the depending on field
		if (line.contains(Mf2HadoopConstants.DEPENDING_ON)){
			for(int x=0;x<lineTokens.length;x++){
				if(Mf2HadoopConstants.DEPENDING_ON.equalsIgnoreCase(lineTokens[x])){
					field.setDependentOnFieldName(lineTokens[x+2]);
					break;
				}
			}
		}
		
		field.setLevelNo(levelNo);
		field.setFieldName(fieldName);
		return field;
	}

}
