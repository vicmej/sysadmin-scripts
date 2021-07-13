#!/usr/bin/env python
#########################################################
# Programa: tetenami.py
# Descripcion:
#   Programa que obtiene los segmentos de red del pais
#   que se encuentran registrados para bloquear segmentos de otros
#   paises.
# Autor: Victor J. Mejia Lara (@d4rkw01f)
#########################################################

import argparse
import os
import tempfile
from progress.bar import Bar

param = argparse.ArgumentParser(description="Get network from the country than you indicate to protect the servers o routers.")
group = param.add_mutually_exclusive_group()
group.add_argument("-v","--verbose", help="show the version and result of the query", action="store_true")
param.add_argument("-V","--version", help="show the version", action="store_true")
param.add_argument("-f","--file", help="Database of LACNIC")
param.add_argument("-c","--country", help="acronym of country", default="MX")
args = param.parse_args()

verbose = False

if args.verbose and args.file:
    print ("Version 0.1")

    if not os.path.exists(args.file):
        quit()
    verbose = True
elif args.file and args.country:
    if not os.path.exists(args.file) and not len(args.country) == 2:
        quit()
elif args.file:
    if not os.path.exists(args.file):
        quit()
elif args.version:
    print("Version 0.1")
else:
    print("Miss the -f option")
    quit()

if os.getuid() != 0:
    print("No tienes privilegios de root.")
    quit()

try:
    dbip = open(args.file,"r")
    temp = tempfile.TemporaryFile(mode="w+t")
except IOException:
    print("Error to open file")

def converIP(ipMsk):
    zeros = [".0.0.0",".0.0",".0",""]
    # Separa el segmento de red de la mascara
    ip_msk = ipMsk.split("/")
    # Separa en octetos el segmento de red
    octetos = ip_msk[0].split(".")
    #concatena con parte del segmento
    ip = ip_msk[0] + zeros[len(octetos)-1]+"/"+ip_msk[1]

    return ip

def creaMuro(ipr, total):
    print("\n\nTotal de IPs a ingresar: "+str(total))
    print("Ingresando reglas al firewall.")
    ipr.seek(0)
    count = 0
    bar = Bar('Cargando',fill='#', max=total, suffix='%(index)dB %(percent)d%% - %(eta)ds')
    for ip in ipr.readlines():
        firewall = "/usr/sbin/iptables -A INPUT -s "+ip.strip()+" -j ACCEPT"
        err = os.system(firewall)
        if err != 0:
            print("Error al insertar la regla en el firewall")
            break
        else:
            count += 1
            bar.goto(count)
    return

countIP = 0
segmento = {'inetnum':"",'status':"",'city':"",'country':"",'created':"",'changed':"",'source':""}

print("Buscando segmentos de red " + args.country)
size_archivo = len(dbip.readlines())
dbip.seek(0)
valor = dbip.readline()
size = 1
bar_archivo = Bar('Cargando', fill='#', max=size_archivo, suffix='%(index)dB %(percent)d%% - %(eta)ds')
while valor != '' :
    bar_archivo.goto(size)
    if valor.find("inetnum:") == 0:
        #Segmento de red
        dato = valor.split(':')
        segmento['inetnum'] = dato[1].strip()

        #Status del segmento de red
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['status'] = dato[1].strip()

        #La ciudad a la que pertenece
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['city'] = dato[1].strip()

        # Pais del segmento de red
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['country'] = dato[1].strip()
        if dato[1].strip() == "MX":
            ip = converIP(segmento['inetnum'])
            temp.write(ip+'\n')
            countIP += 1

        #Fecha de creacion
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['created'] = dato[1].strip()

        #Fecha de cambio
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['changed'] = dato[1].strip()

        # Origen del segmento
        valor = dbip.readline()
        dato = valor.split(':')
        segmento['source'] = dato[1].strip()
        size += 6

    elif valor.find("aut-num:") == 0:
        for i in range(5):
            dbip.readline()
            size += 1

    valor = dbip.readline()
    size += 1

creaMuro(temp, countIP)

dbip.close()
temp.close()
print("Direcciones ips de " + args.country + " : " + str(countIP))
