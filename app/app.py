from flask import Flask, request, render_template
import os
import requests

app = Flask(__name__, template_folder='templates', static_folder='static')

API_URL = "http://api.openweathermap.org/data/2.5/weather"  # Current weather endpoint


@app.route('/')
def home():
    api_key = os.getenv('API_KEY')
    # Read the API key at request time for reliable testing and runtime config
    if not api_key:
        return render_template("error.html", error="API key is missing. Weather functionality is disabled.")
    return render_template('index.html')


@app.route('/health')
def health():
    return {"status": "healthy", "version": "1.0.0"}, 200


@app.route('/weather', methods=['POST'])
def weather():
    api_key = os.getenv('API_KEY')
    if not api_key:
        return render_template("error.html", error="API key is missing. Cannot fetch weather data.")

    city = (request.form.get('city') or "").strip()
    if not city:
        return render_template("result.html", weather=None, error="Please enter a city name.")

    try:
        r = requests.get(API_URL, params={"q": city, "appid": api_key, "units": "metric"}, timeout=5)
        data = r.json()
        if str(data.get("cod")) == "200":
            weather_data = {
                "city": data.get("name", city),
                "temperature": data["main"]["temp"],
                "description": data["weather"][0]["description"],
                "humidity": data["main"]["humidity"],
                "wind_speed": data["wind"]["speed"],
            }
            return render_template("result.html", weather=weather_data)
        # Common errors: 401 (key), 404 (city), etc.
        return render_template("result.html", weather=None, error=data.get("message", "Unable to fetch weather data."))
    except Exception:
        return render_template("result.html", weather=None, error="Error fetching data.")

