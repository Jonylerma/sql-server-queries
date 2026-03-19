import sqlalchemy as sql
import pandas as pd
from sqlalchemy import create_engine

#1. extract: leer el CSV

df= pd.read_csv("orders.csv")
print("Datos originales")
print (df)