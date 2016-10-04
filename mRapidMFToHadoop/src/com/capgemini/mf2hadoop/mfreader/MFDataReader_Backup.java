package com.capgemini.mf2hadoop.mfreader;

import java.io.File;
import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;

import com.capgemini.mf2hadoop.converter.EbcdicToAsciiConverter;
import com.capgemini.mf2hadoop.domain.DataDTO;
import com.capgemini.mf2hadoop.domain.Field;
import com.capgemini.mf2hadoop.domain.FieldData;
import com.capgemini.mf2hadoop.domain.FieldDataObjectList;
import com.capgemini.mf2hadoop.domain.FieldDataSingleObject;
import com.capgemini.mf2hadoop.domain.FieldDataStructuredObjectList;
import com.capgemini.mf2hadoop.utils.MF2HadoopUtils;

public class MFDataReader_Backup {

	public List<Map<String, FieldData>> readData(List<Field> fieldListFromTheLayoutFile, String mfDataFileName) throws Exception {
		List<Map<String, FieldData>> mapList = new ArrayList<Map<String,FieldData>>();
		Map<String, FieldData> fieldDataMap= null;
		
		
		byte[] readFileToByteArray = FileUtils.readFileToByteArray(new File(mfDataFileName));
		int readFileToByteArrayLength = readFileToByteArray.length;
		int headPosition=0;
		
		int noOfFields= fieldListFromTheLayoutFile.size();
		for(int i=0;i<noOfFields;i++){
			//if all the bytes of the mf file have been read
			if(headPosition>=readFileToByteArrayLength){
				break;
			}
			if(i==0){
				fieldDataMap= new LinkedHashMap<String, FieldData>();
			}
			
			Field field = fieldListFromTheLayoutFile.get(i);
			String dataType = field.getDataType();
			int fieldLengthInBytes=0;
			if(isStructuredField(field)){
				FieldDataStructuredObjectList structuredObject = new FieldDataStructuredObjectList();
				List<Map<String, DataDTO>> mapArray = new ArrayList<Map<String,DataDTO>>();
				
				List<Field> childList = field.getChildList();
				String dependentOnFieldName = field.getDependentOnFieldName();
				if(dependentOnFieldName!=null && !dependentOnFieldName.isEmpty()){
					 FieldData fieldData = fieldDataMap.get(dependentOnFieldName);
					 if(fieldData instanceof FieldDataSingleObject){
						 FieldDataSingleObject singleObject = (FieldDataSingleObject)fieldData;
						 //Assuming dependent on field will always contain an integer value
						 int occursCount = Integer.parseInt(singleObject.getDto().getValue());
						 field.setOccursCount(occursCount);
					 }
				}
				int occurances = field.getOccursCount();
				for(int loopIndex=0;loopIndex<occurances;loopIndex++){
					Map<String, DataDTO> map = new LinkedHashMap<String, DataDTO>();
					for(Field childField : childList){
						fieldLengthInBytes = MF2HadoopUtils.extractAtomicFieldLength(childField.getDataType());
						DataDTO dto = readAnAtomicField(readFileToByteArray,
								headPosition, dataType, fieldLengthInBytes);
						headPosition+=fieldLengthInBytes;
						map.put(childField.getFieldName(), dto);
					}
					mapArray.add(map);
				}
				structuredObject.setMapList(mapArray);
				fieldDataMap.put(field.getFieldName(), structuredObject);
			}else if(isArrayField(field)){
				fieldLengthInBytes = MF2HadoopUtils.extractAtomicFieldLength(dataType);
				int occursCount = field.getOccursCount();
				FieldDataObjectList listObject = new FieldDataObjectList();
				List<DataDTO> dtoList=null;
				for(int index=0;index<occursCount;index++){
					DataDTO dto = readAnAtomicField(readFileToByteArray,
							headPosition, dataType, fieldLengthInBytes);
					dtoList = (dtoList==null)?new ArrayList<DataDTO>():dtoList;
					dtoList.add(dto);
					headPosition+=fieldLengthInBytes;
				}
				listObject.setDtoList(dtoList);
				fieldDataMap.put(field.getFieldName(), listObject);
			}
			else{
				fieldLengthInBytes = MF2HadoopUtils.extractAtomicFieldLength(dataType);
				FieldDataSingleObject singleObject = new FieldDataSingleObject();
				
				DataDTO dto = readAnAtomicField(readFileToByteArray,
						headPosition, dataType, fieldLengthInBytes);
				
				singleObject.setDto(dto);
				headPosition+=fieldLengthInBytes;
				fieldDataMap.put(field.getFieldName(), singleObject);
			}

			mapList.add(fieldDataMap);
			i=i==(noOfFields-1)?-1:i;
		}
		return mapList;
	}

	private DataDTO readAnAtomicField(byte[] readFileToByteArray, int headPosition, String dataType,
			int fieldLengthInBytes) throws Exception {
		EbcdicToAsciiConverter converter= new EbcdicToAsciiConverter();
		byte[] copyOfRange = Arrays.copyOfRange(readFileToByteArray, headPosition, headPosition+fieldLengthInBytes);
		String asciiString = converter.convertToAscii(copyOfRange, dataType);
		
		DataDTO dto = new DataDTO();
		dto.setDataType(dataType);
		dto.setValue(asciiString);
		return dto;
	}
	
	private boolean isArrayField(Field field) {
		return ((field.getChildList()==null || field.getChildList().isEmpty()) && field.getOccursCount()>0);
	}

	private boolean isStructuredField(Field field) {
		return (field.getChildList()!=null && !field.getChildList().isEmpty());
	}
}
