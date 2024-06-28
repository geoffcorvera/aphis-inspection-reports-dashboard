from sqlite_utils import Database
import pandas as pd

def read_csv_file(filepath, pk=None):
    df = pd.read_csv(filepath).drop_duplicates(subset=pk)
    return df.to_dict('records')

join_query = "select narrative, desc, web_siteName, kind, hash_id, web_inspectionDate, code, repeat, pdf_insp_type, pdf_animals_total, web_certType, pdf_customer_id, pdf_customer_name, pdf_customer_addr, customer_state, pdf_site_id from citations natural join inspections"

def prejoin_data():
    db = Database('aphis_reports.db')
    db["citation_inspection"].drop(ignore=True)
    db["citation_inspection"].insert_all(db.query(join_query), foreign_keys=[('hash_id', 'inspections', 'hash_id')])

db = Database('aphis_reports.db', recreate=True)

inspection_rows = read_csv_file('aphis-inspection-reports/data/combined/inspections.csv', pk=['hash_id'])
db['inspections'].insert_all(inspection_rows, pk='hash_id')
citations_rows = read_csv_file('aphis-inspection-reports/data/combined/inspections-citations.csv')
db['citations'].insert_all(citations_rows, foreign_keys=[('hash_id', 'inspections', 'hash_id')])

prejoin_data()