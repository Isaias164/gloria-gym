from datetime import date
from hashlib import new

from django.http.request import HttpRequest
from gloriaGym.api.models import GruposReserbas, Instalaciones
from django.shortcuts import render,HttpResponse,HttpResponseRedirect
from rest_framework.viewsets import ViewSet
class MyTemplates:
    redirection_template_login = "/api/login/"
    redirection_template_index = "/api/index/"

    def createUser(request):
        #verifico si el session key tiene el valor de la sessión
        if request.session.session_key is not None:
            #Si lo tiene redirijo a index
            return HttpResponseRedirect(MyTemplates.redirection_template_index)
        #si no le redirijo la plantilla
        return render(request,"crear_usuario.html")

    def recoveryAccount(request):
        return render(request,"recuperar_password.html")

    def index(request):
        if request.session.session_key is not None:
            return render(request,"index.html")
        return HttpResponseRedirect(MyTemplates.redirection_template_login)
    
    def listReserbas(request):
        if request.session.session_key is not None:
            return render(request,"recerbas_hechas.html")
        return HttpResponseRedirect(MyTemplates.redirection_template_login)

    def inscipcion(request):
        if request.session.session_key is not None:
            return render(request,"formulario_inscripcion.html")
        return HttpResponseRedirect(MyTemplates.redirection_template_login)

    def loginUser(request):
        if request.session.session_key is not None:
            return HttpResponseRedirect(MyTemplates.redirection_template_index)
        return render(request,"login.html")

    def changePassword(request):
        if request.session.session_key is not None:
            return render(request,"password_change.html")
        return HttpResponseRedirect(MyTemplates.redirection_template_login)
    
    def changeCorreo(request):
        if request.session.session_key is not None:
            return render(request,"correo_change.html")
        return HttpResponseRedirect(MyTemplates.redirection_template_login)

class Login(ViewSet):
    def list(self,request):
        from django.contrib.auth import authenticate,login
        #Verifico si el usuario esta en la base de datos
        usuario = authenticate(username=request.GET["user"],password=request.GET["pwd"])
        #si las credenciales son correctas me devuelve un objeto user si no me devuelve None
        if usuario is not None:
            #creo un usuario con el valor 1
            request.session["usuario"] = "1"
            #si recordar1 fu enviado por el cliente
            if "recordar1" in request.GET:
                #si se envio el checkbox sin marcar
                if request.GET["recordar1"] == "off":
                    #La sessión se eliminara al cerrar el navegador
                    request.session.set_expiry(0)
             #asocio el usuario con la session
            login(request,usuario)
            return HttpResponseRedirect(MyTemplates.redirection_template_index)
        else:
            return render(request,"login.html",{"mensaje":"Posibles causas del fallo:\n1- El usuario y/o la contraseña no coincide\n2-Su usuario ha sido desactivado por el administrador. Contacte con el administrador"})
        
    def create(self,request):
        from django.contrib.auth.models import User
        from django.contrib.auth import login
        from json import dumps
        try:
            name = request.POST["firstName"]
            last_name =request.POST["lastName"]
            correo = request.POST["email"]
            existe_usuario = Instalaciones.insertar(self,"SELECT EXISTE_USUARIO(%s)",(request.POST["username"],)) 
            existe_correo = Instalaciones.insertar(self,"SELECT EXISTE_CORREO(%s)",(request.POST["email"],))
            if not existe_correo[0]:
                if not existe_usuario[0]:
                    userAuth = User.objects.create_user(request.POST["username"],request.POST["email"],request.POST["pwd"],first_name=request.POST["firstName"],last_name=request.POST["lastName"])
                    #creo la sessión y guardo el nombre de usuario y nombre
                    request.session["usuario"] = request.POST["username"],request.POST["firstName"]
                    login(request,userAuth)
                    return HttpResponseRedirect(MyTemplates.redirection_template_index)
                else:
                    return render(request,"crear_usuario.html",{"usuario":"Este usuario ya existe en la base de datos. Elija otro usuario","nombre":name,"apellido":last_name,"correo":correo})
            else:
                return render(request,"crear_usuario.html",{"correo":"Este correo ya existe en la base de datos. Elija otro correo","nombre":name,"apellido":last_name})    
        except Exception as objExceptions:
            return HttpResponse("ERROR: "+str(objExceptions))

    def logoutSession(request):
        from django.contrib.auth import logout
        logout(request)
        return HttpResponseRedirect(MyTemplates.redirection_template_login)

    def eliminar_cuenta(request):
        Instalaciones.insertar(request,"CALL DECREMENTAR_RECERBAS_REALIZADAS_USUARIO(%s)",(request.user.username,))
        request.user.delete()
        request.session.flush()
        return HttpResponseRedirect("/api/login/")

    def update(request):
        #si la solicitud contiene una clave email
        if "email" in request.POST:
            correo = "No fue posible cambiar su dirección de correo. Vuelva a intentarlo más tarde"
            try:
                #cambio el email
                request.user.email = request.POST["email"]
                request.user.save()
                correo = "Se ha estabelcido el email "+request.POST["email"]+" satisfactoriamente"
            except:
                pass
            #renderizo la plantilla correspondiente a el cambio de correo
            return render(request,"correo_change.html",{"correo":correo})
        #si la solicitud contiene una clave passwordNew
        if "passwordNew" in request.POST:
            mensajePassword = "No se ha podido cambiar su contraseña.Vuelva a intentarlo más tarde"
            #Obtengo los datos de la vieja session
            if request.user.check_password(request.POST["passwordOld"]):
                from django.contrib.auth import update_session_auth_hash
                request.user.set_password(request.POST["passwordNew"])
                request.user.save()
                update_session_auth_hash(request,request.user)
                mensajePassword = "Se ha actualizado la contraseña correctamente"
            else:
                mensajePassword = "Su contraseña actual no se encuntra en la base de datos"
            return render(request,"password_change.html",{"respuesta":mensajePassword})
        
    def informacionDatosUsuario(request):
        return render(request,"informacion_usuario.html",
        {
            "nombre":request.user.first_name+" "+request.user.last_name,
            "usuario":request.user.username,
            "email":request.user.email,
            "fechaCreacion":request.user.date_joined
        }
        )
