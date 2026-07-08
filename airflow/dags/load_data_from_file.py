from airflow.decorators import dag
from airflow.operators.bash import BashOperator
from datetime import datetime

@dag(
    dag_id            = "load_data_from_file",
    description       = "Load data from CSV file to silver db",
    schedule_interval = "* * * * *",
    start_date        = datetime(2026, 7, 1),
    catchup           = False,
    tags              = ["finale"],
    default_args      = {
        "owner": "garong, kocheng",
    }
)
def main():
    load_file = BashOperator(
        task_id = "cobacobasaja",
        bash_command = "echo test"
    )

    load_file

main()

