from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///data.db'
db = SQLAlchemy(app)

class Database(db.Model):
   __tablename__ = 'done-exercises' # print('Exercise: $exercise, Weight: $weight, Sets: $sets, Reps: $reps');
   id = db.Column(db.Integer, primary_key=True, autoincrement=True)
   exercise = db.Column(db.String(100), unique=False, nullable=False)
   weight = db.Column(db.Float, unique=False, nullable=True)
   sets = db.Column(db.Integer, unique=False, nullable=False)
   reps = db.Column(db.Integer, unique=False, nullable=False)
   
with app.app_context():
   db.create_all()


def get_data():
   return_data = {}
   exercises = Database.query.all()
   for e in exercises:
      exercise_data = {
         'exercise': e.exercise,
         'weight': e.weight,
         'sets': e.sets,
         'reps': e.reps
      }
      return_data[e.id] = exercise_data
    
   return return_data

@app.route('/', methods=['GET'])
def index():
   return 'Server is running.'


@app.route('/api/exercises', methods=['GET','POST'])
def result():
   if request.method == 'POST':
      req = request.json
      exercise = req['exercise']
      weight = req['weight']
      sets = req['sets']
      reps = req['reps']
      print(req)

      new_item = Database(exercise=exercise, weight=weight, sets=sets, reps=reps)

      try:
         db.session.add(new_item)
         db.session.commit()

         return jsonify({'message': 'Data added successfully'}), 200

      except Exception as e:
         print(f"Error occured inserting data to db: {e}")
         return jsonify({'error': 'Failed to add data'}), 400
      
   elif request.method == 'GET':
      return jsonify(get_data()), 200



if __name__ == '__main__':
   app.run()