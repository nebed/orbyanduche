import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
from flask_httpauth import HTTPBasicAuth
from werkzeug.security import generate_password_hash, check_password_hash
from dotenv import load_dotenv
from google.cloud import storage
from datetime import timedelta
from twilio.rest import Client
from json import dumps
import random, string, qrcode, requests
from fpdf import FPDF
from PIL import Image

# Load environment variables from .env file
load_dotenv()

# Instantiate the app
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# CORS(app)
if os.environ.get('FLASK_ENV') == 'development':
    # Allow all origins in development
    CORS(app, resources={r"/*": {"origins": "*"}})
else:
    # Restrict to specific domain in production
    CORS(app, resources={r"/*": {"origins": "https://orbyanduche.nebed.io"}})

# Initialize the database
db = SQLAlchemy(app)
auth = HTTPBasicAuth()

# Load password from environment variable
admin_password = os.getenv('VITE_API_PASSWORD')
if not admin_password:
    raise ValueError("No VITE_API_PASSWORD set for Flask application")

username = os.getenv('VITE_API_USERNAME')
if not username:
    raise ValueError("No VITE_API_USERNAME set for Flask application")

mailgun_api_key = os.getenv('MAILGUN_API_KEY')
if not mailgun_api_key:
    raise ValueError("No MAILGUN_API_KEY set for Flask application")

twilio_account_sid = os.getenv('TWILIO_ACCOUNT_SID')
if not twilio_account_sid:
    raise ValueError("No TWILIO_ACCOUNT_SID set for Flask application")

twilio_auth_token = os.getenv('TWILIO_AUTH_TOKEN')
if not twilio_auth_token:
    raise ValueError("No TWILIO_AUTH_TOKEN set for Flask application")

twilio_sender_number = os.getenv('TWILIO_SENDER_NUMBER')

twilio_nomedia_content_sid = os.getenv('TWILIO_NOMEDIA_CONTENT_SID')
twilio_media_content_sid = os.getenv('TWILIO_MEDIA_CONTENT_SID')
twilio_messaging_service_sid = os.getenv('TWILIO_MESSAGING_SERVICE_SID')

gcs_bucket_name = "orbyanducheprivate"

os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = "personal-projects-384213-dd7304a43459.json"

# In-memory user storage for authentication
users = {
    username: generate_password_hash(admin_password)
}

calendar_link = "https://calendar.app.google/GBiUC4xTUHmY8pqt5"
bucket_name = 'orbyanducheprivate'

@auth.verify_password
def verify_password(username, password):
    if username in users and check_password_hash(users.get(username), password):
        return username

