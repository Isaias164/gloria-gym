from typing_extensions import Required
from rest_framework import serializers


class LoginSerializers(serializers.Serializer):
    user = serializers.CharField(required=True, min_length=6, max_length=15)
    pwd = serializers.CharField(required=True, min_length=8, max_length=60)
