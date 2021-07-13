#!/usr/bin/env python
# ############################################################################
# Programa: ipanauatlali.py
# Descripcion:
#          Programa que recopila informacion de una lista de direcciones ip's
# almacenadas en un archivo de texto. La informacion que recaba es: direccion
# ip, pais, region, ciudad, latitud y longitud. las cuales son almacenadas en
# un archivo con formato cvs.
# Autor: Victor J. Mejia Lara (@d4rkw01f)
##############################################################################

import requests
import time
import os.path as path
from lxml import etree
from progress.bar import Bar

import argparse
param = argparse.ArgumentParser(description="Get information of: country, region, city, latitud and longitud about a list of IP's ")
group = param.add_mutually_exclusive_group()
group.add_argument("-v","--verbose", help="show the version and result of the query", action="store_true")
param.add_argument("-V", "--version", help="Show the version", action="store_true")
param.add_argument("-f","--file", help="list of ip in file")
param.add_argument("-o","--out", help="output file by default is location.cvs", default="location.cvs")
args = param.parse_args()

verbose = False

if args.verbose and args.file:
    print ("Version 0.1")

    if not path.exists(args.file):
        quit()
    verbose = True
elif args.file:
    if not path.exists(args.file):
        quit()
elif args.version:
    print("Version 0.2")
else:
    print("Miss the -f option")
    quit()

try:
    ipFile = open(args.file,"r")
    audit = open(args.out, "w")

    tamarch = path.getsize(args.file)
except IOException:
    print("Error to open file")

print("Starting query")
contip = 0
size = 0
errorip = 0
error = False

bar = Bar('Loading', fill='#', max=tamarch, suffix='%(index)dB %(percent)d%% - %(eta)ds')
for ip in ipFile.readlines():
    size += len(ip);
    r = requests.get('http://ip-api.com/xml/'+ip.rstrip('\n'))
    ipxml = etree.XML(r.content)

    status = ipxml[0]
    if status.find('success') != -1:
        country = ipxml.find('country')
        region = ipxml.find('region')
        city = ipxml.find('city')
        lat  = ipxml.find('lat')
        lon = ipxml.find('lon')
        contip = contip + 1
        error = False
    else:
        errorip = errorip + 1
        error = True

    if verbose and not error:
        print("-------------------------------------------")
        print(country.text.encode('utf-8','replace'))
        print(region.text.encode('utf-8','replace'))
        print(city.text.encode('utf-8','replace'))
        print("Coordenadas " + lat.text + " , " + lon.text)
    else:
        bar.goto(size)
    audit.write(ip.rstrip('\n') + "," + country.text + "," + str(region.text) + "," + city.text + "," + lat.text + "," + lon.text + '\n')
    time.sleep(2)

bar.finish()
print("Query terminated")
print("Total ip query: " + repr(contip))
print("Error ip query: " + repr(errorip))

ipFile.close()
audit.close()
