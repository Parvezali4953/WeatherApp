# Stage 1: Builder
FROM python:3.9-slim as builder
WORKDIR /app
ENV PATH=/root/.local/bin:$PATH

COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.9-slim
WORKDIR /app

# Create non-root user
RUN useradd -m appuser && \
    chown -R appuser:appuser /app
USER appuser

# Copy artifacts
COPY --from=builder --chown=appuser /root/.local /home/appuser/.local
COPY --chown=appuser app.py .
COPY --chown=appuser static/ ./static/
COPY --chown=appuser templates/ ./templates/

ENV PATH=/home/appuser/.local/bin:$PATH
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]