from django.urls import path
from .views import LogingViews, UserViews
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

create_user = UserViews.as_view({"post": "create"})
validate_user = UserViews.as_view({"post": "login_user"})


urlpatterns = [
    path("create/user/", create_user, name="create-user"),
    path("loging/user/", validate_user, name="loging-user"),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
