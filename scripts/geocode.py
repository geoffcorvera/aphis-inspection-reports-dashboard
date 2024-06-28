from dotenv import load_dotenv
import json
import requests
import os
from sqlite_utils import Database

load_dotenv()

def _geocode(address):
    url = f"https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={os.environ['GOOGLE_MAPS_API_KEY']}"
    print(url)
    r = requests.get(url)
    j = r.json()['results'][0]
    print(address)
    print(json.dumps(j, indent=2))
    return j['geometry']['location']['lat'], j['geometry']['location']['lng']

addy_dict = {}
def geocode(address):
    if address in addy_dict:
        return addy_dict[address]
    addy_dict[address] = _geocode(address)
    return addy_dict[address]

geocode("14330 W. Sylvanfield Dr. Houston, TX 77014")

db = Database('aphis_reports.db', recreate=False)
for row in db.query('select hash_id, pdf_customer_addr, customer_state from inspections limit 10'):
    print(row)
    lat,lng = geocode(row['pdf_customer_addr'])
    try:
        with open('geocode.json') as f:
            j = json.loads(f.read())
    except:
        j = []
    j.append({"lat": lat, "lng": lng, **row})
    with open('_geocode.json', 'w') as f:
        f.write(json.dumps(j))
    os.rename('_geocode.json', 'geocode.json')
