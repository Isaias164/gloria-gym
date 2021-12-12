from rest_framework import serializers


class LoginSerializers(serializers.Serializer):
    username = serializers.CharField(
        min_length=6,
        max_length=15,
    )
    password = serializers.CharField(
        min_length=8
    )


class CreateUserSerializers(LoginSerializers):
    first_name = serializers.CharField(min_length=3, max_length=15)
    last_name = serializers.CharField(min_length=3, max_length=15)
    email = serializers.EmailField(error_messages={"email": "El email no es valido"})
