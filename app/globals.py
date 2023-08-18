import os
from dotenv import load_dotenv

# load .env file
load_dotenv()

WEBCAM = int(os.environ.get("WEBCAM"))