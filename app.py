from flask import Flask, request, render_template
import requests
import os

app = Flask(__name__, template_folder='templates', static_folder='static')

API_KEY = os.getenv('API_KEY')
if not API_KEY:
    raise ValueError("API_KEY environment variable is required")

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/health')
def health():
    return {"status": "healthy", "version": "1.0.0"}, 200

@app.route('/weather', methods=['POST'])
def weather():
    city = request.form['city']
    if not city.strip():
        return render_template(
            "result.html",
            weather=None,
            error="Please enter a city name."
        )

    url = (
        f"http://api.openweathermap.org/data/2.5/weather?q={city}"
        f"&appid={API_KEY}&units=metric"
    )

    try:
        response = requests.get(url)
        data = response.json()
        if data["cod"] != "404":
            weather_data = {
                "city": city,
                "temperature": data["main"]["temp"],
                "description": data["weather"][0]["description"],
                "humidity": data["main"]["humidity"],
                "wind_speed": data["wind"]["speed"],
            }
            return render_template("result.html", weather=weather_data)
        return render_template(
            "result.html",
            weather=None,
            error="City not found."
        )
    except Exception:
        return render_template(
            "result.html",
            weather=None,
            error="Error fetching data."
        )