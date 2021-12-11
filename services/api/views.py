from datetime import date
from .models import GruposReserbas, Instalaciones
from django.shortcuts import HttpResponse, HttpResponseRedirect, render
from django.views.decorators.csrf import csrf_exempt
from rest_framework.viewsets import ViewSet
from rest_framework.response import Response

# from rest_framework.views import APIView
from rest_framework.decorators import action
from .serializers.serializers import *
from rest_framework.permissions import IsAuthenticated, AllowAny


class X(ViewSet):
    def update(self, reques, pk=None):
        from django.contrib.auth.models import User

        a = User.objects.filter(email="ejemplo1@gmail.com")
        a = a.update(email="est_es_otro_correo@gmail.com").query.__str__()
        print(a)

        # print(a[0].update(email="est_es_otro_correo@gmail.com").query)
        return Response(
            {"mensaje": "correo actualizado correctamnte"},
            status=200,
            content_type="application/json",
        )


class Login(ViewSet):
    permission_classes = [IsAuthenticated]

    @action(detail=True, methods=["post"])
    # @csrf_exempt
    def login_user(self, request):
        from django.contrib.auth import authenticate, login

        datos = LoginSerializers(data=request.data)
        if not datos.is_valid():
            return Response(
                {
                    "login": False,
                    "messaje": datos.error_messages,
                }
            )
        # Verifico si el usuario esta en la base de datos
        usuario = authenticate(
            username=datos.validated_data["user"], password=datos.validated_data["pwd"]
        )
        # si las credenciales son correctas me devuelve un objeto user si no me devuelve None
        if usuario is not None:
            # asocio el usuario con la session
            login(request, usuario)
            # return HttpResponseRedirect("api/token/")
            return Response(
                {"login": True, "message": "Usuario validado correctamente"}
            )
        else:
            return Response(
                {
                    "login": False,
                    "mensaje": "Posibles causas del fallo:\n1- El usuario y/o la contraseña no coincide\n2-Su usuario ha sido desactivado por el administrador. Contacte con el administrador",
                },
            )

    def create(self, request):
        from django.contrib.auth.models import User
        from django.contrib.auth import login

        try:
            datos = CreateUserSerializers(data=request.data)
            if not datos.is_valid():
                return Response({"create_user": False, "error": datos.error_messages})
            name = request.data["first_name"]
            last_name = request.data["last_name"]
            correo = request.data["email"]
            pwd = request.data["pwd"]
            username = request.data["user"]
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
                    login(request, userAuth)
                    # return HttpResponseRedirect(MyTemplates.redirection_template_index)
                    return Response({"usuario_create": True, "redirect": "/api/index"})
                else:
                    return Response(
                        {
                            "usuario": "Este usuario ya existe en la base de datos. Elija otro usuario",
                            "nombre": name,
                            "apellido": last_name,
                            "correo": correo,
                        }
                    )
            else:
                return Response(
                    {
                        "correo": "Este correo ya existe en la base de datos. Elija otro correo",
                        "nombre": name,
                        "apellido": last_name,
                    }
                )
        except Exception as objExceptions:
            return Response({"error: ": str(objExceptions)})

    def logoutSession(request):
        from django.contrib.auth import logout

        logout(request)
        return HttpResponse("Has salido del sistema")

    def destroy(self, request, pk=None):
        """
        Esta vista elimina la cuneta del usuario
        """
        Instalaciones.insertar(
            request,
            "CALL DECREMENTAR_RECERBAS_REALIZADAS_USUARIO(%s)",
            (request.user.username,),
        )
        request.user.delete()
        request.session.flush()
        # return HttpResponseRedirect("/api/login/")
        return Response(
            {"error": False, "message": "cuenta elimnada satisfactoriamente"}
        )

    def update(request):
        # si la solicitud contiene una clave email
        if "email" in request.POST:
            correo = "No fue posible cambiar su dirección de correo. Vuelva a intentarlo más tarde"
            try:
                # cambio el email
                request.user.email = request.POST["email"]
                request.user.save()
                correo = (
                    "Se ha estabelcido el email "
                    + request.POST["email"]
                    + " satisfactoriamente"
                )
            except:
                pass
            # renderizo la plantilla correspondiente a el cambio de correo
            return render(request, "correo_change.html", {"correo": correo})
        # si la solicitud contiene una clave passwordNew
        if "passwordNew" in request.POST:
            mensajePassword = (
                "No se ha podido cambiar su contraseña.Vuelva a intentarlo más tarde"
            )
            # Obtengo los datos de la vieja session
            if request.user.check_password(request.POST["passwordOld"]):
                from django.contrib.auth import update_session_auth_hash

                request.user.set_password(request.POST["passwordNew"])
                request.user.save()
                update_session_auth_hash(request, request.user)
                mensajePassword = "Se ha actualizado la contraseña correctamente"
            else:
                mensajePassword = (
                    "Su contraseña actual no se encuntra en la base de datos"
                )
            return render(
                request, "password_change.html", {"respuesta": mensajePassword}
            )

    def informacionDatosUsuario(request):
        return render(
            request,
            "informacion_usuario.html",
            {
                "nombre": request.user.first_name + " " + request.user.last_name,
                "usuario": request.user.username,
                "email": request.user.email,
                "fechaCreacion": request.user.date_joined,
            },
        )


