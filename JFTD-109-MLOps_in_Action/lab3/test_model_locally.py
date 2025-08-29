import pandas as pd
from frogml.sdk.model.tools import run_local
from pandas import DataFrame
import json
import os

from main import load_model

if __name__ == '__main__':
    # Create a new instance of the model
    m = load_model()
    
    # Create an input vector and convert it to JSON
    input_vector = pd.DataFrame(
        [{
            "input": "እግዚአብሔር ፍቅር ነው"
        }]
    ).to_json()
    print("Test Prompt:"+ input_vector)

    # Run local inference using the model
    prediction = run_local(m, input_vector)
    print("\nPrediction: ", prediction)