class Recerbas(ViewSet):
    def create(self,request): 
        try:
            deporte = request.POST["deporte"].lower()
            resp = ""
            #si la solicitud tiene una clve deporte y esa clave deporte es gym
            if deporte == "gym":
                from gloriaGym.api.models import Gym
                #import el modelo y obtengo los datos del objeto user. Lo mismo hago lo mismo en lo demas elif
                resp =  Gym.insertar(self,"SELECT INSERTAR_CLIENTE_GYM(%s,%s,%s,%s,%s,%s,%s)",(1,request.user.first_name,request.user.last_name,request.user.username,request.POST["deporte"],request.POST["fecha"],request.POST["hora"]))
            elif deporte == "pileta":
                from gloriaGym.api.models import Pileta
                resp =  Pileta.insertar(self,"SELECT INSERTAR_CLIENTE_PILETA(%s,%s,%s,%s,%s,%s,%s)",(1,request.user.first_name,request.user.last_name,request.user.username,request.POST["deporte"],request.POST["fecha"],request.POST["hora"]))
            elif deporte == "futbol":
                from gloriaGym.api.models import CanchasFutbol
                resp =  CanchasFutbol.insertar(self,"SELECT INSERTAR_CLIENTE_FUTBOL(%s,%s,%s,%s,%s,%s,%s)",(1,request.user.first_name,request.user.last_name,request.user.username,request.POST["deporte"],request.POST["fecha"],request.POST["hora"]))
            elif deporte == "paddle":
                from gloriaGym.api.models import CanchasPaddle
                resp =  CanchasPaddle.insertar(self,"SELECT INSERTAR_CLIENTE_PADDLE(%s,%s,%s,%s,%s,%s,%s)",(1,request.user.first_name,request.user.last_name,request.user.username,request.POST["deporte"],request.POST["fecha"],request.POST["hora"]))
            else:
                resp = "NO HAS SELECCIONADO UN DEPORTE. POR FAVOR SELECIONA UN DEPORTE".upper()
            #renderizo la plantilla con los datos enviados por la bd
            return render(request,"confirmacion_reserba.html",{"respuesta":resp[0]})
        except Exception as obj:
            return HttpResponse("ha ocurrido el siguiente error: "+str(obj))
    
    def formatearDatos(self,request,datos):
        datos_formateados = []
        for dato in datos:
            registro = []
            for tipoDato in dato:
                if isinstance(tipoDato,date):
                    registro.append(tipoDato.strftime("%d/%m/%Y"))
                else:
                    registro.append(tipoDato)
            datos_formateados.append(registro)
        return datos_formateados

    def retrieve(self,request):
        idCliente = GruposReserbas.eliminarRecerbaModels(self,request.GET["id"])
        return HttpResponse("Recerva eliminada")

    def list(self,request):
        from gloriaGym.api.models import GruposReserbas
        listaRecerbas = GruposReserbas.listar(self,request.user.username)
        listaRecerbas = self.formatearDatos(request,listaRecerbas)
        return render(request,"recerbas_hechas.html",{"recerbas":listaRecerbas})
class Correo(ViewSet):
    def update(self,request):
        mensaje = "El correo que proporcionaste no se encuentra en la base de datos"
        from json import dumps
        try:
            from django.contrib.auth import models
            from .models import Instalaciones
            #este try verifica que el correo este en la base de datos
            existe_correo = Instalaciones.insertar(self,"SELECT EXISTE_CORREO(%s)",(request.GET["correo"],))
            if existe_correo[0]:
                from django.contrib.auth.models import User
                obj_user = User.objects.get(email=request.GET["correo"])
                #Genero y almaceno la contraseña con e tipo de encriptación del backend
                new_password = request.GET["password"]+self.generar_salt(request,request.GET["password"])
                obj_user.set_password(new_password)
                obj_user.save()
                from django.core.mail import send_mail
                send_mesaage = send_mail('Cambio de contraseña',"Hemos reestrablecido su contraseña con exito\nSu nueva contraseña es: "+new_password,from_email="complejodeportivolagloria02020@gmail.com",recipient_list= [request.GET["correo"],]) 
                if send_mesaage:
                    return HttpResponse(dumps("Su contraseña se ha modificado con exito. La contraseña se ha enviado a su correo"))
            else:
                return HttpResponse(dumps(mensaje))
        except Exception as obj:
            return HttpResponse(dumps(mensaje))

    def generar_salt(self,request,password:str)->str:
        from random import randint
        salt = ""
        value_random_range = randint(1,len(password))
        for character in range(value_random_range):
            value_random = randint(0,len(password)-1)
            salt += password[value_random]
        return salt 