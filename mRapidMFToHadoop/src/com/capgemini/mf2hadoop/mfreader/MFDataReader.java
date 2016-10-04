package com.capgemini.mf2hadoop.mfreader;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.capgemini.mf2hadoop.constants.Mf2HadoopConstants;
import com.capgemini.mf2hadoop.converter.EbcdicToAsciiConverter;
import com.capgemini.mf2hadoop.domain.ByteDataDTO;
import com.capgemini.mf2hadoop.domain.DataDTO;
import com.capgemini.mf2hadoop.domain.Field;
import com.capgemini.mf2hadoop.domain.FieldData;
import com.capgemini.mf2hadoop.domain.FieldDataObjectList;
import com.capgemini.mf2hadoop.domain.FieldDataSingleObject;
import com.capgemini.mf2hadoop.domain.FieldDataStructuredObjectList;
import com.capgemini.mf2hadoop.reader.MFDataFileReaderWriter;
import com.capgemini.mf2hadoop.utils.MF2HadoopUtils;

public class MFDataReader {

	public void readData(List<Field> fieldListFromTheLayoutFile,
			MFDataFileReaderWriter mfDataFileReaderWriter) throws Exception {
		Map<String, FieldData> fieldDataMap = null;

		int noOfFields = fieldListFromTheLayoutFile.size();
		for (int i = 0; i < noOfFields; i++) {
			if (i == 0) {
				if (fieldDataMap != null) {
					writeARecordToTheFile(mfDataFileReaderWriter, fieldDataMap);
					fieldDataMap = null;
				}
				fieldDataMap = new LinkedHashMap<String, FieldData>();
			}

			Field field = fieldListFromTheLayoutFile.get(i);
			String dataType = field.getDataType();
			int fieldLengthInBytes = 0;
			if (isStructuredField(field)) {
				FieldDataStructuredObjectList structuredObject = new FieldDataStructuredObjectList();
				List<Map<String, DataDTO>> mapArray = new ArrayList<Map<String, DataDTO>>();

				List<Field> childList = field.getChildList();
				String dependentOnFieldName = field.getDependentOnFieldName();
				if (dependentOnFieldName != null
						&& !dependentOnFieldName.isEmpty()) {
					FieldData fieldData = fieldDataMap
							.get(dependentOnFieldName);
					if (fieldData instanceof FieldDataSingleObject) {
						FieldDataSingleObject singleObject = (FieldDataSingleObject) fieldData;
						// Assuming dependent on field will always contain an
						// integer value
						int occursCount = Integer.parseInt(singleObject
								.getDto().getValue());
						field.setOccursCount(occursCount);
						singleObject = null;
					}
				}
				int occurances = field.getOccursCount();
				for (int loopIndex = 0; loopIndex < occurances; loopIndex++) {
					Map<String, DataDTO> map = new LinkedHashMap<String, DataDTO>();
					for (Field childField : childList) {
						fieldLengthInBytes = MF2HadoopUtils
								.extractAtomicFieldLength(childField
										.getDataType());
						ByteDataDTO readBytesDTO = readAnAtomicField(
								mfDataFileReaderWriter, dataType,
								fieldLengthInBytes);
						// If read till end of the data file
						if (readBytesDTO == null
								|| readBytesDTO.isEndOfFileFlag()) {
							return;
						} else {
							DataDTO dto = convertToAscii(readBytesDTO,
									childField.getDataType());
							// System.out.println("FieldName=" +
							// childField.getFieldName() + "|DataType="
							// + childField.getDataType() + "|Fieldlength=" +
							// fieldLengthInBytes + "|value="
							// + dto.getValue() + "|occurance=" + loopIndex);
							map.put(childField.getFieldName(), dto);
						}
					}
					mapArray.add(map);
				}
				structuredObject.setMapList(mapArray);
				fieldDataMap.put(field.getFieldName(), structuredObject);
			} else if (isArrayField(field)) {
				fieldLengthInBytes = MF2HadoopUtils
						.extractAtomicFieldLength(dataType);
				String dependentOnFieldName = field.getDependentOnFieldName();
				if (dependentOnFieldName != null
						&& !dependentOnFieldName.isEmpty()) {
					FieldData fieldData = fieldDataMap
							.get(dependentOnFieldName);
					if (fieldData instanceof FieldDataSingleObject) {
						FieldDataSingleObject singleObject = (FieldDataSingleObject) fieldData;
						// Assuming dependent on field will always contain an
						// integer value
						int occursCount = Integer.parseInt(singleObject
								.getDto().getValue());
						field.setOccursCount(occursCount);
						singleObject = null;
					}
				}
				int occursCount = field.getOccursCount();
				FieldDataObjectList listObject = new FieldDataObjectList();
				List<DataDTO> dtoList = null;
				for (int index = 0; index < occursCount; index++) {
					ByteDataDTO readBytesDTO = readAnAtomicField(
							mfDataFileReaderWriter, dataType,
							fieldLengthInBytes);
					// If read till end of the data file
					if (readBytesDTO == null || readBytesDTO.isEndOfFileFlag()) {
						return;
					} else {
						DataDTO dto = convertToAscii(readBytesDTO, dataType);
						// System.out.println("FieldName=" +
						// field.getFieldName() + "|DataType=" +
						// field.getDataType()
						// + "|Fieldlength=" + fieldLengthInBytes + "|value=" +
						// dto.getValue() + "|occurance="
						// + index);
						dtoList = (dtoList == null) ? new ArrayList<DataDTO>()
								: dtoList;
						dtoList.add(dto);
					}
				}
				listObject.setDtoList(dtoList);
				fieldDataMap.put(field.getFieldName(), listObject);
			} else {
				fieldLengthInBytes = MF2HadoopUtils
						.extractAtomicFieldLength(dataType);
				FieldDataSingleObject singleObject = new FieldDataSingleObject();

				ByteDataDTO readBytesDTO = readAnAtomicField(
						mfDataFileReaderWriter, dataType, fieldLengthInBytes);

				// If read till end of the data file
				if (readBytesDTO == null || readBytesDTO.isEndOfFileFlag()) {
					return;
				} else {
					DataDTO dto = convertToAscii(readBytesDTO, dataType);

					// System.out.println("FieldName=" + field.getFieldName() +
					// "|DataType=" + field.getDataType()
					// + "|Fieldlength=" + fieldLengthInBytes + "|value=" +
					// dto.getValue());
					singleObject.setDto(dto);
					fieldDataMap.put(field.getFieldName(), singleObject);
				}
			}

			i = i == (noOfFields - 1) ? -1 : i;
		}
	}

