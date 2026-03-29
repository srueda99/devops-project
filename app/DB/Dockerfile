FROM postgres:16-alpine

# Fix CVEs
RUN apk update && apk upgrade --no-cache
# Copy the SQL script to create the dummy data
COPY data.sql /docker-entrypoint-initdb.d/data.sql
# Expose the port
EXPOSE 5432