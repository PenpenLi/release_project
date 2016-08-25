# -*- coding: UTF-8 -*-
import os
import re
import csv

def get_files():
    filenames=os.listdir('./')
    files=[]
    for name in filenames:
        m = re.match('sub_.*csv$', name)
        if(m!=None):
            files.append('./'+name)

    return files

def main():
    files = get_files()
    reader_f = csv.reader(open(files[0]))
    writer_f = open("称号条件触发表.csv",'w')
    field= reader_f.next()
    writer_f.write(','.join(field)+'\n')
    for row in reader_f:
        writer_f.write(','.join(row)+'\n')


    files = files[1:]
    for filename in files:
        reader_f = csv.reader(open(filename))
        tmp_field = reader_f.next()
        if(field!=tmp_field):
            print "Error,%s's field is different one or more other files" % filename
            break
        for row in reader_f:
            writer_f.write(','.join(row)+'\n')


if __name__ == '__main__':
    main()
