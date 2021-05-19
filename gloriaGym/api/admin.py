from django.contrib import admin
from .models import Productos,ProductosVendidos,Clientes,CanchasFutbol,CanchasPaddle,Pileta,Gym,GruposReserbas

#@admin.register(Productos)
class ProductosAdmin(admin.ModelAdmin):
    pass
#@admin.register(ProductosVendidos)
class ProductosVendidosAdmin(admin.ModelAdmin):
    pass

#@admin.register(Clientes)
class ClientesAdmin(admin.ModelAdmin):
    pass

#@admin.register(CanchasFutbol)
class CanchasFutbolAdmin(admin.ModelAdmin):
    pass

#@admin.register(CanchasPaddle)
class CanchasPaddleAdmin(admin.ModelAdmin):
    pass

#@admin.register(GruposReserbas)
class GruposReserbasAdmin(admin.ModelAdmin):
    pass

#@admin.register(Pileta)
class PiletaAdmin(admin.ModelAdmin):
    pass

#@admin.register(Clientes)
class GymAdmin(admin.ModelAdmin):
    pass

admin.site.register(Productos,ProductosAdmin)
admin.site.register(ProductosVendidos,ProductosVendidosAdmin)
admin.site.register(Clientes,ClientesAdmin)
admin.site.register(Pileta,PiletaAdmin)
admin.site.register(Gym,GymAdmin)
admin.site.register(CanchasPaddle,CanchasPaddleAdmin)
admin.site.register(CanchasFutbol,CanchasFutbolAdmin)
admin.site.register(GruposReserbas,GruposReserbasAdmin)