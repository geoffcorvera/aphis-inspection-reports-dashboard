from sqlite_utils import Database
import pandas as pd

def read_csv_file(filepath, pk=None):
    df = pd.read_csv(filepath)
    df.drop_duplicates(subset=pk, inplace=True)
    return df.to_dict('records')
    
def create_db():
    db = Database('aphis_reports.db', recreate=True)

    inspection_rows = read_csv_file('aphis-inspection-reports/data/combined/inspections.csv', pk=['hash_id'])
    db['inspections'].insert_all(inspection_rows, pk='hash_id')

    citations_rows = read_csv_file('aphis-inspection-reports/data/combined/inspections-citations.csv')
    db['citations'].insert_all(citations_rows, foreign_keys=[('hash_id', 'inspections', 'hash_id')])

if __name__ == '__main__':
    create_db()