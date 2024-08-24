FROM quay.io/astronomer/astro-runtime:11.7.0

# install soda into a virtual environment
RUN python -m venv soda_venv && \
    source soda_venv/bin/activate && \
    pip install --no-cache-dir soda-core-snowflake==3.3.12 && \
    pip install --no-cache-dir soda-core-scientific==3.3.12 && \
    deactivate

# install dbt into a virtual environment
# RUN python -m venv dbt_venv && \
#     source dbt_venv/bin/activate && \
#     pip install --no-cache-dir dbt-snowflake==1.8.3 && \
#     deactivate
