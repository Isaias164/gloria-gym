# Generated by Django 3.1 on 2021-07-10 19:55

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0002_auto_20210625_1820'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='clientes',
            options={'verbose_name_plural': 'Clientes'},
        ),
        migrations.AlterModelOptions(
            name='gruposreserbas',
            options={'verbose_name_plural': 'Grupo de Recerbas'},
        ),
        migrations.AlterModelOptions(
            name='productos',
            options={'verbose_name_plural': 'Productos'},
        ),
        migrations.AlterModelOptions(
            name='productosvendidos',
            options={'verbose_name_plural': 'Productos Vendidos'},
        ),
        migrations.RemoveField(
            model_name='productosvendidos',
            name='empleado',
        ),
        migrations.AlterField(
            model_name='productosvendidos',
            name='cantVendida',
            field=models.IntegerField(default=0),
        ),
        migrations.AlterField(
            model_name='productosvendidos',
            name='fechaVenta',
            field=models.DateField(blank=True, null=True),
        ),
    ]
