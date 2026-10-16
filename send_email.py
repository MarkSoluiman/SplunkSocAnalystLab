from email.message import EmailMessage
import smtplib
import os
from dotenv import load_dotenv
import sys
from string import Template


load_dotenv()

APP_PASSWORD = os.getenv("PASSWORD")

user_info = [
    {
        "name": sys.argv[1],
        "email": sys.argv[2],
        "subject": "You got a new alert",
        "body": "Please investigate this alert"
    }
]


with open("email_template.html", "r", encoding="utf-8") as file:
    template = Template(file.read())


with smtplib.SMTP_SSL("smtp.gmail.com", 465) as email_server:

    email_server.login(
        "marksoluiman@gmail.com",
        APP_PASSWORD
    )

    for user in user_info:

        html = template.substitute(
            name=user["name"]
        )

        message = EmailMessage()

        message["Subject"] = user["subject"]
        message["From"] = "SOC Analyst Team Leader <marksoluiman@gmail.com>"
        message["To"] = user["email"]

        message.set_content(
f"""
Hi {user['name']},

You got a new alert. Please investigate this alert further and provide your findings to your AI agent.

Thank you.

SOC Analyst Team Leader
"""
        )

        message.add_alternative(
            html,
            subtype="html"
        )

        email_server.send_message(message)
        