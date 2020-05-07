import os
import sys
import yaml
import os.path as pt

def parse(filepath,lists):

	path,filename = pt.split(pt.abspath(filepath))

	# Try to read yml

	try:
		b = open(filepath,"r")
	except OSError:
		print ("File {} is not exists".format(filepath))
		return 0
	
	a = yaml.load(b)

	if 'src_files' in a:

		if 'pkg' in a['src_files']:
			for f in a['src_files']['pkg']:
				lists["pkg"].append(pt.join(path,f))

		if 'src' in a['src_files']:
			for f in a['src_files']['src']:
				lists["src"].append(pt.join(path,f))

		if 'filelist' in a['src_files']:
			for f in a['src_files']['filelist']:
				parse(pt.join(path,f),lists)

	return lists

def list_gen(filepath):

	lists = {}
	lists["pkg"] = []
	lists["src"] = []

	return parse(filepath,lists)

filelist_path = sys.argv[1]

lists = list_gen(filelist_path)

string = ''

for i in lists["pkg"]:
	string += i+" "

for i in lists["src"]:
	string += i+" "

print (string)




