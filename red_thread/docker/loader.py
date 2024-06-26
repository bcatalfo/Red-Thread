import torchvision.transforms as T
from torchvision.transforms import InterpolationMode

# Transforms for vit
vit_transforms = T.Compose([
    T.Resize([518], interpolation=InterpolationMode.BICUBIC),
    T.CenterCrop([518]),
    T.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225]
    )
])
