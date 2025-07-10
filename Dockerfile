# Use official Python image
FROM python:3.10-slim

# Set working directory
WORKDIR /WeatherApp

# Copy requirements.txt first (if available), else install manually
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy rest of the app files
COPY . .

# Expose port (Flask default)
EXPOSE 5000

# Run the Flask app
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]