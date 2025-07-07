# parse Open Street Map opl file to a CSV file
import re
import csv
import datetime as dt

# parser function
def parse_opl_record(opl_record):

    # define the regex pattern for OPL file entries
    node_pattern = r'([nwr](\d+))'
    timestamp_pattern = r'( t(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}))'
    user_pattern = r'( i(\d+))'
    lon_pattern = r'( x(-?\d+.\d+))'
    lat_pattern = r'( y(-?\d+.\d+))'

    # initialize a dictionary to hold the parsed values
    record = {}

    # find node id
    match = re.search(node_pattern, opl_record)
    if match:
       record["node"] = int(match.group(0)[1:])
    else:
       record["node"] = None

    # find timestamp
    match = re.search(timestamp_pattern, opl_record)
    if match:
       record["timestamp"] = match.group(0)[2:]
    else:
       record["timestamp"] = None

    # find user id
    match = re.search(user_pattern, opl_record)
    if match:
       record["user"] = int(match.group(0)[2:])
    else:
       record["user"] = None

    # find longitude
    match = re.search(lon_pattern, opl_record)
    if match:
        record["lon"] = float(match.group(0)[2:]) # interpret as decimal degrees
    else:  
        record["lon"] = None

    # find latitude
    match = re.search(lat_pattern, opl_record)
    if match:
        record["lat"] = float(match.group(0)[2:]) # interpret as decimal degrees
    else:
        record["lat"] = None

    # print the parsed values - debug mode only...
    # print(f"record: {record}")

    return record

# print timestamp and start message
print(f'{dt.datetime.now()} starting to parse opl file...')

# read the opl file and write to csv - here be the action!
with open("data-raw/test.opl", "r") as myfile, open("data/history.csv",'w') as fw:
    writer = csv.writer(fw, delimiter=',')

    # iterate over the lines in the opl file
    for line in myfile:
        # parse the line and write to csv
        radek = parse_opl_record(line.strip()) 
        writer.writerow([radek["node"], radek["timestamp"], radek["user"], radek["lon"], radek["lat"]])

# print timestamp and succes message
print(f'{dt.datetime.now()} work finished, check data/history.csv for results...')