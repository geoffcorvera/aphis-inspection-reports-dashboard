from sqlite_utils import Database
import json

db = Database('aphis_reports.db', recreate=False)

try:
    with open('geocode.json') as f:
        j = json.loads(f.read())
except:
    j = []

db['geocodes'].insert_all(j)
db.execute("ALTER TABLE inspections ADD COLUMN lng double precision")
db.execute("ALTER TABLE inspections ADD COLUMN lat double precision")