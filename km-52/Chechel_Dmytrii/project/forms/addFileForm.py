from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, RadioField, SelectField, BooleanField, FileField
from wtforms import validators


class FileUploadForm(FlaskForm):
    fileInput = FileField("Добавить файл для миграции")
    uploadBtn = SubmitField("Добавить файл")

