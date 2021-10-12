import urllib
import platform
import random
import requests
import os
from flask import Flask, render_template, url_for, request
from flask import jsonify

app = Flask(__name__)

event_text = "Welcome to the Hops & DevOps of the 22nd of Sept in Berlin."
tweet_text = "Hello from Hops&DevOps. Just enjoyed a fantastic presentation from @automatecloud about Shift Left Security with #laceworks #devsecops"
random_cocktail = requests.get(
    'https://www.thecocktaildb.com/api/json/v1/1/random.php')
version = open(os.path.dirname(__file__) + '/static/version.txt', 'r').read()
lacework_report = urllib.request.urlretrieve('https://github.com/timarenz/lacework-shift-left-demo/releases/download/v0.1.10/lacework.html', os.path.dirname(__file__) +
                                             '/templates/lacework.html')


@ app.route('/')
def index():
    images = [
        url_for('static', filename='beachops-1.png'),
        url_for('static', filename='beachops-2.png'),
        url_for('static', filename='norules-1.png'),
        url_for('static', filename='norules-2.png'),
    ]
    url = random.choice(images)
    hostname = platform.node()
    return render_template('index.html', url=url, hostname=hostname, event_text=event_text, tweet_text=tweet_text, tweet_text_url=urllib.parse.quote(tweet_text), version=version, ip=request.remote_addr)


@app.route('/andreas')
def andreas():
    images = [
        url_for('static', filename='beachops-1.png'),
        url_for('static', filename='beachops-2.png'),
        url_for('static', filename='norules-1.png'),
        url_for('static', filename='norules-2.png'),
    ]
    url = random.choice(images)
    hostname = platform.node()
    return render_template('andreas.html', url=url, hostname=hostname)


@app.route('/lacework')
def lacework():
    return render_template('lacework.html')


@app.route("/ip")
def ip():
    return jsonify({'ip': request.remote_addr}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0")
