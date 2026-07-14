from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime
from glob import glob
import pandas as pd
from pathlib import Path
import csv
from datetime import datetime

@dag(
    dag_id            = "load_data_from_file",
    description       = "Load data from CSV file to bronze db",
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
    def load_file():
        file_obj_ret = []
        file_paths = glob('data/raw/*/*/*.csv')
        for file_obj in file_paths:
            file_obj_split = file_obj.split('/')
            file_obj_tmp = {
                "folder" : file_obj_split[-2],
                "file" : file_obj_split[-1]
            }
            file_obj_ret.append(file_obj_tmp)
        print(file_obj_ret)

    @task
    def load_file_categories(**kwargs):
        xcom_store = kwargs["ti"]
        categories_raw_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "categories" 
        categories_done_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "categories" / "done"
        if (categories_done_path.is_dir()):
            categories_done_path.mkdir()
        categories_raw_files = glob(str(categories_raw_path / "*.csv"))
        loaded_data = []
        for file_obj in categories_raw_files:
            file_obj_split = file_obj.split('/')
            file_name = file_obj_split[-1]
            raw_file_path = categories_raw_path / file_name
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
        xcom_store.xcom_push(
           key   = "data",
           value = loaded_data
        )


            

    
    @task
    def db_access(**kwargs):
        xcom_store = kwargs["ti"]
        
        from airflow.providers.postgres.hooks.postgres import PostgresHook
        postgres_hook = PostgresHook("postgres_dwh") 

        with postgres_hook.get_conn() as db_conn:
            data = xcom_store.xcom_pull(
                task_ids = "load_file_categories",
                key      = "data"
            )
            print(data)
            target_table = "silver.categories"
            fields = data[0]
            data.pop(0)
            rows = data
            postgres_hook.insert_rows(
                table=target_table, 
                rows=rows, 
                target_fields=fields,
                commit_every=1
            )



    t1 = load_file_categories()
    t2 = db_access()
    t1 >> t2

main()

