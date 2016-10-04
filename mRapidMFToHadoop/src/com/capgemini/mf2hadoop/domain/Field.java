package com.capgemini.mf2hadoop.domain;

import java.util.List;

public class Field {
	private int levelNo;
	private String fieldName;
	private String dataType;
	private int occursCount=0;
	private List<Field> childList;
	private String dependentOnFieldName;
	
	public String getDependentOnFieldName() {
		return dependentOnFieldName;
	}
	public void setDependentOnFieldName(String dependingFieldName) {
		this.dependentOnFieldName = dependingFieldName;
	}
	public int getLevelNo() {
		return levelNo;
	}
	public void setLevelNo(int levelNo) {
		this.levelNo = levelNo;
	}
	public String getFieldName() {
		return fieldName;
	}
	public void setFieldName(String fieldName) {
		this.fieldName = fieldName;
	}
	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}
	public int getOccursCount() {
		return occursCount;
	}
	public void setOccursCount(int occursCount) {
		this.occursCount = occursCount;
	}
	public List<Field> getChildList() {
		return childList;
	}
	public void setChildList(List<Field> childList) {
		this.childList = childList;
	}
}
