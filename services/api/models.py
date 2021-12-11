from django.db import models


class Productos(models.Model):
    nombre = models.CharField(max_length=50)
    cantidad = models.IntegerField()
    precioUnidad = models.DecimalField(max_digits=5, decimal_places=2)
    precioTotal = models.IntegerField()

    def __str__(self) -> str:
        return str(self.nombre)

    class Meta:
        db_table = "productos"
        verbose_name_plural = "Productos"


class ProductosVendidos(models.Model):
    cantVendida = models.IntegerField(default=0)
    fechaVenta = models.DateField(null=True, blank=True)
    producto = models.ForeignKey(
        Productos, db_column="producto", on_delete=models.CASCADE
    )
    # empleado = models.ForeignKey('auth.User',db_column="empleado",on_delete=models.SET_NULL,null=True)
    class Meta:
        db_table = "productosvendidos"
        verbose_name_plural = "Productos Vendidos"


class Instalaciones(models.Model):
    precio = models.IntegerField()
    cantidadUsuarios = models.IntegerField(blank=True, null=True)

    def insertar(self, query, params):
        from django.db import connection

        resp = ""
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            resp = cursor.fetchone()
        return resp

    def __str__(self) -> str:
        return "Gimnacio " + str(self.id)

    class Meta:
        abstract = True


class Gym(Instalaciones):
    class Meta:
        db_table = "gym"


class Pileta(Instalaciones):
    def __str__(self) -> str:
        return "Pileta " + str(self.id)

    class Meta:
        db_table = "pileta"


class CanchasFutbol(Instalaciones):
    def __str__(self) -> str:
        return "Cancha de fútbol " + str(self.id)

    class Meta:
        db_table = "canchasfutbol"


class CanchasPaddle(Instalaciones):
    def __str__(self) -> str:
        return "Cancha de paddle " + str(self.id)

    class Meta:
        db_table = "canchaspaddle"


class GruposReserbas(models.Model):
    hora = models.IntegerField()
    fecha = models.DateField()
    deporte = models.CharField(max_length=15)
    contador = models.IntegerField()

    def __str__(self) -> str:
        return str(self.fecha) + " hora:" + str(self.hora)

    def listar(self, params1):
        from django.db import connection

        query = "SELECT * FROM lista_recerbas_usuario WHERE username = %s;"
        resp = ""
        with connection.cursor() as cursor:
            try:
                cursor.execute(query, (params1,))
                resp = cursor.fetchall()
            except Exception as objStr:
                resp = str(objStr)
        return resp

    def eliminarRecerbaModels(self, id):
        from django.db import connection

        query = "SELECT BORRAR_CLIENTE(%s);"
        resp = ""
        with connection.cursor() as cursor:
            try:
                cursor.execute(query, (id,))
                resp = cursor.fetchone()
            except Exception as objStr:
                resp = str(objStr)
        return resp

    class Meta:
        db_table = "gruposreserbas"
        ordering = ["fecha"]
        verbose_name_plural = "Grupo de Recerbas"


class Clientes(models.Model):
    nombre = models.CharField(max_length=20)
    apellido = models.CharField(max_length=20)
    pagoAbonado = models.CharField(max_length=2, default="No")
    totalPagar = models.IntegerField()
    empleado = models.ForeignKey(
        "auth.User", db_column="empleado", on_delete=models.CASCADE
    )
    futbol = models.ForeignKey(
        CanchasFutbol,
        db_column="futbol",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    paddle = models.ForeignKey(
        CanchasPaddle,
        db_column="paddle",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
    )
    gym = models.ForeignKey(
        Gym, db_column="gym", on_delete=models.SET_NULL, null=True, blank=True
    )
    pileta = models.ForeignKey(
        Pileta, db_column="pileta", on_delete=models.SET_NULL, null=True, blank=True
    )
    grupo = models.ForeignKey(
        GruposReserbas, db_column="grupo", on_delete=models.CASCADE, null=True
    )
    datos_usuario = models.ForeignKey(
        "auth.user",
        on_delete=models.CASCADE,
        db_column="datos_usuario",
        related_name="datos_usuario",
    )

    class Meta:
        db_table = "clientes"
        verbose_name_plural = "Clientes"
