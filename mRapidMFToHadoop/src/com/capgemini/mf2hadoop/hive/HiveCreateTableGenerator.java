package com.capgemini.mf2hadoop.hive;

import java.util.List;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.domain.Field;

public class HiveCreateTableGenerator {
	int filler_count;
	public HiveCreateTableGenerator(){
		filler_count = 0;
	}
	public StringBuffer generateCreateTableQuery(List<Field> fieldList,
			String tableName, String comment, String rowFormat,
			String fieldsTerminatedBy, String linesTerminatedBy, String storedAs,String tablelocation) {
		
		StringBuffer query = new StringBuffer("CREATE EXTERNAL TABLE IF NOT EXISTS ");
		query.append(tableName).append(Mf2HadoopConstants.OPENING_PARENTHESIS);
		for(int index=0;index<fieldList.size();index++){
			query.append(Mf2HadoopConstants.NEW_LINE);
			Field field=fieldList.get(index);
			if(field.getOccursCount()==0){
				query.append(getFieldDeclarationForQuery(field));
			}else if(field.getOccursCount()>0 && (field.getDataType()!=null && !field.getDataType().isEmpty())){
				query.append(getArrayDeclarationForQuery(field));
			}else if(field.getOccursCount()>0 && !field.getChildList().isEmpty()){
				query.append(getArrayOfStructDeclarationForQuery(field));
			}
			if(index < fieldList.size()-1){
				query.append(Mf2HadoopConstants.COMMA_SEPERATOR).append(Mf2HadoopConstants.WHITE_SPACE);
			}
		}
		query.append(Mf2HadoopConstants.CLOSING_PARENTHESIS);
		query.append(Mf2HadoopConstants.NEW_LINE).append("COMMENT '").append(comment).append("'");
		query.append(Mf2HadoopConstants.NEW_LINE).append("ROW FORMAT ").append(rowFormat);
		query.append(Mf2HadoopConstants.NEW_LINE).append("FIELDS TERMINATED BY '").append(fieldsTerminatedBy).append("'");
		query.append(Mf2HadoopConstants.NEW_LINE).append("COLLECTION ITEMS TERMINATED BY '").append(Mf2HadoopConstants.ARRAY_FIELDS_SEPERATOR).append("'");
		query.append(Mf2HadoopConstants.NEW_LINE).append("MAP KEYS TERMINATED BY '").append(Mf2HadoopConstants.STRUCT_FIELDS_SEPERATOR).append("'");
		query.append(Mf2HadoopConstants.NEW_LINE).append("LINES TERMINATED BY '").append(linesTerminatedBy).append("'");
		query.append(Mf2HadoopConstants.NEW_LINE).append("STORED AS ").append(storedAs);
		query.append(Mf2HadoopConstants.NEW_LINE).append("LOCATION '").append(tablelocation).append("'").append(";");
		
		return query;
	
	}
	
	private StringBuffer getArrayOfStructDeclarationForQuery(Field field){
		StringBuffer buffer = new StringBuffer();
		buffer.append(field.getFieldName().replace('-', '_')).append(Mf2HadoopConstants.WHITE_SPACE).append("array").append(Mf2HadoopConstants.OPEN_ANGULAR_BRACKET).append("struct").append(Mf2HadoopConstants.OPEN_ANGULAR_BRACKET);
		List<Field> childList = field.getChildList();
		for(int index=0;index<childList.size();index++){
			buffer.append(childList.get(index).getFieldName().replace('-', '_'));
			buffer.append(":");
			buffer.append(getHiveDataType(childList.get(index).getDataType()));
			if(index < childList.size()-1){
				buffer.append(Mf2HadoopConstants.COMMA_SEPERATOR).append(Mf2HadoopConstants.WHITE_SPACE);
			}
		}
		buffer.append(Mf2HadoopConstants.CLOSING_ANGULAR_BRACKET).append(Mf2HadoopConstants.CLOSING_ANGULAR_BRACKET);
		return buffer;
	}
	
	private StringBuffer getArrayDeclarationForQuery(Field field) {
		StringBuffer buffer = new StringBuffer();
		buffer.append(field.getFieldName().replace('-', '_')).append(Mf2HadoopConstants.WHITE_SPACE).append("array").append(Mf2HadoopConstants.OPEN_ANGULAR_BRACKET).append(getHiveDataType(field.getDataType())).append(Mf2HadoopConstants.CLOSING_ANGULAR_BRACKET);
		return buffer;
	}

	private StringBuffer getFieldDeclarationForQuery(Field field){
		StringBuffer buffer = new StringBuffer();
		String field_name;
		if(field.getFieldName().equalsIgnoreCase("filler")){
			field_name = "filler_" + filler_count;
			filler_count++;
		}
		else
			field_name = field.getFieldName().replace('-', '_');
		buffer.append(field_name + " " + getHiveDataType(field.getDataType()));
		return buffer;
	}

	private String getHiveDataType(String mfDataType) {
		if(mfDataType.startsWith("9(") || mfDataType.equals("9")){
			return "int";
		}else if(mfDataType.startsWith("X(")|| mfDataType.equalsIgnoreCase("X")){
			return "string";
		}else if(mfDataType.contains("COMP-")){
			return "double";
		}
		
		return "dataTypeNotFound";
	}


}
