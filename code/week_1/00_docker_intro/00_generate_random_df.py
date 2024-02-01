"""
Simple Python script that prints a dataframe of random 
numbers from a standard normal distribution based on the
input arguments.
"""

import sys

import numpy as np
import pandas as pd
from tabulate import tabulate

mu: float = float(sys.argv[1])
sigma: float = float(sys.argv[2])

np.random.seed(42)
df = pd.DataFrame(
{
    'date': pd.date_range('2022-01-01', periods=10, freq='1D'),
    'value': mu + sigma * np.random.randn(10)
})

print(tabulate(df))
