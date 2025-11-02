from flask import Flask, request, render_template
import os
import requests

# Initialize the Flask app, specifying template and static file locations
app = Flask(__name__, template_folder='templates', static_folder='static')

# Define the base URL for the OpenWeatherMap API
API_URL = "http://api.openweathermap.org/data/2.5/weather"

@app.route('/')
def home():
    """Renders the main page where users can input a city."""
    # Check for the API key at request time to ensure the app can function.
    api_key = os.getenv('API_KEY')
    if not api_key:
        return render_template("error.html", error="API key is missing. Weather functionality is disabled.")
    return render_template('index.html')

@app.route('/health')
def health_check():
    """
    Provides a simple health check endpoint.
    Load balancers (like AWS ALB) use this to verify the container is running and healthy.
    """
    return {"status": "healthy"}, 200

@app.route('/weather', methods=['POST'])
def get_weather():
    """
    Fetches and displays weather data for a given city from the OpenWeatherMap API.
    """
    api_key = os.getenv('API_KEY')
    if not api_key:
        # Fail fast if the API key isn't configured at runtime
        return render_template("error.html", error="API key is missing. Cannot fetch weather data.")

    # Get the city from the form, stripping any extra whitespace
    city = (request.form.get('city') or "").strip()
    if not city:
        return render_template("result.html", weather=None, error="Please enter a city name.")

    # API request parameters
    params = {
        "q": city,
        "appid": api_key,
        "units": "metric"  # Request temperature in Celsius
    }

    try:
        # Make the API call with a timeout to prevent hanging requests
        response = requests.get(API_URL, params=params, timeout=5)
        response.raise_for_status()  # Raise an exception for bad status codes (4xx or 5xx)
        
        data = response.json()

        # Format the data for display
        weather_data = {
            "city": data.get("name", city),
            "temperature": data["main"]["temp"],
            "description": data["weather"][0]["description"],
            "humidity": data["main"]["humidity"],
            "wind_speed": data["wind"]["speed"],
        }
        return render_template("result.html", weather=weather_data)

    except requests.exceptions.HTTPError as http_err:
        # Handle specific HTTP errors from the weather API (e.g., 404 Not Found, 401 Unauthorized)
        error_message = f"City not found or invalid API key. (Error: {http_err.response.status_code})"
        return render_template("result.html", weather=None, error=error_message)
    except Exception as e:
        # Catch all other exceptions (e.g., network issues, timeouts)
        return render_template("result.html", weather=None, error=f"An error occurred: {e}")

if __name__ == '__main__':
    # The app runs on 0.0.0.0 to be accessible from outside the container.
    # The port 5000 matches the EXPOSE instruction in the Dockerfile.
    app.run(host='0.0.0.0', port=5000)
