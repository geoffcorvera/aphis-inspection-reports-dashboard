import os
from sqlite_utils import Database

join_query = "select narrative, desc, web_siteName, kind, hash_id, web_inspectionDate, code, repeat, pdf_insp_type, pdf_animals_total, web_certType, pdf_customer_id, pdf_customer_name, pdf_customer_addr, customer_state, pdf_site_id, doccloud_url from citations natural join inspections"

def prejoin_data():
    db = Database('aphis_reports.db')
    db["citation_inspection"].drop(ignore=True)
    db["citation_inspection"].insert_all(db.query(join_query), foreign_keys=[('hash_id', 'inspections', 'hash_id')])

if __name__ == "__main__":
    if not os.path.exists("aphis_reports.db"):
        print("aphis_reports.db not found")
    else:
        prejoin_data()