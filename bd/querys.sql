CREATE DATABASE LA_GLORIA;
USE la_gloria;
ALTER DATABASE la_gloria charset=utf8;
#SET GLOBAL event_scheduler = 1;

#ESTE EVENTO ELIMINA LOS CLIENTES,LOS PRODUCTOS VENDIDOS Y LAS RESERBAS QUE SE HICIERON HACE UNA SEMANA
#DELIMITER //
#CREATE EVENT ELIMINACION_VCPV ON SCHEDULE EVERY 1 WEEK STARTS "2020-11-30 00:00:00" ON COMPLETION PRESERVE  DO
#	BEGIN
#	DELETE FROM gruposreserba WHERE gruposreserba.fecha < CURDATE();
#	DELETE FROM productosvendidos WHERE productosvendidos.fechaVenta < CURDATE();
#  END
#  //;

INSERT INTO loggingempleados 
SET loggingempleados.user1 = 'ISAIAS',loggingempleados.correo = 'sosaisaias250@gmail.com',loggingempleados.pasword = '12345678',loggingempleados.idLogEmpleado = 1;

INSERT INTO empleados
SET empleados.nombre = 'ISAIAS',empleados.apellido = 'SOSA',empleados.direccion = 'DIRECCIÓN 000', empleados.telefono = '3777586321',empleados.idEmpleado = 1;

#FUNCION QUE TRATA EL GIMNACIO


#ESTA FUNCIÓN SE ENCARGA DE LA CANCHA DE FUTBOL
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_FUTBOL(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(112)
	BEGIN
    #ALMACENO EL INCREMENTO SI PASA LAS 19HS
	DECLARE RESULTADO INT(5) DEFAULT (SELECT canchasfutbol.precio FROM canchasfutbol WHERE canchasfutbol.idfutbol = 1);
    DECLARE RESULTADO1 INT(5) DEFAULT (SELECT canchasfutbol.precio FROM canchasfutbol WHERE canchasfutbol.idfutbol = 2);
    #CONTADOR DE LA RESERBA. ESE CONTADOR ME VA A INDICAR LAS CANCHAS OCUPADAS
    DECLARE CONTADOR_R INT(2) DEFAULT (SELECT gruposreserba.contador FROM gruposreserba WHERE gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'fútbol');#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    #PRECIOS DE LAS CANCHAS
    DECLARE CANCHA_FUTBOL1 INT(5) DEFAULT (SELECT CanchasFutbol.precio FROM CanchasFutbol WHERE idfutbol = 1);
    DECLARE CANCHA_FUTBOL2 INT(5) DEFAULT (SELECT CanchasFutbol.precio FROM CanchasFutbol WHERE idfutbol = 2);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserba.contador FROM gruposreserba WHERE gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'fútbol');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserba
WHERE EXISTS(SELECT gruposreserba.fecha,gruposreserba.hora FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'fútbol'));
        
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
            INSERT INTO gruposreserba SET gruposreserba.hora = HORA_CLIENTE,gruposreserba.fecha = FECHA_CLIENTE,gruposreserba.contador = 1,gruposreserba.deporte = 'fútbol';
            SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'fútbol');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.futbol = 1;
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
                    SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'fútbol');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.futbol = 1;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserba
                    SET gruposreserba.contador = CONTADOR1 +1
                    WHERE  gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'fútbol';
                    RETURN 'SU RESERBA PARA LA CANCHA DE FUTBOL FUE HECHA SATISFACTORIAMENTE';
                ELSEIF CONTADOR_R = 1 THEN 
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'fútbol');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO1,clientes.futbol = 2;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserba
                    SET gruposreserba.contador = CONTADOR1 +1
                    WHERE  gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'fútbol';
                    RETURN 'SU RESERBA PARA LA CANCHA DE FUTBOL FUE HECHA SATISFACTORIAMENTE';
                END IF;
            END IF;
		END IF;
    END
    //

