from datetime import datetime

import pandas as pd

if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test

@transformer
def transform(data, *args, **kwargs):
    """
    Args:
        data: The output from the upstream parent block
        args: The output from any additional upstream blocks (if applicable)

    Returns:
        Cleaned dataframe
    """
    # Remove rows with invalid values.
    # For some reason, combining the two conditions in one
    # using the `|` operator does not work.
    data = data[data["passenger_count"] > 0]
    data = data[data["trip_distance"] > 0]

    # Create date column.
    data.loc[:, "lpep_pickup_date"] = data["lpep_pickup_datetime"].dt.date

    # # Convert column names to camel case.
    snake_case_columns = {
        "VendorID": "vendor_id",
        "RatecodeID": "ratecode_id",
        "PULocationID": "pu_location_id",
        "DOLocationID": "do_location_id"
    }
    data = data.rename(columns=snake_case_columns)

    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
    assert (output["passenger_count"] > 0).all()
    assert (output["trip_distance"] > 0).all()
    assert "vendor_id" in output.columns
