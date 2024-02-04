import os

import pyarrow as pa
import pyarrow.parquet as pq

if 'data_exporter' not in globals():
    from mage_ai.data_preparation.decorators import data_exporter

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "/home/src/august-cirrus-399913-f3f3cf69d012.json"
PROJECT_ID = "august-cirrus-399913"
BUCKET_NAME = "dez_mage_august-cirrus-399913"
TABLE_NAME = "hw_2_nyc_taxi_data"
ROOT_PATH = f"{BUCKET_NAME}/{TABLE_NAME}" 

@data_exporter
def export_data(data, *args, **kwargs):
    """
    Exports data to GCS.

    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)
    """
    table = pa.Table.from_pandas(data)
    gcs = pa.fs.GcsFileSystem()
    pq.write_to_dataset(
        table,
        ROOT_PATH,
        partition_cols=["lpep_pickup_date"],
        filesystem=gcs
    )


