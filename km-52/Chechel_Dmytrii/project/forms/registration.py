from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, PasswordField
from wtforms import validators


class RegForm(FlaskForm):
    email = StringField("Email", [validators.Email("Неправильный формать email адреса")])

    password = PasswordField("Password", [validators.DataRequired("Пароль не введён"),
                                                 validators.Length(4, 20, "Длина логина должна быть от 4 до 20 символов")])
    name = StringField("Name", [validators.Length(1, 20, "Длина имени должна быть от 1 до 20 символов")])

    submit = SubmitField("Зарегистрироватся")
