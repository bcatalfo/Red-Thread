Make sure to run from the functions directory (idk why)

To update the matching algorithm
gcloud functions deploy match_users \
        --runtime python39 \
        --trigger-topic matchmaking-topic \
        --entry-point match_users \
        --project red-thread-422420 \
        --memory 512MB \
        --timeout 60s
This function has been scheduled to run every second by the following command
gcloud scheduler jobs create pubsub match-users-job \
        --schedule="* * * * *" \
        --topic=matchmaking-topic \
        --message-body="{}" \
        --time-zone="America/New_York" \
        --location="us-central1"
To update the notifications for new messages
gcloud functions deploy notify_new_message \
    --runtime python39 \
    --trigger-event providers/google.firebase.database/eventTypes/ref.write \
    --trigger-resource "projects/_/instances/red-thread-422420-default-rtdb/refs/chats/{chatId}/messages/{messageId}" \
    --entry-point notify_new_message \
    --project red-thread-422420 \
    --memory 256MB \
    --timeout 60s
