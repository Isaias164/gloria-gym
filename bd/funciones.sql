DELIMITER //
CREATE FUNCTION OBTENER_DATOS_LOGGEO_USUARIO(NOMBRE_USUARIO VARCHAR(150)) RETURNS INT
	BEGIN
    	RETURN (SELECT auth_user.id FROM auth_user WHERE auth_user.username = NOMBRE_USUARIO);
    END
//

DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_GYM(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),NOMBRE_USUARIO CHAR(150),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(100)
	BEGIN
	#LA C SIGNIFICA CLIENTE
    DECLARE CONTADOR_R INT(2);#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    DECLARE PRECIO_GYM INT(5) DEFAULT (SELECT gym.precio FROM gym);
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'gym');
    DECLARE ID_DATOS_LOGGEO INT DEFAULT (SELECT OBTENER_DATOS_LOGGEO_USUARIO(NOMBRE_USUARIO));
    #EN EL CASO DEL GYM Y DE LA PILETA VA A DEVOLVER 0 O 1 PORQUE SOLO PUEDE HABER UN GRUPO DE RESERBAS PARA LA PILETA O EL GYM EN UNA HORA
    DECLARE BANDERA_G INT(1);
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserbas WHERE EXISTS(SELECT gruposreserbas.fecha,gruposreserbas.hora FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'gym'));
        
        #si es 0 significa que no hay ninguna reserba hecha ese dia y hora
        IF BANDERA_G = 0 THEN
            #CREO LA RESERBA
            INSERT INTO gruposreserbas SET gruposreserbas.hora = HORA_CLIENTE,gruposreserbas.fecha = FECHA_CLIENTE,gruposreserbas.contador = 1,gruposreserbas.deporte = 'gym';
            SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'gym');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_GYM,clientes.gym = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
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
                SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'gym');
                INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_GYM,clientes.gym = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
                #ACTUALIZO EL CONTADOR DE LA RESERBA
                UPDATE gruposreserbas
                SET gruposreserbas.contador = CONTADOR1 +1
                WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'gym';

                RETURN 'SU RESERBA PARA EL GIMNACIO FUE HECHA SATISFACTORIAMENTE';
            END IF;
		END IF;
    END
//

#FUNCION QUE TRATA EL PILETA
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_PILETA(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),NOMBRE_USUARIO CHAR(150),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(100)
	BEGIN
	DECLARE RESULTADO INT(5);
    DECLARE CONTADOR_R INT(2);#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    DECLARE PRECIO_PILETA INT(5) DEFAULT (SELECT pileta.precio FROM pileta);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'pileta');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    DECLARE ID_DATOS_LOGGEO INT DEFAULT (SELECT OBTENER_DATOS_LOGGEO_USUARIO(NOMBRE_USUARIO));
    
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
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_PILETA,clientes.pileta = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
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
                SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'pileta');
                INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = PRECIO_PILETA,clientes.pileta = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
                #ACTUALIZO EL CONTADOR DE LA RESERBA
                UPDATE gruposreserbas
                SET gruposreserbas.contador = CONTADOR1 +1
                WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'pileta';

                RETURN 'SU RESERBA PARA LA PILETA FUE HECHA SATISFACTORIAMENTE';
            END IF;
		END IF;
    END
//

