from airflow.decorators import dag, task
from airflow.operators.bash import BashOperator
from datetime import datetime
from glob import glob
import pandas as pd
from pathlib import Path
import csv

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
    def load_file_categories():
        categories_raw_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "categories" 
        categories_done_path = Path.cwd() / "data" / "raw" / "raw_csv_file" / "categories" / "done"
        if (categories_done_path.is_dir()):
            categories_done_path.mkdir()
        categories_raw_files = glob(str(categories_raw_path / "*.csv"))
        for file_obj in categories_raw_files:
            file_obj_split = file_obj.split('/')
            file_obj_split[-1]
            raw_file_path = categories_raw_path / file_obj_split[-1]
            with open(raw_file_path) as csvfile:
                reader = csv.reader(csvfile)
                first_row = reader.__next__()
                sql_command = "INSERT INTO bronze.categories (category_id, category_name) VALUES ("
                for row in reader:
                    sql_command_row = sql_command + row[0] + "," + row[1] + ")"
                    print(sql_command_row)

            

    
    @task
    def db_access():
        from airflow.providers.postgres.hooks.postgres import PostgresHook

        postgres_hook = PostgresHook("postgres_dwh").get_sqlalchemy_engine()

        with postgres_hook.connect() as conn:
            df = pd.read_sql(
                sql = "SELECT * FROM customers",
                con = conn,
            )
        print(df)
    t1 = load_file()
    t2 = db_access()
    t3 = load_file_categories()
    t1 >> t2
    t3

main()

