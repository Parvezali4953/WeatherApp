# Use official Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy requirements.txt first (if available), else install manually
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of the app files
COPY . .

# Set environment variables
ENV API_KEY=$API_KEY

# Create a directory for logs
RUN mkdir -p /app/logs
VOLUME /app/logs

# Expose port (Flask default)
EXPOSE 5000

# Run the Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]