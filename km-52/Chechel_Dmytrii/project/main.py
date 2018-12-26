from flask import Flask, render_template, request, flash, session, url_for, redirect, make_response
from forms.registration import RegForm
from forms.login import LoginForm
from forms.migrationCreate import CreateMigrationForm
from forms.addFileForm import FileUploadForm
from dao.db_access_functions import *
from datetime import datetime, timedelta
from werkzeug.utils import secure_filename
import plotly
import os
import plotly.plotly as py
import plotly.graph_objs as go
import hashlib
import csv
import json
import random
import string

app = Flask(__name__)
app.secret_key = 'Dkey'

UPLOAD_HOST = 'http://localhost:5000/'
UPLOAD_FOLDER = 'static/uploadfiles/'
ALLOWED_EXTENSIONS = set(['csv'])
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS



@app.route('/')
def index():
    if 'login' in session:
        login = session['login']
        if login is None:
            return redirect(url_for('login'))
        else:
            return redirect(url_for('getMigrationsRequestsList'))
    else:
        login = request.cookies.get('login')
        session['login'] = login
        if login is None:
            return redirect(url_for('login'))
        else:
            return redirect(url_for('getMigrationsRequestsList'))


@app.route('/login', methods=['GET', 'POST'])
def login():
    login_form = LoginForm()

    if request.method == 'POST':
        user = loginUser(request.form['login'], request.form['password'])

        if not user:
            return render_template('login.html', form=login_form, message='User with current login does not exists.')
        else:
            if login_form.validate():
                session['login'] = request.form['login']
                response = make_response(redirect(url_for('getMigrationsRequestsList')))
                expires = datetime.now()
                expires += timedelta(weeks=10)
                response.set_cookie('login', request.form['login'], expires=expires)
                return response
            else:
                return render_template('login.html', form=login_form)
    else:
        if 'login' in session:
            return render_template('login.html', form=login_form)
        else:
            login = request.cookies.get('login')
            session['login'] = login
            if login is None:
                return render_template('login.html', form=login_form)
            else:
                return redirect(url_for('index'))


@app.route('/registration', methods=['GET', 'POST'])
def registration():
    reg_form = RegForm()

    if request.method == 'POST':
        if not reg_form.validate():
            return render_template('registration.html', form=reg_form)
        else:
            user = getUserByEmail(request.form['email'])

            if user:
                return render_template('registration.html', form=reg_form, is_unique='User with current login already exists.')
            else:
                user_login = regUser(request.form['email'], request.form['name'], request.form['password'])

                session['login'] = user_login
                response = make_response(redirect(url_for('getMigrationsRequestsList')))
                expires = datetime.now()
                expires += timedelta(weeks=10)
                response.set_cookie('login', user_login, expires=expires)
                return response

    return render_template('registration.html', form=reg_form)


@app.route('/getMigrationsRequestsList', methods=['GET'])
def getMigrationsRequestsList():
    login = session['login']
    if 'login' in session:
        if login is None:
            return redirect(url_for('index'))
        migrationsList = getMigrationRequests(login)
        migrationsListStruct = []
        for migrationRequest in migrationsList:
            migrationStatuses = getMigrationStatuses(migrationRequest[0])
            if migrationStatuses:
                currentStatusName = getStatusName(migrationStatuses[0][1])[0][0]
            else:
                currentStatusName = ''
            migrationsListStruct.append({
                'id': migrationRequest[0],
                'dt': datetime.strftime(migrationRequest[2], '%Y-%m-%d %I:%M'),
                'db': migrationRequest[4],
                'curr_status': currentStatusName
            })
        createMigrationForm = CreateMigrationForm()
        return render_template('migrations_requests_list.html', migrationsList=migrationsListStruct, create_form=createMigrationForm, login=login)
    else:
        return redirect(url_for('index'))

@app.route('/createMigrationRequest', methods=['POST'])
def createMigrationRequest():
    login = session['login']
    if 'login' in session:
        if login is None:
            return redirect(url_for('index'))

    if request.method == 'POST':
        databaseId = request.form['dbName']
        addMigrationRequest(databaseId, login)
        lastMigrationRequest = getMigrationRequests(login)[0]
        setMigrationStatus(lastMigrationRequest[0], 'created')

    return redirect(url_for('getMigrationsRequestsList'))

