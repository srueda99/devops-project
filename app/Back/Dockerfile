FROM python:3.12-slim

# Optimize Python
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1
# Set working directory
WORKDIR /app
# Install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt
# Copy the source code
COPY . .
# Create a non-root user
RUN useradd -m rabbit \
    && chown -R rabbit:rabbit /app
USER rabbit
# Expose the port
EXPOSE 8000
# Run the application
CMD ["fastapi", "run", "main.py", "--host", "0.0.0.0", "--port", "8000"]
