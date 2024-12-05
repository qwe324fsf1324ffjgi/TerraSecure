# Step 1: Use the official Python image as the base
FROM python:3.9-slim

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy the requirements.txt into the container
COPY requirements.txt .

# Step 4: Install dependencies listed in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Step 5: Copy the application code into the container
COPY . .

# Step 6: Expose port 5000 (Flask default port) to the outside world
EXPOSE 5000

# Step 7: Set environment variable to disable Python's output buffering (optional)
ENV PYTHONUNBUFFERED=1

# Step 8: Run the application using Gunicorn (a production-grade server for Flask)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