@app.route('/getMigrationRequest/<int:migration_id>', methods=['GET'])
def getMigrationRequest(migration_id):
    login = session['login']
    if 'login' in session:
        if login is None:
            return redirect(url_for('index'))

    migrationRequest = getMigrationRequestById(migration_id)
    migrationFiles = getMigrationFiles(migration_id)
    migrationStatuses = getMigrationStatuses(migrationRequest[0])
    migrationRequestStruct = {
        'id': migrationRequest[0],
        'ts': datetime.strftime(migrationRequest[2], '%Y-%m-%d %I:%M'),
        'db': migrationRequest[4],
    }
    migrationFilesStruct = []
    migrationStatusesStruct = []
    for migrationStatus in migrationStatuses:
        migrationStatusName = getStatusName(migrationStatus[1])[0]
        migrationStatusesStruct.append({
            'status_name': migrationStatusName[0],
            'ts': datetime.strftime(migrationStatus[2], '%Y-%m-%d %I:%M')
        })
    for migrationFile in migrationFiles:
        migrationFilesStruct.append({
            'link': migrationFile[0],
            'ts': datetime.strftime(migrationFile[2], '%Y-%m-%d %I:%M'),
            'file_size': migrationFile[3]
        })

    fileUploadForm = FileUploadForm()

    return render_template(
        'migration_request_info.html',
        migrationRequest=migrationRequestStruct,
        migrationStatuses=migrationStatusesStruct,
        migrationFiles=migrationFilesStruct,
        login=login,
        upload_form=fileUploadForm
    )

@app.route('/addMigrationFile/<int:migration_id>', methods=['POST'])
def addMigrationFile(migration_id):
    if 'fileInput' not in request.files:
        flash('No file part')
        return redirect(request.url)
    file = request.files['fileInput']
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    if file and allowed_file(file.filename):
        filename = secure_filename(file.filename)
        filename = hashlib.sha224(bytes(filename, 'utf-8')).hexdigest()
        filePath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filePath)
        fileSize = os.path.getsize(filePath)
        setNewMigrationFile(UPLOAD_HOST + filePath, fileSize, migration_id)

    return redirect('/getMigrationRequest/' + str(migration_id))

@app.route('/migrate/<int:migration_id>', methods=['GET'])
def getMigrationResult(migration_id):
    migrationFiles = getMigrationFiles(migration_id)
    if migrationFiles:
        fileName = UPLOAD_FOLDER +''.join(random.choices(string.ascii_uppercase + string.digits, k=12)) + '.json'
        f = open(fileName, "a+")
        for migrationFile in migrationFiles:
            with open(migrationFile[0].replace(UPLOAD_HOST, ''), newline='') as csvfile:
                reader = csv.DictReader(csvfile)
                for row in reader:
                    jsonDoc = json.dumps(row)
                    f.write(jsonDoc)
        setMigrationStatus(migration_id, 'finished')
        return redirect(UPLOAD_HOST + fileName)

    return redirect('/getMigrationRequest/' + str(migration_id))


@app.route('/statistics', methods=['GET'])
def statistics():
    login = session['login']
    if not 'login' in session:
        return redirect(url_for('index'))

    migrationRequestsList = getAllMigrationRequests()
    migrationFilesList = getAllMigrationFiles()
    migrationRequestsScatter = go.Scatter(
        x=[current[3] for current in migrationRequestsList],
        y=[current[0] for current in migrationRequestsList],
        name='Migration requests'
    )
    print(migrationRequestsScatter)

    migrationFilesScatter = go.Scatter(
        x=[current[3] for current in migrationFilesList],
        y=[current[0] for current in migrationFilesList],
        name='Migration files'
    )
    print(migrationFilesScatter)


    dataScatter = [migrationFilesScatter, migrationRequestsScatter]
    graphJSONscatter = json.dumps(dataScatter, cls=plotly.utils.PlotlyJSONEncoder)
    return render_template('statistics.html', login=login,
                            graphJSONscatter=graphJSONscatter)


@app.route('/logout')
def logout():
    session.pop('login', None)
    response = make_response(redirect(url_for('index')))
    response.set_cookie('login', '', expires=0)
    return response


if __name__ == '__main__':
    app.run(debug=True)
