"""
Створити два словники: databases и users
"""




from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

@app.route('/api/<action>', methods = [ 'GET'])
def apiget(action):

   if action == "users":
      return render_template("user.html",users=users_dict)

   elif action == "databases":
      return render_template("database.html", databases=databases_dict)

   elif action == "all":
      return render_template("all.html", users=users_dict, databases=databases_dict)

   else:
      return render_template("404.html", action_value=action, possible=["databases", "users"])

@app.route('/api', methods=['POST'])
def apipost():

   if request.form["action"] == "users":

      users_dict["email"] = request.form["email"]
      users_dict["name"] = request.form["name"]

      return redirect(url_for('apiget', action="users"))
   elif request.form["action"] == "databases":

      databases_dict["id"] = request.form["id"]
      databases_dict["name"] = request.form["name"]

      return redirect(url_for('apiget', action="databases"))

if __name__ == "__main__":
    databases_dict = {
        "id": 1,
        "name": "mysql",
    }

    users_dict = {
        "email": "petro@petro.com",
        "name": "petro"
    }
    app.run("0.0.0.0", port=80, debug=True)
