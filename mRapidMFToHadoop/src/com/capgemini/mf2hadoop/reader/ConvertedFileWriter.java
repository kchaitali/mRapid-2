package com.capgemini.mf2hadoop.reader;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.domain.DataDTO;
import com.capgemini.mf2hadoop.domain.FieldData;
import com.capgemini.mf2hadoop.domain.FieldDataObjectList;
import com.capgemini.mf2hadoop.domain.FieldDataSingleObject;
import com.capgemini.mf2hadoop.domain.FieldDataStructuredObjectList;

public class ConvertedFileWriter {
	private File file;

	public void writeToFile(String outputFileName, List<Map<String, FieldData>> readData) throws IOException {
		file = (file==null)?new File(outputFileName):file;
		
		for(Map<String, FieldData> map: readData){
			for(Map.Entry<String , FieldData> entry: map.entrySet()){
				FieldData fieldData = entry.getValue();
				if(fieldData instanceof FieldDataSingleObject){
					printSingleObject((FieldDataSingleObject) fieldData);
				}else if(fieldData instanceof FieldDataObjectList){
					printListedObject((FieldDataObjectList) fieldData);
				}else if(fieldData instanceof FieldDataStructuredObjectList){
					printStructuredObjectList((FieldDataStructuredObjectList) fieldData);
				}
			}
			FileUtils.writeStringToFile(file, Mf2HadoopConstants.OUTPUT_RECORDS_SEPERATOR, true);
		}
	}

	private void printListedObject(FieldDataObjectList fieldData) throws IOException {
		List<DataDTO> dtoList = fieldData.getDtoList();
		for(DataDTO dto: dtoList){
			printDTO(dto);
		}
	}

	private void printStructuredObjectList(FieldDataStructuredObjectList fieldData) throws IOException {
		List<Map<String, DataDTO>> mapList = fieldData.getMapList();
		for(Map<String, DataDTO> map: mapList){
			for(Map.Entry<String, DataDTO> entry: map.entrySet()){
				printDTO(entry.getValue());
			}
		}
	}

	private void printSingleObject(FieldDataSingleObject fieldData) throws IOException {
		printDTO(fieldData.getDto());
	}

	private void printDTO(DataDTO dto) throws IOException {
		FileUtils.writeStringToFile(this.file, dto.getValue(), true);
		FileUtils.writeStringToFile(this.file, Mf2HadoopConstants.OUTPUT_FIELDS_SEPERATOR, true);
	}
}
