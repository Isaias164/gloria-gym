from django.urls import path
from . import views

a = views.S.as_view({"post": "create"})
urlpatterns = [path("mailing/", a)]
