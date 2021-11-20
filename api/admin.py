from django.contrib import admin
from .models import Productos,ProductosVendidos,Clientes,CanchasFutbol,CanchasPaddle,Pileta,Gym,GruposReserbas


def vender_producto(modeladmin, request, queryset):
    for objects_queryset in queryset:
        if not objects_queryset.cantidad == 0:
            queryset.filter(id=objects_queryset.id).update(cantidad=objects_queryset.cantidad - 1)
    vender_producto.short_description = 'Vender productos'

def cantidad_recaudada_recerbas(modeladmin,request,queryset):
    from django.shortcuts import render
    from .models import Instalaciones
    from datetime import datetime
    #en caso de que no ingrese nada 
    #fecha_actual = fecha = datetime.now().strftime("%d/%m/%Y")
    cantidad_recaudada = Instalaciones.insertar(request,"SELECT RECAUDADO_RESERBAS(%s)",(queryset[0].fecha,))
    cantidad_recaudada_recerbas.short_description = "Monto de las reerbas realizadas"
    #return HttpResponseRedirect("/api/cantidad/recaudada/recerbas")
    return render(request,"cantidad_recaudada_recerbas.html",{"fecha":queryset[0].fecha,"monto":cantidad_recaudada[0]})

class ProductosAdmin(admin.ModelAdmin):
    list_display = ("id","nombre","cantidad","precioUnidad","precioTotal")
    list_filter = ("nombre","cantidad","precioUnidad","precioTotal")
    actions = [vender_producto]
class ProductosVendidosAdmin(admin.ModelAdmin):
    list_display =  ("id","cantVendida","fechaVenta","producto")
class Instalaciones(admin.ModelAdmin):
    list_display = ("id","precio","cantidadUsuarios")
class CanchasFutbolAdmin(Instalaciones):
    pass
class CanchasPaddleAdmin(Instalaciones):
    pass
class PiletaAdmin(Instalaciones):
    pass
class GymAdmin(Instalaciones):
    pass
class GruposReserbasAdmin(admin.ModelAdmin):
    list_display =  ("id","fecha","hora","deporte","contador")
    search_fields = ["fecha","hora","deporte"]
    actions = [cantidad_recaudada_recerbas]
class ClientesAdmin(admin.ModelAdmin):
    list_display = ("nombre","apellido","pagoAbonado","totalPagar","empleado","futbol","paddle","gym","pileta","grupo","datos_usuario")
    search_fields = ["nombre","apellido","pagoAbonado"]


admin.site.register(Productos,ProductosAdmin)
admin.site.register(ProductosVendidos,ProductosVendidosAdmin)
admin.site.register(Clientes,ClientesAdmin)
admin.site.register(Pileta,PiletaAdmin)
admin.site.register(Gym,GymAdmin)
admin.site.register(CanchasPaddle,CanchasPaddleAdmin)
admin.site.register(CanchasFutbol,CanchasFutbolAdmin)
admin.site.register(GruposReserbas,GruposReserbasAdmin)