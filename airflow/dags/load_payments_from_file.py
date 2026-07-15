from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime
from glob import glob
import pandas as pd
from pathlib import Path
import csv
from datetime import datetime

@dag(
    dag_id            = "load_payments_from_file",
    description       = "Load data from CSV file to bronze and silver db",
    schedule_interval = "* * * * *",
    start_date        = datetime(2026, 7, 1),
    catchup           = False,
    tags              = ["finale"],
    default_args      = {
        "owner": "garong, kocheng",
    }
)
def main():
    @task
    def load_file_payments(**kwargs):
        xcom_store = kwargs["ti"]
        payments_raw_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "payments" 
        payments_done_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "payments" / "done"
        if (not(payments_done_path.is_dir())):
            payments_done_path.mkdir()
        payments_raw_files = glob(str(payments_raw_path / "*.csv"))
        loaded_data = None
        for file_obj in payments_raw_files:
            loaded_data = []
            file_obj_split = file_obj.split('/')
            file_name = file_obj_split[-1]
            raw_file_path = payments_raw_path / file_name
            file_name_split = file_name.split('.')[0].split('_')
            date_format = "%Y%m%d %H%M%S"
            file_datetime = datetime.strptime(file_name_split[-2] + ' ' + file_name_split[-1], date_format)
            with open(raw_file_path) as csvfile:
                reader = csv.reader(csvfile)
                first_row = reader.__next__()
                first_row.append('modified')
                loaded_data.append(first_row)
                for row in reader:
                    row.append(file_datetime)
                    loaded_data.append(row)
            payments_done_file = payments_done_path / file_name
            raw_file_path.rename(payments_done_file)
        print(loaded_data)
        xcom_store.xcom_push(
           key   = "data",
           value = loaded_data
        )
    
    @task
    def db_access(**kwargs):
        xcom_store = kwargs["ti"]
        data = xcom_store.xcom_pull(
            task_ids = "load_file_payments",
            key      = "data"
        )
        
        if data != None:
            from airflow.providers.postgres.hooks.postgres import PostgresHook
            postgres_hook = PostgresHook("postgres_dwh") 

            with postgres_hook.get_conn() as db_conn:
                target_table = "bronze.payments"
                fields = data[0]
                data.pop(0)
                rows = data
                postgres_hook.insert_rows(
                    table=target_table, 
                    rows=rows, 
                    target_fields=fields,
                    commit_every=1
                )

    t1 = load_file_payments()
    t2 = db_access()
    t1 >> t2

main()

