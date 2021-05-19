#from django import db
from django.db import models

class Productos(models.Model):
    nombre = models.CharField(max_length=50)
    cantidad = models.IntegerField()
    precioUnidad = models.DecimalField(max_digits=5,decimal_places=2)
    
    class Meta:
        db_table = "Productos"

class ProductosVendidos(models.Model):
    cantVendida = models.IntegerField()
    fechaVenta = models.DateField()
    producto= models.ForeignKey(Productos,db_column="producto",on_delete=models.CASCADE)
    empleado = models.ForeignKey('auth.User',db_column="empleado",on_delete=models.SET_NULL,null=True)
    
    class Meta:
        db_table = "ProductosVendidos"

class Instalaciones(models.Model):
    precio = models.IntegerField()
    cantidadUsuarios = models.IntegerField(blank=True,null=True)

    class Meta:
        abstract = True

class Gym(Instalaciones):
    class Meta:
        db_table = "Gym"

class Pileta(Instalaciones):
    class Meta:
        db_table = "Pileta"

class CanchasFutbol(Instalaciones):
    class Meta:
        db_table = "CanchasFutbol"

class CanchasPaddle(Instalaciones):
    class Meta:
        db_table = "CanchasPaddle"

class GruposReserbas(models.Model):
    hora= models.TimeField()
    fecha=models.DateField()
    deporte = models.CharField(max_length=15)
    contador = models.IntegerField()

    class Meta:
        db_table = "GruposReserbas"

class Clientes(models.Model):
    nombre = models.CharField(max_length=20)
    apellido = models.CharField(max_length=20)
    formaPago = models.CharField(max_length=10,default="Efectivo")
    totalPagar = models.IntegerField()
    empleado = models.ForeignKey('auth.User',db_column='empleado',on_delete=models.CASCADE)
    futbol = models.ForeignKey(CanchasFutbol,db_column='futbol',on_delete=models.SET_NULL,null=True)
    paddle = models.ForeignKey(CanchasPaddle,db_column='paddle',on_delete=models.SET_NULL,null=True)
    gym = models.ForeignKey(Gym,db_column='gym',on_delete=models.SET_NULL,null=True)
    pileta = models.ForeignKey(Pileta,db_column='pileta',on_delete=models.SET_NULL,null=True)
    grupo = models.ForeignKey(GruposReserbas,db_column='grupo',on_delete=models.CASCADE,null=True)

    class Meta:
        db_table = "Clientes"
