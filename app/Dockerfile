# Stage 1: Builder
# This stage installs all dependencies.
FROM python:3.11-slim AS builder

WORKDIR /app
COPY requirements.txt .

# Install all dependencies from requirements.txt
RUN pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime
# This stage creates the final, minimal, and secure image.
FROM python:3.11-slim

WORKDIR /app

# Create a dedicated, non-root user for security.
RUN adduser --system --no-create-home appuser

# Copy all installed Python packages AND their executables from the builder stage.
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy the application source code and set the correct owner.
COPY --chown=appuser:appuser . .

# Switch to the non-root user.
USER appuser

# Expose the port that the application will run on.
EXPOSE 5000

# The command to run the application.
# It's a best practice to use the full path to the executable.
CMD ["/usr/local/bin/gunicorn", "--workers", "4", "--bind", "0.0.0.0:5000", "app:app"]
