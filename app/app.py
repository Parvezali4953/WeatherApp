from flask import Flask, request, render_template
import requests
from dotenv import load_dotenv
import os
import logging
from logging.handlers import RotatingFileHandler

load_dotenv()

app = Flask(__name__, template_folder='templates', static_folder='static')
handler = RotatingFileHandler('logs/app.log', maxBytes=2000, backupCount=3)
logging.basicConfig(level=logging.INFO, handlers=[handler])
logger = logging.getLogger(__name__)

API_KEY = os.getenv("API_KEY")
if not API_KEY:
    raise ValueError("API_KEY environment variable is not set")

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/weather', methods=['POST'])
def weather():
    city = request.form['city']
    if not city.strip():
        return render_template("result.html", weather=None, error="Please enter a city name.")
    url = f"http://api.openweathermap.org/data/2.5/weather?q={city}&appid={API_KEY}&units=metric"
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
            logger.info(f"Successfully fetched weather for {city}")
            return render_template("result.html", weather=weather_data)
        return render_template("result.html", weather=None, error="City not found.")
    except Exception as e:
        logger.error(f"Error fetching weather for {city}: {str(e)}")
        return render_template("result.html", weather=None, error=f"Error fetching data: {str(e)}")

if __name__ == '__main__':
    app.run(port=5000)