import cx_Oracle
from dao.connection_info import *


def regUser(user_email, user_password, user_name):

    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    cursor.callproc("USER_PACKAGE.REGISTER", [user_email, user_password, user_name])

    cursor.close()
    connection.close()

    return user_email

def getUserByEmail(user_email):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = "Select * From dchechel.USERS Where EMAIL = :user_email"
    cursor.execute(query, user_email=user_email)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result


def loginUser(login, passw):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM table(USER_PACKAGE.LOG_IN(:login, :passw))'
    cursor.execute(query, login=login, passw=passw)
    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result


def getMigrationRequests(user_login):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM table(MIGRATION_REQUEST_PACKAGE.GET_MIGRATION_REQUESTS(:user_login))'
    cursor.execute(query, user_login=user_login)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def getMigrationRequestById(mr_id):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM table(MIGRATION_REQUEST_PACKAGE.GET_MIGRATION_REQUEST(:mr_id))'
    cursor.execute(query, mr_id=mr_id)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result[0]

def getMigrationStatuses(migration_id):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM table(MIGRATION_STATUS_PACKAGE.GET_MIGRATION_STATUSES(:migration_id))'
    cursor.execute(query, migration_id=migration_id)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def getStatusName(status_id):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT status_name FROM migration_statuses WHERE id = :stid'
    cursor.execute(query, stid=status_id)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def addMigrationRequest(dbId, login):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    cursor.callproc("MIGRATION_REQUEST_PACKAGE.CREATE_MIGRATION_REQUEST", [login, dbId])

    cursor.close()
    connection.close()

    return login

def setMigrationStatus(mr_id, statusName):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    cursor.callproc("MIGRATION_STATUS_PACKAGE.SET_NEW_MIGRATION_STATUS", [mr_id, statusName])

    cursor.close()
    connection.close()

    return mr_id

def getMigrationFiles(migration_id):
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM table(MIGRATION_FILES_PACKAGE.GET_MIGRATION_FILES(:migration_id))'
    cursor.execute(query, migration_id=migration_id)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def setNewMigrationFile(link, size, mr_id):
    connection = cx_Oracle.connect(username, password, databaseName)
    cursor = connection.cursor()

    print(mr_id)
    print(size)
    print(link)
    # cursor.callproc("MIGRATION_FILES_PACKAGE.SET_NEW_FILE", [link, size, mr_id])
    cursor.execute("INSERT INTO MIGRATION_FILES (link, file_size, migration_id) VALUES (:link, :fsize, :mr_id)", link=link, fsize=size, mr_id=mr_id)
    cursor.execute("COMMIT WORK")

    cursor.close()
    connection.close()

    return link

def getAllMigrationRequests():
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM MIGRATION_REQUESTS'
    cursor.execute(query)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result

def getAllMigrationFiles():
    connection = cx_Oracle.connect(username, password, databaseName)

    cursor = connection.cursor()

    query = 'SELECT * FROM MIGRATION_FILES'
    cursor.execute(query)

    result = cursor.fetchall()

    cursor.close()
    connection.close()

    return result