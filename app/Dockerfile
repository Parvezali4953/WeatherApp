# --- Stage 1: Builder ---
# The goal of this stage is to install Python dependencies in a clean environment.
# Using a full OS image gives us the tools needed (like gcc) to build any packages.
FROM python:3.9-slim as builder

# Set the working directory inside the container
WORKDIR /app

# Best practice: Copy only the requirements file first to leverage Docker's build cache.
# The layer cache is only invalidated if this file changes, not the entire codebase.
COPY requirements.txt .

# Install dependencies. The --no-cache-dir flag keeps the image layer smaller.
RUN pip install --no-cache-dir -r requirements.txt


# --- Stage 2: Final Image ---
# This stage builds the final, lightweight image for production.
# We use a slim base image because it's smaller and has a reduced attack surface.
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Create a non-root user for security purposes.
# Running as a non-root user is a critical security best practice to limit
# the blast radius if the application is compromised.
RUN addgroup --system nonroot && adduser --system --ingroup nonroot nonroot
USER nonroot

# Copy installed dependencies from the 'builder' stage.
# This keeps the final image clean, without the build tools from the first stage.
COPY --from=builder /app /app

# Copy the application code into the final image
COPY . .

# Expose the port the application will run on.
# This doesn't publish the port, but documents it and makes it available for mapping.
EXPOSE 5000

# Set the API_KEY as an environment variable placeholder.
# Its value will be injected securely at runtime (e.g., by ECS Task Definition).
# DO NOT hardcode secrets in the Dockerfile.
ENV API_KEY=""

# The command to run the application using a production-grade WSGI server.
# Gunicorn is a robust choice for running Flask apps in production.
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
