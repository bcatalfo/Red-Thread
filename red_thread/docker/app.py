import os
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import uvicorn
from models import get_model
from loader import vit_transforms
from PIL import Image
from torchvision.transforms import ToTensor
import torch

app = FastAPI()

# Load the model
device = "cuda" if torch.cuda.is_available() else "mps" if torch.backends.mps.is_available() else "cpu"
model = get_model()
model.load_state_dict(torch.load('./weights/aug_epoch_7.pt', map_location=device))
model.to(device)
model.eval()

@app.post("/predict")
async def predict(file: UploadFile = File(...)):
    try:
        # Read image
        image = Image.open(file.file)
        if image.mode != 'RGB':
            image = image.convert('RGB')
        image = ToTensor()(image)
        image = vit_transforms(image).unsqueeze(0).to(device)
        
        # Predict BMI
        with torch.no_grad():
            prediction = model(image)
            bmi = prediction.item()

        return JSONResponse(content={"prediction": bmi})
    except Exception as e:
        return JSONResponse(content={"error": str(e)}, status_code=400)

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run(app, host="0.0.0.0", port=port)
