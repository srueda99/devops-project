FROM postgres:16-alpine

# Copy the SQL script to create the dummy data
COPY data.sql /docker-entrypoint-initdb.d/data.sql
# Expose the port
EXPOSE 5432