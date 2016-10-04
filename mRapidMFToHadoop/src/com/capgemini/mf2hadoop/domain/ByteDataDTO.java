package com.capgemini.mf2hadoop.domain;

public class ByteDataDTO {
	private byte[] byteArray;
	private boolean endOfFileFlag=false;
	public byte[] getByteArray() {
		return byteArray;
	}
	public void setByteArray(byte[] byteArray) {
		this.byteArray = byteArray;
	}
	public boolean isEndOfFileFlag() {
		return endOfFileFlag;
	}
	public void setEndOfFileFlag(boolean endOfFileFlag) {
		this.endOfFileFlag = endOfFileFlag;
	}
}