#ESTA FUNCIÓN SE ENCARGA DE LAS CANCHAS DE PADDLE
DELIMITER //
CREATE FUNCTION INSERTAR_CLIENTE_PADDLE(EMPLEADO INT (4),NOMBRE_CLIENTE CHAR(15),APELLIDO_CLIENTE CHAR(15),DEPORTE_CLIENTE CHAR(9),FECHA_CLIENTE DATE,HORA_CLIENTE INT(2)) RETURNS VARCHAR(120)
	BEGIN
    #ALMACENO EL INCREMENTO SI PASA LAS 19HS
	DECLARE RESULTADO INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 1);
    DECLARE RESULTADO1 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 2);
    DECLARE RESULTADO2 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 3);

    #CONTADOR DE LA RESERBA. ESE CONTADOR ME VA A INDICAR LAS CANCHAS OCUPADAS
    DECLARE CONTADOR_R INT(2) DEFAULT (SELECT gruposreserba.contador FROM gruposreserba WHERE gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'paddle');#LA R SIGNIFCA RESERBA
    DECLARE ID_RESERBA INT(9);
    #PRECIOS DE LAS CANCHAS
    DECLARE CANCHA_PADDLE1 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 1);
    DECLARE CANCHA_PADDLE2 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 2);
    DECLARE CANCHA_PADDLE3 INT(5) DEFAULT (SELECT canchaspaddle.precio FROM canchaspaddle WHERE canchaspaddle.idPaddle = 3);
    #POR DEFECTO LE GUARDO EL VALOR DEL CONTADOR DE LA RESERBA, SI ES QUE EXISTE
    DECLARE CONTADOR1 INT(5) DEFAULT (SELECT gruposreserba.contador FROM gruposreserba WHERE gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'paddle');
    #ALMACENA EL VALOR EN CASO DE QUE HALLA UNA RESERBA HECHA EN ESE DIA Y HORARIO
    DECLARE BANDERA_G INT(1);
    
    SET BANDERA_G = (SELECT COUNT(*) FROM gruposreserba
WHERE EXISTS(SELECT gruposreserba.fecha,gruposreserba.hora FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'paddle'));
        
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
            INSERT INTO gruposreserba SET gruposreserba.hora = HORA_CLIENTE,gruposreserba.fecha = FECHA_CLIENTE,gruposreserba.contador = 1,gruposreserba.deporte = 'paddle';
            SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'paddle');
            #INSERTO EL CLIENTE
            INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 1;
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
                    SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'paddle');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 2;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserba
                    SET gruposreserba.contador = CONTADOR1 +1
                    WHERE  gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'paddle';
                    RETURN 'SU RESERBA PARA LA CANCHA DE PADDLE FUE HECHA SATISFACTORIAMENTE';
                ELSEIF CONTADOR_R = 2 THEN 
                    #OBTENGO EL ID DE LA RESERBA PARA COLOCARLO EN EL CAMPO GRUPO DE LA ENTIDAD CLIENTE
                    SET ID_RESERBA = (SELECT idGrupo FROM gruposreserba WHERE gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.hora = HORA_CLIENTE AND gruposreserba.deporte = 'paddle');
                    INSERT INTO clientes SET clientes.empleado=EMPLEADO,clientes.nombre = NOMBRE_CLIENTE,clientes.apellido= APELLIDO_CLIENTE,clientes.grupo=ID_RESERBA,clientes.totalPagar = RESULTADO,clientes.paddle = 3;
                    #ACTUALIZO EL CONTADOR DE LA RESERBA
                    UPDATE gruposreserba
                    SET gruposreserba.contador = CONTADOR1 +1
                    WHERE  gruposreserba.hora = HORA_CLIENTE AND gruposreserba.fecha = FECHA_CLIENTE AND gruposreserba.deporte = 'paddle';
                    RETURN 'SU RESERBA PARA LA CANCHA DE PADDLE FUE HECHA SATISFACTORIAMENTE';
                END IF;
            END IF;
		END IF;
    END
    //

