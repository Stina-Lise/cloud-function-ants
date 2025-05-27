import firebase_admin
from firebase_admin import credentials, firestore
import random

def apply_discount(event, context):
    # Initialize Firebase Admin SDK
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {"projectId": "ingka-native-ikealabs-dev"})

    # Initialize Firestore
    db = firestore.client()

    # Reference to the Firestore collection containing products
    products_ref = db.collection("ants")

    # Query all products
    products = products_ref.stream()

    all_products = list(products_ref.stream())

    # Define the number of products to discount (e.g., 30%)
    discount_percent = 30
    min_products_to_discount = 1
    max_products_to_discount = len(all_products) // 2  # Half of the total products

    # Generate a random number of products to discount within the specified range
    num_products_to_discount = random.randint(min_products_to_discount, max_products_to_discount)
    # Randomly select a subset of products to discount
    products_to_discount = random.sample(all_products, num_products_to_discount)

    # Apply a random discount of 30% to each selected product
    for product in products_to_discount:
        product_data = product.to_dict()
        original_price = product_data.get("currentPrice", 0)

        # Calculate the discounted price
        discounted_price = original_price * (1 - discount_percent / 100)

        # Update the Firestore document with the discounted price
        products_ref.document(product.id).update({"discountedPrice": discounted_price})

        print(f"Applied {discount_percent}% discount to product {product.id}: New price: {discounted_price:.2f}")

# To test this function locally, you can call it like this:
apply_discount(None, None)

# function calculate median of two sorted arrays
def median(arr1, arr2):
    # TODO: Implement the median function
    pass
       


                

