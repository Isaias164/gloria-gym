from django.shortcuts import HttpResponse, HttpResponseRedirect, render
from django.contrib.auth.models import User
from django.contrib.auth import login, logout

from rest_framework.viewsets import ViewSet
from rest_framework.response import Response
from rest_framework import status

from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated, AllowAny
from .serializers.serializers import *

from .models import GruposReserbas, Instalaciones


class UserViews(ViewSet):
    permission_classes = [AllowAny]

    @action(detail=True, methods=["post"])
    def login_user(self, request):
        from django.contrib.auth import authenticate, login

        datos = LoginSerializers(data=request.data)
        if not datos.is_valid():
            return Response(
                {"login": False, "messaje": datos.errors},
                status=status.HTTP_400_BAD_REQUEST,
            )
        # Verifico si el usuario esta en la base de datos
        usuario = authenticate(
            username=datos.validated_data["username"],
            password=datos.validated_data["password"],
        )
        # si las credenciales son correctas y/o el usuario existe en la bd
        if usuario is not None:
            # asocio el usuario con la session
            login(request, usuario)
            # llamo al endpoint que me va a generar el token bearer para acceder a las demás clases más adelante
            # La vista que me genera el token va a retornar al cliente el token/refreshtoken
            return HttpResponseRedirect(
                "/api/token/",
                content=datos.validated_data,
                content_type="application/json",
                status=status.HTTP_308_PERMANENT_REDIRECT,
            )
        else:
            return Response(
                {
                    "login": False,
                    "mensaje": "Posibles causas del fallo:\n1- El usuario y/o la contraseña no coincide\n2-Su usuario ha sido desactivado por el administrador. Contacte con el administrador",
                },
                status=status.HTTP_202_ACCEPTED,
            )

    def create(self, request):

        try:
            datos = CreateUserSerializers(data=request.data)
            if not datos.is_valid():
                return Response(
                    {"create_user": False, "error": datos.errors},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            name = datos.validated_data["first_name"]
            last_name = datos.validated_data["last_name"]
            correo = datos.validated_data["email"]
            pwd = datos.validated_data["password"]
            username = datos.validated_data["username"]
            existe_usuario = Instalaciones.insertar(
                self, "SELECT EXISTE_USUARIO(%s)", (username,)
            )
            existe_correo = Instalaciones.insertar(
                self, "SELECT EXISTE_CORREO(%s)", (correo,)
            )
            if not existe_correo[0]:
                if not existe_usuario[0]:
                    userAuth = User.objects.create_user(
                        username,
                        correo,
                        pwd,
                        first_name=name,
                        last_name=last_name,
                    )
                    # creo la sessión y guardo el nombre de usuario y nombre
                    request.session["usuario"] = (
                        username,
                        name,
                    )
                    # unimos la session con el usuario
                    login(request, userAuth)
                    # obtenemos su token
                    datos.validated_data.pop("first_name")
                    datos.validated_data.pop("last_name")
                    datos.validated_data.pop("email")
                    return HttpResponseRedirect(
                        "/api/token/",
                        content=datos.validated_data,
                        content_type="application/json",
                        status=status.HTTP_308_PERMANENT_REDIRECT,
                    )

                else:
                    return Response(
                        {
                            "usuario": f"El usuario {username} ya existe en la base de datos. Elija otro usuario",
                        },
                        status=status.HTTP_208_ALREADY_REPORTED,
                        content_type="application/json",
                    )
            else:
                return Response(
                    {
                        "correo": f"El correo {correo} ya existe en la base de datos. Elija otro correo",
                    },
                    status=status.HTTP_208_ALREADY_REPORTED,
                    content_type="application/json",
                )
        except Exception as objExceptions:
            return Response(
                {"error: ": str(objExceptions)},
                content_type="application/json",
                status=status.HTTP_400_BAD_REQUEST,
            )


class LogingViews(ViewSet):
    permission_classes = [IsAuthenticated]

    def destroy(self, request, pk=None):
        """
        Esta vista elimina la cuenta del usuario
        """
        Instalaciones.insertar(
            request,
            "CALL DECREMENTAR_RECERBAS_REALIZADAS_USUARIO(%s)",
            (request.user.username,),
        )
        request.user.delete()
        request.session.flush()
        logout(request)
        return Response(
            {"error": False, "message": "cuenta elimnada satisfactoriamente"},
            status=status.HTTP_202_ACCEPTED,
            content_type="application/json",
        )

    def list(request):
        data = {
            "nombre": request.user.first_name + " " + request.user.last_name,
            "usuario": request.user.username,
            "email": request.user.email,
            "fechaCreacion": request.user.date_joined,
        }
        return Response(
            data=data, status=status.HTTP_200_OK, content_type="application/json"
        )


class EmailViews(ViewSet):
    permission_classes = [IsAuthenticated]

    def update(self, request):
        datos = UpdateEmailSerializers(data=request.data)
        data = "Correo actualizado correctamnte"
        if not datos.is_valid():
            return Response(data={"error": True, "message": "Este campo es requerido"})
        estado = status.HTTP_205_RESET_CONTENT
        try:
            request.user.email = datos.validated_data["email"]
            request.user.save()
        except Exception as e:
            data = "Ha ocurrido un error y no hemos podido actualizar tu correo"
            print("Ocurrio el siguiente error")
            estado = status.HTTP_400_BAD_REQUEST
        finally:
            return Response(data=data, status=estado, content_type="application/json")


class PasswordViews(ViewSet):
    permission_classes = [IsAuthenticated]

    def update(self, request):
        datos = UpdatePasswordSerializers(data=request.data)
        if not datos.is_valid():
            return Response(
                data={"error": True, "message": "Este campo es requerido"},
                status=status.HTTP_400_BAD_REQUEST,
                content_type="application/json",
            )
        if not datos.validated_data["password"] == datos.validated_data["password2"]:
            return Response(
                data={"password": "Las contraseñas no coinciden"},
                content_type="application/json",
                status=status.HTTP_204_NO_CONTENT,
            )

        mensaje = """No se ha podido cambiar su contraseña.
                        Vuelva a intentarlo más tarde"""
        stado = status.HTTP_205_RESET_CONTENT
        try:
            from django.contrib.auth import update_session_auth_hash

            request.user.set_password(datos.validated_data["password2"])
            request.user.save()
            update_session_auth_hash(request, request.user)
            mensaje = "Se ha actualizado la contraseña correctamente"
        except Exception as e:
            stado = status.HTTP_400_BAD_REQUEST
            print(f"error {str(e)}")
        finally:
            return Response(data=mensaje, content_type="application/json", status=stado)


class Recerbas(ViewSet):
    def create(self, request):
        datos = DeportesSerializers(data=request.data)
        if not datos.is_valid():
            return Response(
                data={"error": "Datos json mal enviados"},
                content_type="application/json",
                status=status.HTTP_400_BAD_REQUEST,
            )
        try:
            deporte = datos.validated_data["deporte"].lower()
            resp = ""
            stado = status.HTTP_200_OK
            # si la solicitud tiene una clve deporte y esa clave deporte es gym
            if deporte == "gym":
                from .models import Gym

                # import el modelo y obtengo los datos del objeto user. Lo mismo hago lo mismo en lo demas elif
                resp = Gym.insertar(
                    self,
                    "SELECT INSERTAR_CLIENTE_GYM(%s,%s,%s,%s,%s,%s,%s)",
                    (
                        1,
                        request.user.first_name,
                        request.user.last_name,
                        request.user.username,
                        deporte,
                        datos.validated_data["fecha"],
                        datos.validated_data["hora"],
                    ),
                )
            elif deporte == "pileta":
                from .models import Pileta

                resp = Pileta.insertar(
                    self,
                    "SELECT INSERTAR_CLIENTE_PILETA(%s,%s,%s,%s,%s,%s,%s)",
                    (
                        1,
                        request.user.first_name,
                        request.user.last_name,
                        request.user.username,
                        deporte,
                        datos.validated_data["fecha"],
                        datos.validated_data["hora"],
                    ),
                )
            elif deporte == "futbol":
                from .models import CanchasFutbol

                resp = CanchasFutbol.insertar(
                    self,
                    "SELECT INSERTAR_CLIENTE_FUTBOL(%s,%s,%s,%s,%s,%s,%s)",
                    (
                        1,
                        request.user.first_name,
                        request.user.last_name,
                        request.user.username,
                        deporte,
                        datos.validated_data["fecha"],
                        datos.validated_data["hora"],
                    ),
                )
            elif deporte == "paddle":
                from .models import CanchasPaddle

                resp = CanchasPaddle.insertar(
                    self,
                    "SELECT INSERTAR_CLIENTE_PADDLE(%s,%s,%s,%s,%s,%s,%s)",
                    (
                        1,
                        request.user.first_name,
                        request.user.last_name,
                        request.user.username,
                        deporte,
                        datos.validated_data["fecha"],
                        datos.validated_data["hora"],
                    ),
                )
            else:
                resp = "NO HAS SELECCIONADO UN DEPORTE. POR FAVOR SELECIONA UN DEPORTE".upper()
                stado = status.HTTP_203_NON_AUTHORITATIVE_INFORMATION
        except Exception as obj:
            stado = status.HTTP_400_BAD_REQUEST
            print("ha ocurrido el siguiente error: " + str(obj))
        finally:
            return Response(data=resp, content_type="application/json", status=stado)

    def retrieve(self, request, pk=None):
        idCliente = GruposReserbas.eliminarRecerbaModels(self, pk)
        return Response(
            data={"mensaje": "Recerva eliminada"},
            content_type="application/json",
            status=status.HTTP_200_OK,
        )

    def list(self, request):
        from .models import GruposReserbas

        listaRecerbas = GruposReserbas.listar(self, request.user.username)
        listaRecerbas = self.formatearDatos(request, listaRecerbas)
        return Response(
            data={"recerbas": listaRecerbas},
            status=status.HTTP_200_OK,
            content_type="application/json",
        )


# class Correo(ViewSet):
#     def update(self, request):
#         mensaje = "El correo que proporcionaste no se encuentra en la base de datos"

#         try:
#             from .models import Instalaciones

#             # este try verifica que el correo este en la base de datos
#             existe_correo = Instalaciones.insertar(
#                 self, "SELECT EXISTE_CORREO(%s)", (request.GET["correo"],)
#             )
#             if existe_correo[0]:
#                 from django.contrib.auth.models import User

#                 obj_user = User.objects.get(email=request.GET["correo"])
#                 # Genero y almaceno la contraseña con e tipo de encriptación del backend
#                 new_password = request.GET["password"] + self.generar_salt(
#                     request, request.GET["password"]
#                 )
#                 obj_user.set_password(new_password)
#                 obj_user.save()
#                 from django.core.mail import send_mail

#                 send_mesaage = send_mail(
#                     "Cambio de contraseña",
#                     "Hemos reestrablecido su contraseña con exito\nSu nueva contraseña es: "
#                     + new_password,
#                     from_email="complejodeportivolagloria02020@gmail.com",
#                     recipient_list=[
#                         request.GET["correo"],
#                     ],
#                 )
#                 if send_mesaage:
#                     return Response(
#                         "Su contraseña se ha modificado con exito. La contraseña se ha enviado a su correo"
#                     )
#             else:
#                 return Response(mensaje)
#         except Exception as obj:
#             return Response(mensaje)

#     def generar_salt(self, request, password: str) -> str:
#         from random import randint

#         salt = ""
#         value_random_range = randint(1, len(password))
#         for character in range(value_random_range):
#             value_random = randint(0, len(password) - 1)
#             salt += password[value_random]
#         return salt
