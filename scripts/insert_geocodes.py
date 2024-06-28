from sqlite_utils import Database
from sqlite3 import OperationalError
import json

def add_geo_cols(table: str, db: Database):
    try:
        db.execute(f"ALTER TABLE {table} ADD COLUMN lat double precision")
        db.execute(f"ALTER TABLE {table} ADD COLUMN lng double precision")
    except OperationalError:
        pass
    
try:
    with open('geocode.json') as f:
        j = json.loads(f.read())
except:
    j = []

db = Database('aphis_reports.db', recreate=False)
db['geocodes'].insert_all(j)
add_geo_cols('inspections', db)
add_geo_cols('citation_inspection', db)