# Define the RSVP model
class RSVP(db.Model):
    __tablename__ = 'guests'  # Explicit table name
    id = db.Column(db.Integer, primary_key=True)
    first_name = db.Column(db.String(50), nullable=False)
    last_name = db.Column(db.String(50), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    phone_number = db.Column(db.String(11), nullable=False)
    additional_guests = db.Column(db.Integer, nullable=False)
    approved = db.Column(db.Boolean, default=False, nullable=False)

@app.route('/api/ping', methods=['GET'])
def ping_pong():
    return jsonify('pong!')

@app.route('/api/rsvps', methods=['GET'])
@auth.login_required
def get_rsvps():
    rsvps = RSVP.query.all()
    return jsonify([{
        'id': rsvp.id,
        'firstName': rsvp.first_name,
        'lastName': rsvp.last_name,
        'email': rsvp.email,
        'phoneNumber': rsvp.phone_number,
        'additionalGuests': rsvp.additional_guests,
        'approved': rsvp.approved
    } for rsvp in rsvps])

@app.route('/api/rsvp/<int:id>', methods=['DELETE'])
@auth.login_required
def delete_rsvp(id):
    rsvp = RSVP.query.get(id)
    if not rsvp:
        return jsonify({"error": "RSVP not found"}), 404

    db.session.delete(rsvp)
    db.session.commit()
    return jsonify({"message": "RSVP deleted successfully"})

@app.route('/api/rsvp/<int:id>/approve', methods=['PATCH'])
@auth.login_required
def approve_rsvp(id):
    rsvp = RSVP.query.get(id)
    if not rsvp:
        return jsonify({"error": "RSVP not found"}), 404
    if rsvp.approved:
        return jsonify({"message": "RSVP has been approved already"}), 409
    
    tickets = generate_qr_codes_from_rsvp(rsvp, 'logo.jpg')
    send_email_invitation(rsvp.first_name, rsvp.email, tickets)

    media_urls = upload_file_to_gcs(gcs_bucket_name, tickets)
    send_whatsapp_messages(rsvp.first_name, rsvp.phone_number, media_urls)

    rsvp.approved = True
    db.session.commit()
    return jsonify({"message": "RSVP approved successfully"})

@app.route('/api/rsvp', methods=['POST'])
@auth.login_required
def create_rsvp():
    data = request.json
    if not data:
        return jsonify({"error": "Invalid input, no data provided."}), 400

    # Extract and clean fields from request data
    first_name = data.get('firstName', '').strip()
    last_name = data.get('lastName', '').strip()
    email = data.get('email', '').strip().lower()
    phone_number = data.get('phoneNumber', '').strip()

    # Parse and validate additional_guests
    try:
        additional_guests = int(data.get('additionalGuests', 0))
        if additional_guests < 0:
            raise ValueError("Additional guests cannot be negative.")
        if additional_guests > 2:
            raise ValueError("Additional guests cannot be more than 2.")
    except ValueError as e:
        return jsonify({"error": str(e)}), 400

    # Validate fields
    if not all(isinstance(field, str) and field for field in [first_name, last_name, email, phone_number]):
        return jsonify({"message": "First name, last name, email, and phone number are required and must be strings."}), 400

    # Validate email format
    if '@' not in email:
        return jsonify({"message": "Invalid email format."}), 400

    # Validate phone number (should be exactly 11 digits)
    if not phone_number.lstrip('+').isdigit():
        return jsonify({"message": "Phone number must be digits."}), 400

    # Check if an RSVP with the same email and phone number already exists
    existing_rsvp = RSVP.query.filter_by(email=email, phone_number=phone_number).first()
    if existing_rsvp:
        return jsonify({"message": "you have RSVP'd already"}), 400

    # Create a new RSVP
    new_rsvp = RSVP(
        first_name=first_name,
        last_name=last_name,
        email=email,
        phone_number=phone_number,
        additional_guests=additional_guests,
        approved=False
    )
    db.session.add(new_rsvp)
    db.session.commit()

    return jsonify({"message": "you RSVP has been submitted"}), 200

def generate_qr_codes_from_rsvp(rsvp, logo_path=None, output_dir='qrcodes'):
    """
    Generates QR codes for a main guest and additional guests based on RSVP model instance.
    
    Args:
    - rsvp (RSVP): The RSVP model instance.
    - logo_path (str, optional): Path to a logo to include in the QR code.
    - output_dir (str): Directory to save the generated QR codes.
    
    Returns:
    - List of paths to the generated QR code images.
    """
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    pdf_paths = []
    
    first_name = rsvp.first_name
    last_name = rsvp.last_name
    email = rsvp.email
    additional_guests = rsvp.additional_guests

    # Create QR codes for main guest and additional guests
    total_guests = additional_guests + 1
    for i in range(1, total_guests + 1):
        guest_data = f"{first_name} {last_name} - {i}\nEmail: {email}"
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=10,
            border=4,
        )
        qr.add_data(guest_data)
        qr.make(fit=True)

        img = qr.make_image(fill='black', back_color='white')
        img = img.convert("RGB")

        if logo_path and os.path.exists(logo_path):
            logo = Image.open(logo_path)
            logo = logo.resize((50, 50))
            pos = ((img.size[0] - logo.size[0]) // 2, (img.size[1] - logo.size[1]) // 2)
            img.paste(logo, pos)

        random_text = ''.join(random.choices(string.digits, k=4))
        
        file_name = f"{first_name}_{last_name}_guest_{i}_{random_text}.png"
        file_path = os.path.join(output_dir, file_name)
        img.save(file_path)

       # Create a PDF with the QR code
        pdf_file_name = f"{first_name}_{last_name}_guest_{i}_{random_text}.pdf"
        pdf_file_path = os.path.join(output_dir, pdf_file_name)
        
        pdf = FPDF(orientation='L', unit='mm', format=(95, 170))
        pdf.add_page()

        pdf.set_fill_color(230, 230, 250)  # Light lavender color
        pdf.rect(0, 0, 95, 170, 'F')

        pdf.set_draw_color(0, 0, 0)  # Black color
         # Bold text
        pdf.set_font("Helvetica", 'B', 10)

        pdf.set_xy(10, 10)
        pdf.cell(0, 10, "EVENT", ln=True)
        pdf.set_xy(10, 30)
        pdf.cell(0, 10, "LOCATION", ln=True)
        pdf.set_xy(10, 50)
        pdf.cell(0, 10, "DATE AND TIME", ln=True)
        pdf.set_xy(120, 50)
        pdf.cell(40, 10, "1 ADULT PASS", ln=True, align='C')

        #  Non Bold text
        pdf.set_font("Arial", 'I', 10)

        pdf.set_xy(10, 15)
        pdf.cell(0, 10, "Orby and Uche's Wedding Party", ln=True)
        pdf.set_xy(10, 35)
        pdf.cell(0, 10, "GIA Event Center, Aba-Owerri Road, Aba", ln=True)
        pdf.set_xy(10, 55)
        pdf.cell(0, 10, "14th December, 2024 1:00PM", ln=True)
        pdf.set_xy(120, 55)
        pdf.cell(40, 10, f"Guest Name: {first_name} {last_name}", ln=True, align='C')
        pdf.set_xy(120, 60)
        pdf.cell(40, 10, f"Guest Ticket: {i} of {total_guests}", ln=True, align='C')
        
        # QR code section
        pdf.image(file_path, x=120, y=10, w=40)  # Adjust positioning

        pdf.output(pdf_file_path)
        pdf_paths.append(pdf_file_path)
        
    return pdf_paths

def send_email_invitation(first_name, email, pdf_paths):
    mailgun_api_key = os.getenv('MAILGUN_API_KEY')
    files = [("attachment", (os.path.basename(pdf_path), open(pdf_path, "rb").read())) for pdf_path in pdf_paths]
    
    return requests.post(
        "https://api.mailgun.net/v3/mail.nebed.io/messages",
        auth=("api", mailgun_api_key),
        files=files,
        data={"from": "Orby & Uche <orbyanduche@mail.nebed.io>",
              "to": f"{first_name} <{email}>",
              "subject": "Your Invitation: Orby & Uche, 14th Dec",
              "template": "wedding invitation",
              "h:X-Mailgun-Variables": f'{{"first_name": "{first_name}", "invite_link": "{calendar_link}"}}'}
    )

def upload_file_to_gcs(bucket_name, pdf_files):

    gcs_urls = []
    # Initialize a client
    storage_client = storage.Client()

    # Get the bucket
    bucket = storage_client.bucket(bucket_name)

    for ticket in pdf_files:
        # Create a blob object
        blob = bucket.blob(ticket)

        # Upload the file
        blob.upload_from_filename(ticket)

        # Generate a signed URL for the blob
        url = blob.generate_signed_url(
            version="v4",
            expiration=timedelta(days=2),  # URL expires in 2 years
            method="GET"
        )
        gcs_urls.append(url)

    return gcs_urls

def send_whatsapp_messages(first_name, phone_number, media_urls):
    base_url = "https://storage.googleapis.com/orbyanducheprivate/"
    client = Client(twilio_account_sid, twilio_auth_token)

    try:
        # Send the initial message with the guest's first name
        client.messages.create(
            content_sid=twilio_nomedia_content_sid,
            from_=f"whatsapp:{twilio_sender_number}",
            to=f"whatsapp:{phone_number}",
            content_variables=dumps({"1": first_name}),
            messaging_service_sid=twilio_messaging_service_sid
        )

        # Loop through the media URLs and send each one
        for url in media_urls:
            adjusted_url = url.replace(base_url, "")
            client.messages.create(
                content_sid=twilio_media_content_sid,
                from_=f"whatsapp:{twilio_sender_number}",
                to=f"whatsapp:{phone_number}",
                content_variables=dumps({"url_path": adjusted_url}),
                messaging_service_sid=twilio_messaging_service_sid
            )
    
    except Exception as e:
        print(f"An error occurred: {e}")

    print()

    return



if __name__ == '__main__':
    app.run(debug=True)
