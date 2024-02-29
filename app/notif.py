from firebase_admin import messaging
import re
from datetime import datetime


def convertToValidTopic(input):
    return re.sub(r"[^a-zA-Z0-9-_.~%]", "_", re.sub(r"^_+|_+$", "", input))


def send_notif(team, m):
    topic = convertToValidTopic(team)
    message = messaging.Message(
        notification=messaging.Notification(
            title=f"{team} are playing Pog",
            body=f"BatChest {m.get('team1')} vs {m.get('team2')} in less than an hour",
        ),
        topic=topic,
    )
    response = messaging.send(message)


def notify(matches, sent_notif):
    for m in matches:
        minutes_to_match = (
            datetime.fromtimestamp(int(m["datetime"])) - datetime.now()
        ).total_seconds() / 60
        key = f"{m['team1_name']}_{m['team2_name']}_{m['datetime']}"
        if 0 < minutes_to_match < 60 and sent_notif.get(key) is None:
            send_notif(m["team1_name"], m)
            send_notif(m["team2_name"], m)
            sent_notif[key] = True
    return sent_notif
