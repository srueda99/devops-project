FROM postgres:16

# Copy the SQL script to create the dummy data
COPY data.sql /docker-entrypoint-initdb.d/data.sql
EXPOSE 5432