class Recerbas(ViewSet):
    def create(self, request):
        try:
            deporte = request.POST["deporte"].lower()
            resp = ""
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
                        request.POST["deporte"],
                        request.POST["fecha"],
                        request.POST["hora"],
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
                        request.POST["deporte"],
                        request.POST["fecha"],
                        request.POST["hora"],
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
                        request.POST["deporte"],
                        request.POST["fecha"],
                        request.POST["hora"],
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
                        request.POST["deporte"],
                        request.POST["fecha"],
                        request.POST["hora"],
                    ),
                )
            else:
                resp = "NO HAS SELECCIONADO UN DEPORTE. POR FAVOR SELECIONA UN DEPORTE".upper()
            # renderizo la plantilla con los datos enviados por la bd
            return render(request, "confirmacion_reserba.html", {"respuesta": resp[0]})
        except Exception as obj:
            return HttpResponse("ha ocurrido el siguiente error: " + str(obj))

    def formatearDatos(self, request, datos):
        datos_formateados = []
        for dato in datos:
            registro = []
            for tipoDato in dato:
                if isinstance(tipoDato, date):
                    registro.append(tipoDato.strftime("%d/%m/%Y"))
                else:
                    registro.append(tipoDato)
            datos_formateados.append(registro)
        return datos_formateados

    def retrieve(self, request):
        idCliente = GruposReserbas.eliminarRecerbaModels(self, request.GET["id"])
        return HttpResponse("Recerva eliminada")

    def list(self, request):
        from .models import GruposReserbas

        listaRecerbas = GruposReserbas.listar(self, request.user.username)
        listaRecerbas = self.formatearDatos(request, listaRecerbas)
        return render(request, "recerbas_hechas.html", {"recerbas": listaRecerbas})


class Correo(ViewSet):
    def update(self, request):
        mensaje = "El correo que proporcionaste no se encuentra en la base de datos"

        try:
            from .models import Instalaciones

            # este try verifica que el correo este en la base de datos
            existe_correo = Instalaciones.insertar(
                self, "SELECT EXISTE_CORREO(%s)", (request.GET["correo"],)
            )
            if existe_correo[0]:
                from django.contrib.auth.models import User

                obj_user = User.objects.get(email=request.GET["correo"])
                # Genero y almaceno la contraseña con e tipo de encriptación del backend
                new_password = request.GET["password"] + self.generar_salt(
                    request, request.GET["password"]
                )
                obj_user.set_password(new_password)
                obj_user.save()
                from django.core.mail import send_mail

                send_mesaage = send_mail(
                    "Cambio de contraseña",
                    "Hemos reestrablecido su contraseña con exito\nSu nueva contraseña es: "
                    + new_password,
                    from_email="complejodeportivolagloria02020@gmail.com",
                    recipient_list=[
                        request.GET["correo"],
                    ],
                )
                if send_mesaage:
                    return Response(
                        "Su contraseña se ha modificado con exito. La contraseña se ha enviado a su correo"
                    )
            else:
                return Response(mensaje)
        except Exception as obj:
            return Response(mensaje)

    def generar_salt(self, request, password: str) -> str:
        from random import randint

        salt = ""
        value_random_range = randint(1, len(password))
        for character in range(value_random_range):
            value_random = randint(0, len(password) - 1)
            salt += password[value_random]
        return salt