#ESTA FUNCIÓN SE ENCARGA DE LA CANCHA DE FUTBOL
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_FUTBOL(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),NOMBRE_USUARIO CHAR(150),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(112)
	BEGIN
    #ALMACENO EL INCREMENTO SI PASA LAS 19HS
	DECLARE RESULTADO INT(5) DEFAULT (SELECT canchasfutbol.precio FROM canchasfutbol WHERE canchasfutbol.id = 1);
    DECLARE RESULTADO1 INT(5) DEFAULT (SELECT canchasfutbol.precio FROM canchasfutbol WHERE canchasfutbol.id = 2);
    #CONTADOR DE LA RESERBA. ESE CONTADOR ME VA A INDICAR LAS CANCHAS OCUPADAS
    DECLARE CONTADOR_R INT(2) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'fútbol');#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    #PRECIOS DE LAS CANCHAS
    DECLARE CANCHA_FUTBOL1 INT(5) DEFAULT (SELECT CanchasFutbol.precio FROM CanchasFutbol WHERE id = 1);
    DECLARE CANCHA_FUTBOL2 INT(5) DEFAULT (SELECT CanchasFutbol.precio FROM CanchasFutbol WHERE id = 2);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'fútbol');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    DECLARE ID_DATOS_LOGGEO INT DEFAULT (SELECT OBTENER_DATOS_LOGGEO_USUARIO(NOMBRE_USUARIO));
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserbas
WHERE EXISTS(SELECT gruposreserbas.fecha,gruposreserbas.hora FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'fútbol'));
        
        IF HORA_CLIENTE > 19 THEN
            IF CONTADOR_R = '' THEN
                SET RESULTADO = ((CANCHA_FUTBOL1 * 15) DIV 100) + CANCHA_FUTBOL1;
            ELSEIF CONTADOR_R = 1 THEN
                SET RESULTADO1 = ((CANCHA_FUTBOL2 * 15) DIV 100) + CANCHA_FUTBOL2;
            END IF;
        END IF;
        #si es 0 significa que no hay ninguna reserba hecha ese dia y hora Y QUE LAS 3 CANCHAS ESTAN DESOCUPADAS
        IF BANDERA_G = 0 THEN
            #CREO LA RESERBA
            INSERT INTO gruposreserbas SET gruposreserbas.hora = HORA_CLIENTE,gruposreserbas.fecha = FECHA_CLIENTE,gruposreserbas.contador = 1,gruposreserbas.deporte = 'fútbol';
            SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'fútbol');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.futbol = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
            RETURN 'SU RESERBA PARA LA CANCHA DE FUTBOL FUE HECHA SATISFACTORIAMENTE';
        #biene un 1 y significa quehay una reserba que no completa el cupo
        ELSE
            #verifico si todavia no se ha RESERBADO LAS 3 CANCHAS personas
            IF CONTADOR_R = 2 THEN
                RETURN 'NO ES POSIBLE REALIZAR LA RESERBA EN ESTE FECHA Y/U HORARIO PORQUE TODAS LAS CANCHAS DE FÚTBOL YA ESTAN OCUPADAS';
            #SI TODAVIA HAY CANCHAS
            #SI VENGO POR ACA LA CANCHA 1 YA ESTA OCUPADA, ME QUEDARIA PREGUNTAR POR LA 2 Y LA 3
            ELSE
                IF CONTADOR_R = '' THEN
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'fútbol');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.futbol = 1,clientes.datos_usuario = ID_DATOS_LOGGEO;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserbas
                    SET gruposreserbas.contador = CONTADOR1 +1
                    WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'fútbol';
                    RETURN 'SU RESERBA PARA LA CANCHA DE FUTBOL FUE HECHA SATISFACTORIAMENTE';
                ELSEIF CONTADOR_R = 1 THEN 
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'fútbol');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO1,clientes.futbol = 2,clientes.datos_usuario = ID_DATOS_LOGGEO;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserbas
                    SET gruposreserbas.contador = CONTADOR1 +1
                    WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'fútbol';
                    RETURN 'SU RESERBA PARA LA CANCHA DE FUTBOL FUE HECHA SATISFACTORIAMENTE';
                END IF;
            END IF;
		END IF;
    END
//

