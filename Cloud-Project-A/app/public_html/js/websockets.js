// websockets.js

// Define a map of colors for sender IDs
const senderColors = {};

// Predefined colors suitable for dark backgrounds with white text
const predefinedColors = [
    '#FF5733', '#FFC300', '#00AF91', '#00ADB5', '#FFD700', '#FF8C00', '#9932CC', '#FF4500',
    '#48D1CC', '#FF1493', '#1E90FF', '#FF69B4', '#DC143C', '#00FF7F', '#6B8E23', '#B22222'
];

// Function to generate a color based on the sender's ID
function getColor(senderId) {
    // If the sender ID is not already mapped to a color, assign a color
    if (!senderColors[senderId]) {
        // Use the sender ID as an index to select a color from the predefined set
        const colorIndex = parseInt(senderId) % predefinedColors.length;
        senderColors[senderId] = predefinedColors[colorIndex];
    }
    return senderColors[senderId];
}


// Event listener for form submission
const messageForm = document.getElementById('messageForm');
const messageInput = document.getElementById('messageInput');
const statusDiv = document.getElementById('statusDiv');
const notificationDiv = document.getElementById('notificationDiv');

messageForm.addEventListener('submit', function(event) {
    event.preventDefault();
    const message = messageInput.value;
    sendMessage(message);
    messageInput.value = '';
});

// Create a WebSocket connection
const socket = new WebSocket(ws_uri);

socket.onopen = function(event) {
    console.log('WebSocket connection established');
    statusDiv.classList.remove('alert-warning');
    statusDiv.classList.add('alert-success');
    statusDiv.innerHTML = 'WebSocket connection established.' + statusDiv.querySelector('.btn-close').outerHTML;
};

socket.onmessage = function(event) {
    const notification = JSON.parse(event.data);
    const notificationMessage = document.createElement('div');
    
    // Create spans for message, timestamp, and sender ID
    const messageSpan = document.createElement('span');
    messageSpan.innerText = notification.message;
    const timestampSpan = document.createElement('span');
    timestampSpan.innerText = ` (on ${notification.timestamp})`;
    const senderIdSpan = document.createElement('span');
    senderIdSpan.innerText = ` (by Sender ID: ${notification.sender_id})`;
    
    // Apply classes for styling
    messageSpan.classList.add('message-text');
    timestampSpan.classList.add('timestamp');
    senderIdSpan.classList.add('sender-id');
    
    // Append spans to the notification message div
    notificationMessage.appendChild(messageSpan);
    notificationMessage.appendChild(timestampSpan);
    notificationMessage.appendChild(senderIdSpan);
    
    // Add classes for sender and recipient messages
    if (notification.sender_id === socket.id) {
        notificationMessage.classList.add('notification', 'sender-message');
    } else {
        notificationMessage.classList.add('notification', 'recipient-message');
    }
    
    // Set background color based on sender ID
    const color = getColor(notification.sender_id);
    notificationMessage.style.backgroundColor = color;
    
    // Append the notification message to the notification div
    notificationDiv.appendChild(notificationMessage);
};

socket.onclose = function(event) {
    console.log('WebSocket connection closed');
    statusDiv.classList.remove('alert-warning');
    statusDiv.classList.add('alert-danger');
    statusDiv.innerHTML = 'WebSocket connection closed. Please try again later.' + statusDiv.querySelector('.btn-close').outerHTML;
};

// Send a message to the server
function sendMessage(message) {
    if (socket.readyState === WebSocket.OPEN) {
        socket.send(JSON.stringify({ message: message }));
    } else {
        notificationDiv.innerHTML = 'WebSocket connection is not available.';
    }
}
