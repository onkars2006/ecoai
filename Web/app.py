# app.py
from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_session import Session
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime,timedelta
from flask import jsonify


app = Flask(__name__)
app.config["SECRET_KEY"] = "your_secret_key_here"
app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

# Initialize Firebase
cred = credentials.Certificate("D:\Onkar\Hackathons\Google AI Solution\Website\ecoscan_service_key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

ADMIN_CREDENTIALS = {"username": "admin", "password": "admin"}

def get_user_stats():
    users_ref = db.collection("users")
    docs = users_ref.stream()
    
    stats = {
        'total_users': 0,
        'total_points': 0,
        'total_camera_uses': 0,
        'registration_dates': {},
        'points_distribution': []
    }
    
    for doc in docs:
        user = doc.to_dict()
        stats['total_users'] += 1
        stats['total_points'] += user.get('points', 0)
        camera_uses = user.get('imageAnalysisCount', 0)
        stats['total_camera_uses'] += camera_uses
        
        # Registration dates
        reg_date = user.get('createdAt')
        if reg_date:
            reg_date = reg_date.replace(tzinfo=None)
            stats['registration_dates'][reg_date.date()] = stats['registration_dates'].get(reg_date.date(), 0) + 1
        
        # Points distribution
        stats['points_distribution'].append(user.get('points', 0))
        
    # Sort and prepare chart data
    stats['registration_dates'] = dict(sorted(stats['registration_dates'].items()))
    stats['points_distribution'] = sorted(stats['points_distribution'], reverse=True)
    
    return stats

@app.route("/login", methods=['GET', 'POST'])
def login():
    if session.get("admin_logged_in"):
        return redirect(url_for('dashboard'))
    
    error = None
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if (username == ADMIN_CREDENTIALS['username'] and 
            password == ADMIN_CREDENTIALS['password']):
            session['admin_logged_in'] = True
            return redirect(url_for('dashboard'))
        else:
            error = 'Invalid credentials'
    
    return render_template('login.html', error=error)

@app.route("/dashboard")
def dashboard():
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))
    
    stats = get_user_stats()
    
    # Prepare chart data
    chart_data = {
        'registrations': {
            'labels': [str(date) for date in stats['registration_dates'].keys()],
            'data': list(stats['registration_dates'].values())
        },
        'points_distribution': stats['points_distribution'][:10],
        'camera_usage': {
            'total': stats['total_camera_uses'],
            'average': stats['total_camera_uses'] / stats['total_users'] if stats['total_users'] > 0 else 0
        }
    }
    
    return render_template("dashboard.html", 
                         stats=stats,
                         chart_data=chart_data)

@app.route("/users")
def users():
    if not session.get("admin_logged_in"):
        return redirect(url_for("login"))
    
    users_ref = db.collection("users")
    docs = users_ref.stream()
    
    users = []
    for doc in docs:
        user_data = doc.to_dict()
        users.append({
            "uid": user_data.get("uid"),
            "email": user_data.get("email"),
            "displayName": user_data.get("displayName"),
            "points": user_data.get("points", 0),
            "referrals": user_data.get("referrals", 0),
            "createdAt": user_data.get("createdAt"),
            "imageAnalysisCount": user_data.get("imageAnalysisCount", 0)
        })
    
    return render_template("users.html", users=users)


# Rewards Management Routes
@app.route('/rewards')
def rewards_list():
    if not session.get("admin_logged_in"):
        return redirect(url_for('login'))
    
    rewards_ref = db.collection('rewards')
    rewards = [doc.to_dict() | {'id': doc.id} for doc in rewards_ref.stream()]
    return render_template('rewards.html', rewards=rewards)

@app.route('/rewards/create', methods=['GET', 'POST'])
def create_reward():
    if not session.get("admin_logged_in"):
        return redirect(url_for('login'))
    
    icons = [
        ('park', 'Nature'),
        ('school', 'Education'),
        ('people', 'Community'),
        ('clean_hands', 'Cleanup'),
        ('electrical_services', 'E-Waste'),
        ('eco', 'Eco')
    ]
    
    types = [
        ('action', 'Action'),
        ('education', 'Education'),
        ('community', 'Community')
    ]
    
    if request.method == 'POST':
        reward_data = {
            'type': request.form['type'],
            'title': request.form['title'],
            'points': int(request.form['points']),
            'impact': request.form['impact'],
            'icon': request.form['icon'],
            'created_at': datetime.now()
        }
        
        try:
            db.collection('rewards').add(reward_data)
            flash('Reward created successfully!', 'success')
            return redirect(url_for('rewards_list'))
        except Exception as e:
            flash(f'Error creating reward: {str(e)}', 'danger')
        
    return render_template('reward_form.html', 
                         icons=icons, 
                         types=types,
                         reward=None)

@app.route('/rewards/edit/<reward_id>', methods=['GET', 'POST'])
def edit_reward(reward_id):
    if not session.get("admin_logged_in"):
        return redirect(url_for('login'))
    
    icons = [
        ('park', 'Nature'),
        ('school', 'Education'),
        ('people', 'Community'),
        ('clean_hands', 'Cleanup'),
        ('electrical_services', 'E-Waste'),
        ('eco', 'Eco')
    ]
    
    types = [
        ('action', 'Action'),
        ('education', 'Education'),
        ('community', 'Community')
    ]
    
    reward_ref = db.collection('rewards').document(reward_id)
    
    if request.method == 'POST':
        update_data = {
            'type': request.form['type'],
            'title': request.form['title'],
            'points': int(request.form['points']),
            'impact': request.form['impact'],
            'icon': request.form['icon']
        }
        
        try:
            reward_ref.update(update_data)
            flash('Reward updated successfully!', 'success')
            return redirect(url_for('rewards_list'))
        except Exception as e:
            flash(f'Error updating reward: {str(e)}', 'danger')
    
    reward = reward_ref.get().to_dict()
    reward['id'] = reward_id
    return render_template('reward_form.html', 
                         reward=reward,
                         icons=icons,
                         types=types)

@app.route('/rewards/delete/<reward_id>')
def delete_reward(reward_id):
    if not session.get("admin_logged_in"):
        return redirect(url_for('login'))
    
    try:
        db.collection('rewards').document(reward_id).delete()
        flash('Reward deleted successfully!', 'success')
    except Exception as e:
        flash(f'Error deleting reward: {str(e)}', 'danger')
    
    return redirect(url_for('rewards_list'))


@app.route("/logout")
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == "__main__":
    app.run(debug=True)