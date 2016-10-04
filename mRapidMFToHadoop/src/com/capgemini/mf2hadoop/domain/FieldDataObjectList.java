package com.capgemini.mf2hadoop.domain;

import java.util.List;

public class FieldDataObjectList implements FieldData {
	private List<DataDTO> dtoList;

	public List<DataDTO> getDtoList() {
		return dtoList;
	}

	public void setDtoList(List<DataDTO> dtoList) {
		this.dtoList = dtoList;
	}
	
}