#ESTA FUNCIÓN SE ENCARGA DE LAS CANCHAS DE PADDLE
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_PADDLE(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),NOMBRE_USUARIO CHAR(150),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(120)
	BEGIN
    #ALMACENO EL INCREMENTO SI PASA LAS 19HS
	DECLARE RESULTADO INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 1);
    DECLARE RESULTADO1 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 2);
    DECLARE RESULTADO2 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 3);

    #CONTADOR DE LA RESERBA. ESE CONTADOR ME VA A INDICAR LAS CANCHAS OCUPADAS
    DECLARE CONTADOR_R INT(2) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'paddle');#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    #PRECIOS DE LAS CANCHAS
    DECLARE CANCHA_PADDLE1 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 1);
    DECLARE CANCHA_PADDLE2 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 2);
    DECLARE CANCHA_PADDLE3 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.id = 3);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas WHERE gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'paddle');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    DECLARE ID_LOGGEO_USUARIO INT DEFAULT (OBTENER_DATOS_LOGGEO_USUARIO(NOMBRE_USUARIO));
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserbas
WHERE EXISTS(SELECT gruposreserbas.fecha,gruposreserbas.hora FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'paddle'));
        
        IF HORA_CLIENTE > 19 THEN
            IF CONTADOR_R = '' THEN
                SET RESULTADO = ((CANCHA_PADDLE1 * 15) DIV 100) + CANCHA_PADDLE1;
            ELSEIF CONTADOR_R = 1 THEN
                SET RESULTADO = ((CANCHA_PADDLE2 * 15) DIV 100) + CANCHA_PADDLE2;
            ELSE
                SET RESULTADO = ((CANCHA_PADDLE3 * 15) DIV 100) + CANCHA_PADDLE3;
            END IF;
        END IF;
        #si es 0 significa que no hay ninguna reserba hecha ese dia y hora Y QUE LAS 3 CANCHAS ESTAN DESOCUPADAS
        IF BANDERA_G = 0 THEN
            #CREO LA RESERBA
            INSERT INTO gruposreserbas SET gruposreserbas.hora = HORA_CLIENTE,gruposreserbas.fecha = FECHA_CLIENTE,gruposreserbas.contador = 1,gruposreserbas.deporte = 'paddle';
            SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'paddle');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 1,clientes.datos_usuario = ID_LOGGEO_USUARIO;
            RETURN 'SU RESERBA PARA LA CANCHA DE PADDLE FUE HECHA SATISFACTORIAMENTE';
        #biene un 1 y significa quehay una reserba que no completa el cupo
        ELSE
            #verifico si todavia no se ha RESERBADO LAS 3 CANCHAS personas
            IF CONTADOR_R = 3 THEN
                RETURN 'NO ES POSIBLE REALIZAR LA RESERBA EN ESTA FECHA Y/U HORARIO PORQUE TODAS LAS CANCHAS DE PADDLE YA ESTAN OCUPADAS';
            #SI TODAVIA HAY CANCHAS
            #SI VENGO POR ACA LA CANCHA 1 YA ESTA OCUPADA, ME QUEDARIA PREGUNTAR POR LA 2 Y LA 3
            ELSE
                IF CONTADOR_R = 1 THEN
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'paddle');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 2,clientes.datos_usuario = ID_LOGGEO_USUARIO;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserbas
                    SET gruposreserbas.contador = CONTADOR1 +1
                    WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'paddle';
                    RETURN 'SU RESERBA PARA LA CANCHA DE PADDLE FUE HECHA SATISFACTORIAMENTE';
                ELSEIF CONTADOR_R = 2 THEN 
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT id FROM gruposreserbas WHERE gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.deporte = 'paddle');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 3,clientes.datos_usuario = ID_LOGGEO_USUARIO;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserbas
                    SET gruposreserbas.contador = CONTADOR1 +1
                    WHERE  gruposreserbas.hora = HORA_CLIENTE AND gruposreserbas.fecha = FECHA_CLIENTE AND gruposreserbas.deporte = 'paddle';
                    RETURN 'SU RESERBA PARA LA CANCHA DE PADDLE FUE HECHA SATISFACTORIAMENTE';
                END IF;
            END IF;
		END IF;
    END
   //


#BORRA EL CLIENTE
DELIMITER //
CREATE FUNCTION BORRAR_CLIENTE(ID_CLIENTE INT) RETURNS INT
	BEGIN
    	DECLARE ID_RECERBA INT DEFAULT (SELECT clientes.grupo FROM clientes WHERE clientes.id = ID_CLIENTE);
        CALL DECREMENTAR_RECERBAS(ID_RECERBA);
        DELETE FROM clientes WHERE clientes.id = ID_CLIENTE;
        RETURN 1;
    END
