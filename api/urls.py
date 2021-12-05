from os import name
from django.urls import path
from .views import Login, Recerbas, Correo
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register("usuario", Login, basename="usuarios")
urlpatterns = router.urls

# log = Login.as_view({"post": "create", "delete": "destroy"})
# log_action = Login.as_view({"post": "login_user"})

# r = Recerbas.as_view({"post": "create", "get": "list"})
# r1 = Recerbas.as_view({"get": "retrieve"})

# correo = Correo.as_view({"get": "update"})

# app_name = "api"
# urlpatterns = [
#     path("create/user", log, name="change-password"),
#     path("procesar_logging", log_action, name="procesar"),
#     path("usuario/inscripcion/deportes/", r, name="deportes"),
#     path("", Login.logoutSession, name="logout"),
#     path("actualizar/datos/usuario/correo/", Login.update, name="put-correo"),
#     path("actualizar/datos/usuario/password/", Login.update, name="put-password"),
#     path("lista/recerbas-hechas/", r, name="recerbas-hechas"),
#     path("eliminar/recerba/", r1, name="eliminarRecerba"),
#     path("datos/usuario/", Login.informacionDatosUsuario, name="datos-usuario"),
#     path("recuperar/password/", correo, name="recovery-count"),
#     path("eliminar/cuenta/", log),
# ]

from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

urlpatterns = [
    path("api/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
]
