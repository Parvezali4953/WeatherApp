# Stage 1: Builder - Installs dependencies and prepares the app artifacts.

FROM python:3.11-slim AS builder
WORKDIR /app

# Copy requirements.txt FIRST to maximize caching.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code.
COPY . .

# Stage 2: Runtime - Creates a minimal and secure running environment.
FROM python:3.11-slim
WORKDIR /app

# REFINEMENT 1: SECURITY - Create a dedicated non-root user for running the application.
RUN adduser --system --no-create-home appuser
USER appuser 

# Copy necessary Python dependencies (runtime)
COPY --from=builder /usr/local/lib/python3.11 /usr/local/lib/python3.11
COPY --from=builder /usr/local/bin/gunicorn /usr/local/bin/

# Copy only the necessary application files needed at runtime
COPY --chown=appuser:appuser app.py .
COPY --chown=appuser:appuser templates/ ./templates/
COPY --chown=appuser:appuser static/ ./static/

EXPOSE 5000
# Use the absolute path for gunicorn, ensuring it runs as the appuser.
CMD ["/usr/local/bin/gunicorn", "--workers", "2", "--threads", "2", "--timeout", "60", "--access-logfile", "-", "--bind", "0.0.0.0:5000", "app:app"]
