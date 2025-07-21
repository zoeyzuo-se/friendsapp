FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    gettext \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Make startup script executable
RUN chmod +x startup.sh

# Collect static files
RUN mkdir -p staticfiles
RUN mkdir -p media/profile_pictures

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PORT=8000
ENV WEBSITES_PORT=8000
ENV WEBSITE_SITE_NAME=friendsapp

# Expose the port
EXPOSE 8000

# Run startup script
CMD ["./startup.sh"]