//

#vERIFICA SI EXISTE UN CORREO EN LA BD
DELIMITER //

CREATE FUNCTION EXISTE_CORREO(CORREO CHAR(60)) RETURNS INT
	BEGIN
    	DECLARE CANT_CORREO INT DEFAULT (SELECT COUNT(auth_user.email) FROM auth_user
                                        WHERE auth_user.email = LOWER(CORREO));
        RETURN CANT_CORREO;
    END
//

DELIMITER //

CREATE FUNCTION EXISTE_USUARIO(USUARIO CHAR(60)) RETURNS INT
	BEGIN
    	DECLARE CANT_USUARIO INT DEFAULT (SELECT COUNT(auth_user.username) FROM auth_user
                                        WHERE auth_user.username = LOWER(USUARIO));
        RETURN CANT_USUARIO;
    END
//


DELIMITER //
CREATE FUNCTION RECAUDADO_RESERBAS(FECHA_RECAUDADO DATE) RETURNS BIGINT(20)
    BEGIN
		DECLARE PRECIO_PILETA BIGINT(20) DEFAULT (SELECT SUM(pileta.precio) FROM clientes
JOIN pileta ON pileta.id = clientes.pileta
JOIN gruposreserbas ON gruposreserbas.id = clientes.grupo
WHERE gruposreserbas.fecha = FECHA_RECAUDADO);
        
        DECLARE PRECIO_GYM BIGINT(20) DEFAULT (SELECT SUM(gym.precio) FROM clientes JOIN gym ON gym.id = clientes.gym JOIN gruposreserbas ON gruposreserbas.id = clientes.grupo WHERE gruposreserbas.fecha = FECHA_RECAUDADO);
        
        DECLARE PRECIO_PADDLE BIGINT(20) DEFAULT (SELECT SUM(canchaspaddle.precio) FROM clientes
JOIN canchaspaddle ON canchaspaddle.id = clientes.paddle
JOIN gruposreserbas ON gruposreserbas.id = clientes.grupo
WHERE gruposreserbas.fecha = FECHA_RECAUDADO);

        DECLARE PRECIO_FUTBOL BIGINT(20) DEFAULT (SELECT SUM(canchasfutbol.precio) FROM clientes
JOIN canchasfutbol ON canchasfutbol.id = clientes.futbol
JOIN gruposreserbas ON gruposreserbas.id = clientes.grupo
WHERE gruposreserbas.fecha = FECHA_RECAUDADO);

	DECLARE TOTAL BIGINT(20) DEFAULT 0;

	IF PRECIO_PADDLE != 0  THEN
    	SET TOTAL = TOTAL + PRECIO_PADDLE;
    END IF;
    IF PRECIO_FUTBOL != 0 THEN
    	SET TOTAL = TOTAL + PRECIO_FUTBOL;
    END IF;
    IF PRECIO_PILETA != 0 THEN
    	SET TOTAL = TOTAL + PRECIO_PILETA;
    END IF;
    IF PRECIO_GYM != 0 THEN
    	SET TOTAL = TOTAL + PRECIO_GYM;
    END IF;
    
    RETURN TOTAL;
    END
//

DELIMITER //
CREATE FUNCTION DECREMENTAR_RECERBA(FECHA DATE,HORA INT(2),DEPORTE CHAR(15)) RETURNS BOOLEAN
	BEGIN
    	DECLARE CONTADOR_RECERBA INT(2) DEFAULT (SELECT gruposreserbas.contador FROM gruposreserbas 
                                   WHERE gruposreserbas.fecha = FECHA AND gruposreserbas.hora = HORA AND gruposreserbas.deporte = LOWER(DEPORTE));
    IF CONTADOR_RECERBA >= 1 THEN
    	UPDATE gruposreserbas
    	SET gruposreserbas.contador = CONTADOR_RECERBA - 1
    	WHERE gruposreserbas.fecha = FECHA AND gruposreserbas.hora = HORA AND gruposreserbas.deporte = LOWER(DEPORTE);
     END IF;
    RETURN TRUE;
    END
//
