import os
print(os.getcwd())
os.chdir("D:\\SmartTrader\\ProjectCA\\smart-trader\\trunk\\data")

# to install xlrd, follow http://www.wikihow.com/Install-Python-Packages-on-Windows-7

# -*- coding: utf-8 -*-
import xlrd
import csv
from os import sys

def csv_from_excel(excel_file):
    workbook = xlrd.open_workbook(excel_file)
    all_worksheets = workbook.sheet_names()
    for worksheet_name in all_worksheets:
        worksheet = workbook.sheet_by_name(worksheet_name)
        your_csv_file = open("csv\\" + ''.join([worksheet_name,'.csv']), 'wb')
        wr = csv.writer(your_csv_file, quoting=csv.QUOTE_ALL)

        for rownum in xrange(worksheet.nrows):
            wr.writerow([unicode(entry).encode("utf-8") for entry in worksheet.row_values(rownum)])
        your_csv_file.close()

# if __name__ == "__main__":
#     csv_from_excel(sys.argv[1])
# csv_from_excel("SP20090209.XLS")
 
for file in os.listdir("."):
    if file.endswith(".xls") or file.endswith(".XLS"):
        csv_from_excel(file)