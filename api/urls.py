from os import name
from django.contrib.auth import login
from django.urls import path,include
from .views import Login,MyTemplates,Recerbas,Correo

log = Login.as_view({
    "get":"list",
    "post":"create"
})

r = Recerbas.as_view({
    "post":"create",
    "get":"list"
})
r1 = Recerbas.as_view({
    "get":"retrieve"
})

correo =  Correo.as_view(
    {
    "get":"update"
    }
)

app_name = "api"
urlpatterns = [
    path("crear/cuenta/",MyTemplates.createUser,name="createUser"),
    path("recuperar/cuenta/",MyTemplates.recoveryAccount,name="recoveryPassword"),
    path("index/",MyTemplates.index,name="index"),
    path("inscripcion/usuario/",MyTemplates.inscipcion,name="inscripcion"),
    path("login/",MyTemplates.loginUser,name="login"),
    path("cambiar/correo/",MyTemplates.changeCorreo,name="change-correo"),
    path("cambiar/password/",MyTemplates.changePassword,name="change-password"),
    path("procesar_logging/",log,name="procesar"),
    path("usuario/inscripcion/deportes/",r,name="deportes"),
    path("",Login.logoutSession,name="logout"),
    path("actualizar/datos/usuario/correo/",Login.update,name="put-correo"),
    path("actualizar/datos/usuario/password/",Login.update,name="put-password"),
    path("lista/recerbas-hechas/",r,name="recerbas-hechas"),
    path("eliminar/recerba/",r1,name="eliminarRecerba"),
    path("datos/usuario/",Login.informacionDatosUsuario,name="datos-usuario"),
    path("recuperar/password/",correo,name="recovery-count"),
    path("eliminar/cuenta/",Login.eliminar_cuenta)
]