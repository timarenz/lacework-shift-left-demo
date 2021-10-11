from flask import Flask, render_template, url_for
import urllib.parse
import random
import platform

app = Flask(__name__)

event_text = "Welcome to the Hops & DevOps of the 22nd of Sept in Berlin."
tweet_text = "Hello from Hops&DevOps. Just enjoyed a fantastic presentation from @automatecloud about Shift Left Security with #laceworks #hopsndevops"


@app.route('/')
def index():
    images = [
        url_for('static', filename='beachops-1.png'),
        url_for('static', filename='beachops-2.png'),
        url_for('static', filename='norules-1.png'),
        url_for('static', filename='norules-2.png'),
    ]
    url = random.choice(images)
    hostname = platform.node()
    return render_template('index.html', url=url, hostname=hostname, event_text=event_text, tweet_text=tweet_text, tweet_text_url=urllib.parse.quote(tweet_text))


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
    return render_template('lacework-scan.html')


if __name__ == "__main__":
    app.run(host="0.0.0.0")