#ESTA FUNCION SE ENCARGA DE CREAR LOS DATOS PARA EL LOGEO Y EL EMPLEADO
DELIMITER //
CREATE FUNCTION CREAR_EMPLEADO(USUARIO CHAR(60),CORREO1 CHAR(30),PWD CHAR(60),NOMBRE1 CHAR(15),APELLIDO1 CHAR(15),DIRECCION1 CHAR(30),TELEFONO1 CHAR(15)) RETURNS VARCHAR(138)

	BEGIN
    DECLARE ID_LOGING INT(9);
    DECLARE USUARIO1 INT(9) DEFAULT (SELECT COUNT(*) FROM loggingempleados WHERE EXISTS(SELECT loggingempleados.user1 FROM loggingempleados WHERE loggingempleados.user1 = USUARIO AND loggingempleados.correo = CORREO1 AND loggingempleados.pasword = PWD));
    
    IF USUARIO1 = 0 THEN
        #SETEO LA VARIABLE PORQUE QUEDA LA CANTIDAD DE VECES QUE APARECE EL USUARIO
        SET USUARIO1 = USUARIO;
    	#CREO EL USUARIO
    	INSERT INTO loggingempleados SET loggingempleados.user1 = USUARIO,loggingempleados.correo = CORREO1, 			loggingempleados.pasword = PWD; 
        #OBTENGO LA ID PARA TERMINAR DE CREAR UN EMPLEADO CON UN LOGING
        SET ID_LOGING = (SELECT loggingempleados.idLogEmpleado FROM loggingempleados WHERE loggingempleados.user1 = USUARIO AND loggingempleados.correo = CORREO1 AND loggingempleados.pasword = PWD);
        #CREO EL EMPLEADO
        INSERT INTO empleados SET empleados.idEmpleado = ID_LOGING ,empleados.nombre = NOMBRE1,empleados.apellido = APELLIDO1, empleados.direccion = DIRECCION1, empleados.telefono = TELEFONO1;
        RETURN "EL USUARIO Y EL EMPLEADO SE HAN CREADO SATISFACTORIAMENTE";
    ELSE
    	RETURN "EL USUARIO,LA CONTRASEÑA Y EL CORREO QUE QUIERE UTILIZAR YA ESTA SIENDO UTILIZADO POR OTRO USUARIO.ELIJA OTRO USUARIO,CONTRASEÑA Y CORREO";
    END IF;
    END
    //

#verifica si hay productos en stock y si hay,se ihace una venta. Por cantidad se refiere a la cantidad que llevael cleinte de ese mismo producto
#DROP FUNCTION PRODUCTO_VENDIDO
DELIMITER //
CREATE FUNCTION PRODUCTO_VENDIDO(ID_EMPLEADO INT(2),CANTIDAD INT(2),NOMBREP CHAR(20),PRECIOP DOUBLE(4,2),PRECIOTOTALP INT(9)) RETURNS VARCHAR(40)
	BEGIN
    	DECLARE HAY_PRODUCTO INT(5) DEFAULT (SELECT productos.cantidad FROM productos WHERE productos.nombre = NOMBREP AND productos.precioUnidad = PRECIOP);
        DECLARE ID_PRODUCTO INT(9);
        
        IF HAY_PRODUCTO = 0  THEN
        	RETURN "NO QUEDAN MÁS PRODUCTOS EN STOCK";
        ELSE
        	IF HAY_PRODUCTO > CANTIDAD THEN
            #SI TODAVIA QUEDA EL PRODUCTO EN STOCK, OBTENGO SU ID
        	SET ID_PRODUCTO = (SELECT productos.idProducto FROM productos WHERE productos.nombre = NOMBREP AND productos.precioUnidad = PRECIOP);
        	INSERT INTO productosvendidos SET productosvendidos.cantidadVendida = CANTIDAD,productosvendidos.produc = ID_PRODUCTO,productosvendidos.empleado = ID_EMPLEADO,productosvendidos.fechaVenta = CURDATE();
            
            UPDATE productos
			SET productos.cantidad = HAY_PRODUCTO - CANTIDAD
			WHERE  productos.idProducto = ID_PRODUCTO;
            RETURN "OPERACIÓN SATISFACTORIA";
       		ELSE
       			RETURN CONCAT("SOLO QUEDA ",HAY_PRODUCTO," ",NOMBREP);
       		END IF;
        END IF;
    END
    //;

