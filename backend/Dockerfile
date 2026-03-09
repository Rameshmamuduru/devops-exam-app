FROM python:3.11-slim

WORKDIR /app

# Copy backend code
COPY . .

# Copy frontend templates
COPY ../frontend/ templates/

# Install dependencies
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0
EXPOSE 5000

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app", "--workers", "3"]
