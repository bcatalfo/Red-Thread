import firebase_admin
from firebase_admin import credentials, db, messaging
from geopy.distance import great_circle
import datetime
import re
import json

cred = credentials.Certificate('red-thread-422420-firebase-adminsdk-ndqik-31d32cdc87.json')
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://red-thread-422420-default-rtdb.firebaseio.com/'
})

def calculate_age(birthday):
    birth_date = datetime.datetime.strptime(birthday, "%m/%d/%Y")
    today = datetime.datetime.today()
    age = today.year - birth_date.year - ((today.month, today.day) < (birth_date.month, birth_date.day))
    return age

def send_push_notification(token, title, body):
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            token=token
        )
        response = messaging.send(message)
        print(f'Successfully sent message: {response}')
    except Exception as e:
        print(f'Failed to send message: {e}')

def match_users_and_create_chat(user1, user2):
    distance = calculate_geographical_distance(user1['location'], user2['location'])
    chat_ref = db.reference('chats').push({
        'users': {user1['id']: True, user2['id']: True},
        'match_info': {
            'distance': distance,
            'user1_id': user1['id'],
            'user2_id': user2['id'],
            'user1_name': user1['displayName'],
            'user2_name': user2['displayName'],
            'user1_age': user1['age'],
            'user2_age': user2['age']
        },
        'timestamp': datetime.datetime.now().isoformat()
    })
    chat_id = chat_ref.key
    users_ref = db.reference('users')
    users_ref.child(user1['id']).child('chat').set(chat_id)
    users_ref.child(user2['id']).child('chat').set(chat_id)
    print(f"Match created: {user1['id']} and {user2['id']} in chat {chat_id}")

    # Send push notifications
    if 'fcmToken' in user1:
        send_push_notification(user1['fcmToken'], "You've got a new match!", f"Say hi to {user2['displayName']}!")
    if 'fcmToken' in user2:
        send_push_notification(user2['fcmToken'], "You've got a new match!", f"Say hi to {user1['displayName']}!")

def find_best_matches(users_data):
    best_matches = []
    num_of_users = len(users_data)
    matched_user_ids = set()

    for i in range(num_of_users):
        if users_data[i]['id'] in matched_user_ids:
            continue

        best_match = None
        best_match_score = 0

        print(f"Evaluating user {i+1}/{num_of_users}: {users_data[i]['displayName']}")

        for j in range(num_of_users):
            if i == j or users_data[j]['id'] in matched_user_ids:
                continue

            user1 = users_data[i]
            user2 = users_data[j]

            print(f"  Comparing with user {j+1}/{num_of_users}: {users_data[j]['displayName']}")

            # Check gender preference
            if user2['gender'] not in user1['preferences']:
                print(f"    Gender preference mismatch: {user2['gender']} not in {user1['preferences']}")
                continue
            if user1['gender'] not in user2['preferences']:
                print(f"    Gender preference mismatch: {user1['gender']} not in {user2['preferences']}")
                continue

            # Check age range preference
            if not (user1['ageRange']['start'] <= user2['age'] <= user1['ageRange']['end']):
                print(f"    Age range mismatch for user1: {user2['age']} not in {user1['ageRange']}")
                continue
            if not (user2['ageRange']['start'] <= user1['age'] <= user2['ageRange']['end']):
                print(f"    Age range mismatch for user2: {user1['age']} not in {user2['ageRange']}")
                continue

            # Check distance preference
            distance = calculate_geographical_distance(user1['location'], user2['location'])
            if distance > user1['maxDistance']:
                print(f"    Distance mismatch for user1: {distance} miles > {user1['maxDistance']} miles")
                continue
            if distance > user2['maxDistance']:
                print(f"    Distance mismatch for user2: {distance} miles > {user2['maxDistance']} miles")
                continue

            # Check contacts for both users
            if is_in_contacts(user1, user2):
                print(f"    Contact mismatch: users are in each other's contacts")
                continue

            # Calculate match score (excluding distance since it's already checked)
            match_score = calculate_match_score(user1, user2)
            print(f"    Match score: {match_score}")

            if match_score > best_match_score:
                best_match = user2
                best_match_score = match_score

        if best_match:
            best_matches.append((users_data[i], best_match))
            matched_user_ids.add(users_data[i]['id'])
            matched_user_ids.add(best_match['id'])
            print(f"  Best match found for user {users_data[i]['displayName']}: {best_match['displayName']} with score {best_match_score}")

    return best_matches

def normalize_phone_number(phone_number):
    """Normalize phone numbers to a comparable format."""
    return re.sub(r'\D', '', phone_number)

