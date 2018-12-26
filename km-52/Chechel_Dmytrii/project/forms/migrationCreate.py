from flask_wtf import FlaskForm
from wtforms import SubmitField, SelectField
from wtforms import validators


class CreateMigrationForm(FlaskForm):
    dbName = SelectField("Создать запрос на миграцию", [validators.InputRequired("Выберите базу данных.")], choices=[('1', 'Mysql'), ('2', 'Postgres')])
    create = SubmitField("Создать запрос на миграцию")