	private void writeARecordToTheFile(
			MFDataFileReaderWriter mfDataFileReaderWriter,
			Map<String, FieldData> fieldDataMap) throws IOException {
		int x = fieldDataMap.size();
		int count = 1;
		String separator = "";

		for (Map.Entry<String, FieldData> entry : fieldDataMap.entrySet()) {
			if (count == x)
				separator = "";
			else
				separator = Mf2HadoopConstants.OUTPUT_FIELDS_SEPERATOR;

			FieldData fieldData = entry.getValue();
			if (fieldData instanceof FieldDataSingleObject) {
				FieldDataSingleObject singleObject = (FieldDataSingleObject) fieldData;

				mfDataFileReaderWriter.write(singleObject.getDto().getValue(),
						separator);

			} else if (fieldData instanceof FieldDataObjectList) {
				FieldDataObjectList objectList = (FieldDataObjectList) fieldData;
				List<DataDTO> dtoList = objectList.getDtoList();
				int countFields = 1;
				for (DataDTO dto : dtoList) {
					if (countFields == dtoList.size())
						mfDataFileReaderWriter.write(dto.getValue(), separator);
					else
						mfDataFileReaderWriter.write(dto.getValue(),
								Mf2HadoopConstants.ARRAY_FIELDS_SEPERATOR);

					countFields++;
				}

			} else if (fieldData instanceof FieldDataStructuredObjectList) {
				FieldDataStructuredObjectList structuredObject = (FieldDataStructuredObjectList) fieldData;
				List<Map<String, DataDTO>> mapList = structuredObject
						.getMapList();
				int countMap = 1;
				for (Map<String, DataDTO> mapDTO : mapList) {

					int countFields = 1;
					for (Map.Entry<String, DataDTO> dtoEntry : mapDTO
							.entrySet()) {

						if (countFields == mapDTO.size())
							if (countMap == mapList.size())
								mfDataFileReaderWriter.write(dtoEntry
										.getValue().getValue(), "");
							else
								mfDataFileReaderWriter
										.write(dtoEntry.getValue().getValue(),
												Mf2HadoopConstants.ARRAY_FIELDS_SEPERATOR);
						else
							mfDataFileReaderWriter.write(dtoEntry.getValue()
									.getValue(),
									Mf2HadoopConstants.STRUCT_FIELDS_SEPERATOR);

						countFields++;
					}
					countMap++;
				}
			}
			count++;
		}
		mfDataFileReaderWriter.write(null,
				Mf2HadoopConstants.OUTPUT_RECORDS_SEPERATOR);
	}

	private ByteDataDTO readAnAtomicField(
			MFDataFileReaderWriter mfDataFileReaderWriter, String dataType,
			int fieldLengthInBytes) throws IOException {
		ByteDataDTO readBytesDTO = mfDataFileReaderWriter
				.readBytesFromTheDataFile(fieldLengthInBytes);
		return readBytesDTO;
	}

	private DataDTO convertToAscii(ByteDataDTO readBytesDTO, String dataType)
			throws Exception {
		EbcdicToAsciiConverter converter = new EbcdicToAsciiConverter();
		String asciiString = converter.convertToAscii(
				readBytesDTO.getByteArray(), dataType);

		DataDTO dto = new DataDTO();
		dto.setDataType(dataType);
		dto.setValue(asciiString);
		return dto;
	}

	private boolean isArrayField(Field field) {
		String dependentOnFieldName = field.getDependentOnFieldName();
		boolean isDependentField = dependentOnFieldName != null
				&& !dependentOnFieldName.isEmpty();
		return ((field.getChildList() == null || field.getChildList().isEmpty()) && (field
				.getOccursCount() > 0 || isDependentField));
	}

	private boolean isStructuredField(Field field) {
		return (field.getChildList() != null && !field.getChildList().isEmpty());
	}
}
