from flask_wtf import FlaskForm
from wtforms import StringField, SubmitField, PasswordField, validators


class LoginForm(FlaskForm):
    login = StringField('Email', validators=[validators.DataRequired('Пожалуйста, введіте логин: '), validators.Length(4, 20, 'Длина логина должна быть от 4 до 20 символов')])
    password = PasswordField('Password', validators=[validators.DataRequired('Пожалуйста, введите пароль:'), validators.Length(4, 20, 'Длина пароля должна быть от 4 до 20 символов')])

    submit = SubmitField('Войти')
