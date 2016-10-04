package com.capgemini.mf2hadoop.constants;

public class Mf2HadoopConstants {
	public static final String TAB = "\t";
	public static final String NEW_LINE = "\n";
	public static final String CLOSING_ANGULAR_BRACKET = ">";
	public static final String OPEN_ANGULAR_BRACKET = "<";
	public static final int REDEFINES=0;
	public static final int OCCURS_AND_PIC=1;
	public static final int OCCURS_ONLY=2;
	public static final int PIC_ONLY=3;
	public static final String WHITE_SPACE=" ";
	public static final String COMMA_SEPERATOR=",";
	public static final String OPENING_PARENTHESIS="(";
	public static final String CLOSING_PARENTHESIS=")";
	public static final int ROOT_LEVEL_NO=01;
	public static final String DEPENDING_ON="DEPENDING";
	public static final String STRING_FIELD = "string";
	public static final String SIGNED_NUMBER= "signed";
	public static final String UNSIGNED_NUMBER= "unsigned";
	public static final String OUTPUT_FIELDS_SEPERATOR= "\u0001";//"\u0001"; // This is ^A
	public static final String OUTPUT_RECORDS_SEPERATOR= "\n";
	public static final String ARRAY_FIELDS_SEPERATOR="\u0002";//"\u0002"; // This is ^B
	public static final String STRUCT_FIELDS_SEPERATOR="\u0003";
}
