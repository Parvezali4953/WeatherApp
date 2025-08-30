# Stage 1: Builder
FROM python:3.11-slim AS builder
WORKDIR /app
ENV PATH=/root/.local/bin:$PATH
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.11-slim
WORKDIR /app

# Create a non-root user and set ownership
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Copy installed packages and application code
COPY --from=builder --chown=appuser /root/.local /home/appuser/.local
COPY --chown=appuser app.py .
COPY --chown=appuser templates/ ./templates/
COPY --chown=appuser static/ ./static/
ENV PATH=/home/appuser/.local/bin:$PATH
EXPOSE 5000
#CMD ["gunicorn","--workers","2","--threads","2","--bind","0.0.0.0:5000","app:app"]
CMD ["gunicorn","--workers","2","--threads","2","--timeout","60","--access-logfile","-","--bind","0.0.0.0:5000","app:app"]