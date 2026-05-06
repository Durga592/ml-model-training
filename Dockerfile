FROM python:3.10-slim

ENV APP_HOME /app
WORKDIR $APP_HOME

# Install system dependencies if any C-extensions need them
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and model training files
COPY requirements.txt requirements.txt
COPY bank_campaign_model_training.py bank_campaign_model_training.py
# COPY test_training.py test_training.py  # Ensure your test file is also copied for pytest!

# 1. Upgrade pip to the latest version
# 2. Install numpy 1.23.5 specifically (stable for scikit-learn 1.2.2)
# 3. Install the rest of the requirements
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir "numpy==1.23.5" && \
    pip install --no-cache-dir -r requirements.txt

# This is necessary if your cloudbuild.yaml runs 'python -m pytest' inside the container
CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 main:app
