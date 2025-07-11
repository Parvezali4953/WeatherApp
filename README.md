# 🌦️ Atmosphere - Weather Forecast Web App

Atmosphere is a simple weather forecast web application built using **Flask** and the **OpenWeatherMap API**. 
Users can enter a city name to get real-time weather data like temperature, humidity, description, and wind speed.

## 🚀 Features

- Search weather by city name
- Fetch data using OpenWeatherMap API
- Displays temperature, weather description, humidity, and wind speed
- Error handling for invalid city names
- Simple and clean UI with HTML + CSS

## 📁 Project Structure

```

Atmosphere/
│
├── static/
│   └── style.css              # CSS file for styling
│
├── templates/
│   ├── index.html             # Form to enter city
│   └── result.html            # Displays weather result
│
├── app.py                     # Main Flask application
├── .env                       # Stores API key (not shared publicly)
├── requirements.txt           # List of Python dependencies
└── README.md                  # This file

```

## 🧪 Tech Stack

- Python
- Flask
- HTML/CSS
- OpenWeatherMap API

## 🔐 Environment Variables

Create a `.env` file in the root directory and add your OpenWeatherMap API key:

```

API\_KEY=your\_api\_key\_here

````

> You can get your free API key from [https://openweathermap.org/api](https://openweathermap.org/api)

## 📦 Installation & Setup

1. **Clone the repo**

```bash
 https://github.com/Parvezali4953/WeatherApp.git
cd WeatherApp
````

2. **Create and activate virtual environment**

```bash
python -m venv venv
# On Windows
venv\Scripts\activate
# On macOS/Linux
source venv/bin/activate
```

3. **Install dependencies**

```bash
pip install -r requirements.txt
```

4. **Create `.env` file and add API key**

```
API_KEY=your_api_key_here
```

5. **Run the app**

```bash
python app.py
```

Then go to [http://localhost:5000](http://localhost:5000)

## 📸 Screenshots

### Homepage

![image](https://github.com/user-attachments/assets/75140d0e-4d7f-480a-9f4e-e57016e40f34)


### Weather Result

![image](https://github.com/user-attachments/assets/e6f852cd-faad-495b-8041-057b44d4425b)

## 🧠 How it works

* `index.html`: User enters the city and submits the form.
* `/weather` route: Flask fetches weather using the OpenWeatherMap API.
* `result.html`: Displays weather details or error message.

## ✨ Future Improvements

* Add support for country selection
* Show forecast for multiple days
* Add geolocation support
* Improve UI/UX

 