def is_in_contacts(user1, user2):
    user2_phone = normalize_phone_number(user2['phoneNumber'])
    user1_phone = normalize_phone_number(user1['phoneNumber'])

    # Check if user2's phone number is in user1's contacts
    if 'contacts' in user1:
        for contact in user1['contacts']:
            if 'phoneNumbers' in contact:
                for phone_number in contact['phoneNumbers']:
                    if normalize_phone_number(phone_number) == user2_phone:
                        return True

    # Check if user1's phone number is in user2's contacts
    if 'contacts' in user2:
        for contact in user2['contacts']:
            if 'phoneNumbers' in contact:
                for phone_number in contact['phoneNumbers']:
                    if normalize_phone_number(phone_number) == user1_phone:
                        return True

    return False

def calculate_match_score(user1, user2):
    age_factor = max(0, 1 - abs(user1['age'] - user2['age']) / 10)
    bmi_factor = bmi_compatibility(user1.get('bmi', 22), user2.get('bmi', 22))
    return age_factor * bmi_factor

def calculate_geographical_distance(location1, location2):
    distance = great_circle((location1['latitude'], location1['longitude']), (location2['latitude'], location2['longitude'])).miles
    print(f"    Calculated geographical distance: {distance} miles")
    return distance

def bmi_compatibility(bmi1, bmi2):
    class1 = classify_bmi(bmi1)
    class2 = classify_bmi(bmi2)
    if class1 == class2:
        return 1.0
    elif (class1 in ['underweight', 'normal'] and class2 in ['underweight', 'normal']) or \
         (class1 in ['overweight', 'obese'] and class2 in ['overweight', 'obese']):
        return 0.5
    else:
        return 0.0

def classify_bmi(bmi):
    if bmi < 18.5:
        return 'underweight'
    elif 18.5 <= bmi < 25.0:
        return 'normal'
    elif 25.0 <= bmi < 30.0:
        return 'overweight'
    else:
        return 'obese'

def parse_preferences(preferences):
    # Remove the Gender. prefix and convert to a set of strings
    preferences = preferences.replace("Gender.", "").strip("{}")
    return set(preferences.split(", "))

def parse_gender(gender):
    # Remove the Gender. prefix
    return gender.replace("Gender.", "")

def match_users(event, context):
    print("Starting matchmaking process...")
    queue_ref = db.reference('queue')
    users_ref = db.reference('users')
    queue = queue_ref.get()
    if queue is None or len(queue) < 2:
        print("Not enough users in queue")
        return 'Not enough users in queue', 200

    users_data = []
    for user_id in queue.keys():
        user_data = users_ref.child(user_id).get()
        if user_data:
            user_data['id'] = user_id
            user_data['age'] = calculate_age(user_data['birthday'])
            user_data['preferences'] = parse_preferences(user_data['lookingFor'])
            user_data['gender'] = parse_gender(user_data['gender'])
            users_data.append(user_data)
            print(f"Loaded user: {user_data['displayName']}")

    best_matches = find_best_matches(users_data)

    matched_user_ids = set()
    for match in best_matches:
        match_users_and_create_chat(match[0], match[1])
        matched_user_ids.add(match[0]['id'])
        matched_user_ids.add(match[1]['id'])

    # Remove matched users from the queue
    for user_id in matched_user_ids:
        queue_ref.child(user_id).delete()
        print(f"Removed user {user_id} from queue")

    print("Matchmaking process complete")
    return 'Matchmaking complete', 200

def notify_new_message(event, context):
    print("New message detected...")
    
    # Print the full event and context to debug their structures
    print(f"Data: {event}")
    print(f"Context: {context}")
    
    # Extract the delta (new data after the change)
    message_data = event["delta"]
    print(f"Delta: {json.dumps(message_data)}")

    chat_id = context.resource.split('/')[6]
    sender_id = message_data["author"]
    text = message_data["message"]
    
    print(f"Chat ID: {chat_id}")
    print(f"Sender ID: {sender_id}")
    print(f"Message: {text}")

    chat_ref = db.reference(f'chats/{chat_id}')
    chat_data = chat_ref.get()

    print(f"Chat data: {chat_data}")

    sender_ref = db.reference(f'users/{sender_id}')
    sender_data = sender_ref.get()
    sender_name = sender_data['displayName']

    for user_id in chat_data['users']:
        if user_id != sender_id:
            user_ref = db.reference(f'users/{user_id}')
            user_data = user_ref.get()
            user_fcm_token = user_data.get('fcmToken')
            if user_fcm_token:
                print(f"Sending notification to user {user_id}")
                send_push_notification(user_fcm_token, f"New message from {sender_name}", text)
            else:
                print(f"No FCM token found for user {user_id}")