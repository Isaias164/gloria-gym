# Generated by Django 3.1 on 2021-06-25 21:20

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('api', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='gruposreserbas',
            name='hora',
            field=models.IntegerField(),
        ),
    ]
