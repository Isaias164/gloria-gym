from typing_extensions import Required
from rest_framework import serializers


class LoginSerializers(serializers.Serializer):
    user = serializers.CharField(min_length=6, max_length=15)
    pwd = serializers.CharField(min_length=8, max_length=60)

class CreateUserSerializers(LoginSerializers):
    first_name = serializers.CharField(min_length=3,max_length=15)
    last_name = serializers.CharField(min_length=3,max_length=15)
    email = serializers.EmailField()