DELIMITER // 
CREATE FUNCTION INSERTAR_PRODUCTO(NOMBREP CHAR(20),CANTIDADP INT(4),PRECIOP FLOAT(4,2),PRECIOTOTALP INT(9)) RETURNS CHAR(100)
    BEGIN
    DECLARE EXISTE_PRODUCTO INT(1) DEFAULT (SELECT COUNT(*) FROM productos WHERE productos.nombre = NOMBREP);
    
    IF EXISTE_PRODUCTO = 1 THEN
    RETURN "NO ES POSIBLE INSERTAR ESTE PRODCTO PORQUE EL MISMO YA EXISTE EN LA BASE DE DATOS";
    ELSE
    INSERT INTO productos
    SET  productos.nombre = NOMBREP,productos.cantidad = CANTIDADP, productos.precioUnidad = PRECIOP,productos.precioTotal = PRECIOTOTALP;
    RETURN CONCAT("EL PRODUCTO ",NOMBREP," FUE INSERTADO CORRECTAMENTE"); 
    END IF;  
    END
//


#OBTIENE LA CANTIDAD RECAUDADA DE TODAS LAS CANCHAS
DELIMITER //

CREATE FUNCTION RECAUDADO_RESERBAS(FECHA_RECAUDADO DATE) RETURNS BIGINT(20)
    BEGIN
		DECLARE PRECIO_PILETA BIGINT(20) DEFAULT (SELECT SUM(pileta.precio) FROM clientes
JOIN pileta ON pileta.idPileta = clientes.pileta
JOIN gruposreserba ON gruposreserba.idGrupo = clientes.grupo
WHERE gruposreserba.fecha = FECHA_RECAUDADO);
        
        DECLARE PRECIO_GYM BIGINT(20) DEFAULT (SELECT SUM(gym.precio) FROM clientes JOIN gym ON gym.idGym = clientes.gym JOIN gruposreserba ON gruposreserba.idGrupo = clientes.grupo WHERE gruposreserba.fecha = FECHA_RECAUDADO);
        
        DECLARE PRECIO_PADDLE BIGINT(20) DEFAULT (SELECT SUM(canchaspaddle.precio) FROM clientes
JOIN canchaspaddle ON canchaspaddle.idPaddle = clientes.paddle
JOIN gruposreserba ON gruposreserba.idGrupo = clientes.grupo
WHERE gruposreserba.fecha = FECHA_RECAUDADO);

        DECLARE PRECIO_FUTBOL BIGINT(20) DEFAULT (SELECT SUM(canchasfutbol.precio) FROM clientes
JOIN canchasfutbol ON canchasfutbol.idfutbol = clientes.futbol
JOIN gruposreserba ON gruposreserba.idGrupo = clientes.grupo
WHERE gruposreserba.fecha = FECHA_RECAUDADO);

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

#CORREO DE RECUPERACIÓN
DELIMITER //
CREATE FUNCTION CUENTA_RECUPERACION(CORREO_USUARIO CHAR(40),NUEVO_PASSWORD CHAR(64)) RETURNS INT(1)
	BEGIN
    DECLARE CORREO INT(9) DEFAULT (SELECT loggingempleados.idLogEmpleado FROM loggingempleados WHERE loggingempleados.correo = CORREO_USUARIO);
    IF CORREO != 0 THEN
    	UPDATE loggingempleados
        SET loggingempleados.pasword = NUEVO_PASSWORD
        WHERE loggingempleados.correo = CORREO_USUARIO;
        RETURN 0;
        #RETURN "LE HEMOS ENVIADO LA NUEVA CONTRASEÑA A SU CORREO";
    ELSE
    	#RETURN "NO ES POSIBLE ENVIAR LA CONTRASEÑA A SU CORREO PORQUE SU CORREO NO SE ENCUENTRA EN NUESTRA BASE DE DATOS";
        RETURN 1;
    END IF;
    END
    //