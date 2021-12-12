from django.urls import path
from .views import LogingViews, UserViews, EmailViews, PasswordViews
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

create_user = UserViews.as_view({"post": "create"})
validate_user = UserViews.as_view({"post": "login_user"})
update_password = PasswordViews.as_view({"put": "update"})

update_email = EmailViews.as_view({"put": "update"})
login = LogingViews.as_view({"get": "list", "delete": "destroy"})

urlpatterns = [
    path("create/user/", create_user, name="create-user"),
    path("loging/user/", validate_user, name="loging-user"),
    path("user/delete/", login, name="delete-user"),
    path("user/data/", login, name="get-data"),
    path("update/email/", update_email, name="update-email"),
    path("update/password/", update_password, name="update-password"),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
