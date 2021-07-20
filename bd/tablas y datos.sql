CREATE DATABASE LA_GLORIA;
USE la_gloria;
ALTER DATABASE la_gloria charset=utf8;
#SET GLOBAL event_scheduler = 1;

CREATE OR REPLACE VIEW  lista_recerbas_usuario AS 
SELECT auth_user.username,gruposreserbas.deporte,gruposreserbas.fecha,gruposreserbas.hora,clientes.totalPagar FROM clientes
JOIN auth_user ON clientes.datos_usuario = auth_user.id
JOIN gruposreserbas ON  clientes.grupo=gruposreserbas.id
ORDER BY gruposreserbas.fecha,gruposreserbas.hora

INSERT INTO gym
SET gym.precio = 700,gym.cantidadUsuarios = 10;

INSERT INTO pileta
SET pileta.precio = 700,pileta.cantidadUsuarios = 10

INSERT INTO canchasfutbol
SET canchasfutbol.precio = 800,canchasfutbol.cantidadUsuarios = 30
INSERT INTO canchasfutbol
SET canchasfutbol.precio = 800,canchasfutbol.cantidadUsuarios = 30

INSERT INTO canchaspaddle
SET canchaspaddle.precio = 800,canchaspaddle.cantidadUsuarios = 2
INSERT INTO canchaspaddle
SET canchaspaddle.precio = 800,canchaspaddle.cantidadUsuarios = 2
INSERT INTO canchaspaddle
SET canchaspaddle.precio = 800,canchaspaddle.cantidadUsuarios = 2