import sqlite3
import pandas as pd

def create_db():
    conn = sqlite3.connect('aphis_reports.db')

    inspection_data = pd.read_csv('aphis-inspection-reports/data/combined/inspections.csv')
    inspection_data.to_sql('inspections', conn, if_exists='replace', index=False)

    citations_data = pd.read_csv('aphis-inspection-reports/data/combined/inspections-citations.csv')
    citations_data.to_sql('citations', conn, if_exists='replace', index=False)

    conn.close()

if __name__ == '__main__':
    create_db()