import os
import firebase_admin
from firebase_admin import credentials, firestore
import json

def upload_products_to_firestore(key_file_path, json_file_path):
    # Initialize Firebase Admin SDK with the service account key
    cred = credentials.Certificate(key_file_path)
    firebase_admin.initialize_app(cred)

    # Initialize Firestore
    db = firestore.client()

    # Read product data from the JSON file
    with open(json_file_path, "r") as json_file:
        products_data = json.load(json_file)

    # Reference to the Firestore collection where you want to add products
    firebase_collection = db.collection("ants")

    # Add each product to Firestore
    for product in products_data:
        firebase_collection.add(product)
        print(f"Added product: {product['name']}")

    print("Data import complete")

if __name__ == "__main__":
    # Specify the paths to your service account key and JSON data file
    key_path = os.path.expanduser("~/Downloads/ingka-native-ikealabs-dev-cec4597d9e4d.json")
    json_data_path = "mockdata.json"

    # Call the function to upload products to Firestore
    upload_products_to_firestore(key_path, json_data_path)
