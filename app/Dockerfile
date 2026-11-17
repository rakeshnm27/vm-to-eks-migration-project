
FROM python:3.12-slim

# Prevent Python from creating unnecessary bytecode files
ENV PYTHONDONTWRITEBYTECODE=1

# Send application logs directly to container output
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Create a non-root application user
RUN useradd --system --uid 10001 appuser

# Copy application with correct ownership
COPY --chown=10001:10001 app.py .

# Application port
EXPOSE 5000

# Run container health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health', timeout=3)"

# Run application as non-root
USER 10001:10001

CMD ["python", "app.py"]

