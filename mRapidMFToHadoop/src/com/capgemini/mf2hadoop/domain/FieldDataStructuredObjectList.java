package com.capgemini.mf2hadoop.domain;

import java.util.List;
import java.util.Map;

public class FieldDataStructuredObjectList implements FieldData {
	private List<Map<String, DataDTO>> mapList;

	public List<Map<String, DataDTO>> getMapList() {
		return mapList;
	}

	public void setMapList(List<Map<String, DataDTO>> mapList) {
		this.mapList = mapList;
	}
}
