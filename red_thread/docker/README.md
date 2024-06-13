# Face2BMI Project

This project is a web service that uses a machine learning model to predict Body Mass Index (BMI) from facial images. The model is based on the Vision Transformer (ViT) architecture. This project integrates with the Red Thread app to help verify users and improve matchmaking by running the BMI prediction algorithm on verified user images.

## Table of Contents
1. [Setup and Installation](#setup-and-installation)
2. [Running the Application Locally](#running-the-application-locally)
3. [Building the Docker Container](#building-the-docker-container)
4. [Testing the Docker Container Locally](#testing-the-docker-container-locally)
5. [Deploying to Google Cloud Run](#deploying-to-google-cloud-run)
6. [Testing the Deployed Application](#testing-the-deployed-application)
7. [Integration with Red Thread](#integration-with-red-thread)
8. [Additional Information](#additional-information)

## Setup and Installation

### Prerequisites
- Docker
- Google Cloud SDK
- Python 3.8+

### Clone the Repository
```sh
git clone https://github.com/yourusername/your-repo.git
cd your-repo/docker
```

### Model Weights
Create a directory for the model weights:
```sh
mkdir -p weights
```
Place your model weights (`aug_epoch_7.pt`) in the `weights` directory.

## Running the Application Locally

### Install Dependencies
```sh
pip install -r requirements.txt
```

### Run the Application
```sh
uvicorn app:app --host 0.0.0.0 --port 8000
```

## Building the Docker Container

### Build the Docker Image
```sh
docker build -t face2bmi .
```

### Tag the Docker Image
```sh
docker tag face2bmi gcr.io/red-thread-422420/face2bmi
```

## Testing the Docker Container Locally

### Run the Docker Container
```sh
docker run -e PORT=8080 -p 8080:8000 --memory="4g" --cpus="2" gcr.io/red-thread-422420/face2bmi
```

### Test with Postman
1. Open Postman and create a new POST request.
2. Set the URL to `http://localhost:8080/predict`.
3. Set the request type to `multipart/form-data`.
4. Add a form-data key named `file` and upload a JPEG image.
5. Send the request and check the response for the predicted BMI.

## Deploying to Google Cloud Run

### Configure Google Cloud SDK
Authenticate with your Google Cloud account:
```sh
gcloud auth login
```
Set your project:
```sh
gcloud config set project red-thread-422420
```

### Push the Docker Image to Google Container Registry
```sh
docker push gcr.io/red-thread-422420/face2bmi
```

### Deploy to Google Cloud Run
```sh
gcloud run deploy face2bmi \
    --image gcr.io/red-thread-422420/face2bmi \
    --platform managed \
    --region us-east1 \
    --allow-unauthenticated \
    --memory 16Gi \
    --cpu 2
```

## Testing the Deployed Application

### Test with Postman
1. Open Postman and create a new POST request.
2. Set the URL to `http://<your-cloud-run-url>/predict`.
3. Set the request type to `multipart/form-data`.
4. Add a form-data key named `file` and upload a JPEG image.
5. Send the request and check the response for the predicted BMI.

## Integration with Red Thread

This project integrates with the Red Thread app to help verify users and improve matchmaking. When users get verified, the Face2BMI algorithm runs on their images to predict their BMI. This information helps enhance the matchmaking process by providing additional data points.

## Additional Information

For more details on the Face2BMI algorithm and its implementation, visit the [Face2BMI GitHub repository](https://github.com/liujie-zheng/face-to-bmi-vit/).
```