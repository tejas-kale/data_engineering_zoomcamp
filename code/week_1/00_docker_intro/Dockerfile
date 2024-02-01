FROM python:3.10

RUN pip install numpy pandas tabulate

WORKDIR /app
COPY 00_generate_random_df.py 00_generate_random_df.py

ENTRYPOINT ["python", "00_generate_random_df.py", "1", "0"]
