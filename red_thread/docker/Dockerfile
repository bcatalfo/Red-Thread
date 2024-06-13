# Use a smaller base image if possible
FROM python:3.8-slim

WORKDIR /app

COPY requirements.txt requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Set the PORT environment variable to the default Cloud Run port
ENV PORT 8080

# Expose the port the app runs on
EXPOSE $PORT

# Run the application
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
