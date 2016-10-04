#!/usr/bin/env python

from sas7bdat import SAS7BDAT
import sys, getopt

def main(argv):
	inputfile = ''
	try:
		opts, args = getopt.getopt(argv,"hi:",["ifile="])
	except getopt.GetoptError:
		print 'sas7bdat_convert.py -i <input_file>'
		sys.exit(1)
	for opt, arg in opts:
		if opt == '-h':
			print 'sas7bdat_convert.py -i <input_file>'
			sys.exit()
		elif opt in ("-i", "--ifile"):
			inputfile = arg
	if inputfile != '':
		with SAS7BDAT(inputfile) as f:
			for row in f:
				print row
	else:
		print 'sas7bdat_convert.py -i <input_file>'
		sys.exit(1)

if __name__ == "__main__":
	main(sys.argv[1:])
