from openai import OpenAI
import os

# Client automatically uses the OPENAI_API_KEY environment variable
# Alternatively, you can pass it explicitly: client = OpenAI(api_key="your-api-key")
API_KEY="ok"
BASE_URL="http://localhost:8000/v1"
MODEL_NAME ="google/gemma-3-27b-it"
client = OpenAI(api_key=API_KEY, base_url=BASE_URL)

# Send a request to the chat completions endpoint
response = client.chat.completions.create(
    model=MODEL_NAME,
    messages=[
        {"role": "user", "content": "Explain the difference between a completion and a chat completion."}
    ]
)

# Extract and print the model's content from the response
print(response.choices[0].message.content)
