#triplex
#123456Is@

#SELECT INSERTAR_CLIENTE_GYM(2,"pepito","aguirre","gym","2021-05-3","10:00") 
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_GYM(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(100)
	BEGIN
	#LA C SIGNIFICA CLIENTE
    DECLARE CONTADOR_R INT(2);#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    DECLARE PRECIO_GYM INT(5) DEFAULT (SELECT gym.precio FROM gym);
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'gym');
    #EN EL CASO DEL GYM Y DE LA PILETA VA A DEVOLVER 0 O 1 PORQUE SOLO PUEDE HABER UN GRUPO DE RESERBAS PARA LA PILETA O EL GYM EN UNA HORA
    DECLARE BANDERA_G INT(1);
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserbas WHERE EXISTS(SELECT gruposreserbas.fecha,gruposreserbas.hora FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'gym'));
        
        #si es 0 significa que no hay ninguna reserba hecha ese dia y hora
        IF BANDERA_G = 0 THEN
            #CREO LA RESERBA
            INSERT INTO gruposreserbas SET gruposreserbas.hora = HORA_CLIENTE,gruposreserbas.fecha = FECHA_CLIENTE,gruposreserbas.contador = 1,gruposreserbas.deporte = 'gym';
            SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'gym');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_GYM,clientes.gym = 1;
            RETURN 'SU RESERBA PARA EL GIMNACIO FUE HECHA SATISFACTORIAMENTE';
        #biene un 1 y significa quehay una reserba que no completa el cupo
        ELSE
            #verifico si todavia no se ha completado las 10 personas
            SET CONTADOR_R = (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'gym');
            #si ya hay 10 personas
            IF CONTADOR_R = 10 THEN
                RETURN 'NO ES POSIBLE REALIZAR LA RESERBA DEL GIMNACIO EN ESTE DIA Y/U HORARIO PORQUE YA NO HAY CUPO';
            #SI TODAVIA HAY CUPOS EN LA RESERVA
            ELSE
                SET ID_RESERBA = (SELECT id FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'gym');
                INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_GYM,clientes.gym = 1;
                #ACTUALIZO EL CONTADOR DE LA RESERBA
                UPDATE gruposreserba
                SET gruposreserba.contador = CONTADOR1 +1
                WHERE  gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'gym';

                RETURN 'SU RESERBA PARA EL GIMNACIO FUE HECHA SATISFACTORIAMENTE';
            END IF;
		END IF;
    END
//


#FUNCION QUE TRATA EL PILETA
#SELECT INSERTAR_CLIENTE_PILETA(2,"pepito","aguirre","gym","2021-05-3","10:00")
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_PILETA(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(100)
	BEGIN
	DECLARE RESULTADO INT(5);
    DECLARE CONTADOR_R INT(2);#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    DECLARE PRECIO_PILETA INT(5) DEFAULT (SELECT pileta.precio FROM pileta);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'pileta');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserbas
WHERE EXISTS(SELECT gruposreserbas.fecha,gruposreserbas.hora FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'pileta'));
        
        IF HORA_CLIENTE > 19 THEN
            SET RESULTADO = ((PRECIO_PILETA * 15) DIV 100) + PRECIO_PILETA;
            SET PRECIO_PILETA = RESULTADO;
        END IF;
        #si es 0 significa que no hay ninguna reserba hecha ese dia y hora
        IF BANDERA_G = 0 THEN
            #CREO LA RESERBA
            INSERT INTO gruposreserbas SET gruposreserbas.hora = HORA_CLIENTE,gruposreserbas.fecha = FECHA_CLIENTE,gruposreserbas.contador = 1,gruposreserbas.deporte = 'pileta';
            SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'pileta');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_PILETA,clientes.pileta = 1;
            RETURN 'SU RESERBA PARA LA PILETA FUE HECHA SATISFACTORIAMENTE';
        #biene un 1 y significa quehay una reserba que no completa el cupo
        ELSE
            #verifico si todavia no se ha completado las 10 personas
            SET CONTADOR_R = (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'pileta');
            #si ya hay 10 personas
            IF CONTADOR_R = 10 THEN
                RETURN 'NO ES POSIBLE REALIZAR LA RESERBA PARA LA PILETA EN ESTE DIA Y/U HORARIO PORQUE YA NO HAY CUPO';
            #SI TODAVIA HAY CUPOS EN LA RESERVA
            ELSE
                SET ID_RESERBA = (SELECT id FROM gruposreserba WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'pileta');
                INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_PILETA,clientes.pileta = 1;
                #ACTUALIZO EL CONTADOR DE LA RESERBA
                UPDATE gruposreserbas
                SET gruposreserbas.contador = CONTADOR1 +1
                WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'pileta';

                RETURN 'SU RESERBA PARA LA PILETA FUE HECHA SATISFACTORIAMENTE';
            END IF;
		END IF;
    END
//
