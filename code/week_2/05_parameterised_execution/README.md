## Parameterised execution

In this section, we learn how to use runtime parameters in Mage blocks. These
parameters are either available by default (like `execution_date`) or can be
specified:
- while executing a Mage pipeline using the API
- while defining a Mage pipeline using the UI
- while specifying a trigger for the pipeline

The parameters are available in each block in the `kwargs` argument.

*Note*: While we create a Postgres database container in this section using the same `docker-compose.yml` file as in the earlier sections, this database is not used and is thus redundant.
