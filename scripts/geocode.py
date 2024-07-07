from dotenv import load_dotenv
import json
import requests
import os
from sqlite_utils import Database
import urllib.parse
from tqdm import tqdm

load_dotenv()

geocodes_filename = 'geocode.json'

def _geocode(address):
    try:
        escaped = urllib.parse.quote(address)
    except TypeError as e:
        print(address, e)
        return 0,0
    url = f"https://maps.googleapis.com/maps/api/geocode/json?address={escaped}&key={os.environ['GOOGLE_MAPS_API_KEY']}"
    # print(url)
    r = requests.get(url)
    j = r.json()['results'][0]
    # print(address)
    # print(json.dumps(j, indent=2))
    return j['geometry']['location']['lat'], j['geometry']['location']['lng']

addy_dict = {}
def geocode(address):
    if address in addy_dict:
        return addy_dict[address]
    addy_dict[address] = _geocode(address)
    return addy_dict[address]

def load_geocode_json():
    try:
        with open(geocodes_filename) as f:
            j = json.loads(f.read())
    except:
        j = []
    
    for row in j:
        addy_dict[row['pdf_customer_addr']] = row['lat'], row['lng']
    

db = Database('aphis_reports.db', recreate=False)
for row in tqdm(db.query('select hash_id, pdf_customer_addr, customer_state from inspections')):
    # print(row)
    lat,lng = geocode(row['pdf_customer_addr'])
    try:
        with open(geocodes_filename) as f:
            j = json.loads(f.read())
    except:
        j = []
    j.append({"lat": lat, "lng": lng, **row})
    with open('_geocode.json', 'w') as f:
        f.write(json.dumps(j))
    os.rename('_geocode.json', geocodes_filename)
