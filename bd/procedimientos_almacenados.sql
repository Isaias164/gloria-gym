#DECREMENTA LAS  RECERBAS
DELIMITER //
CREATE PROCEDURE DECREMENTAR_RECERBAS(ID_RECERBA INT)
	BEGIN
    	UPDATE gruposreserbas
        SET gruposreserbas.contador = gruposreserbas.contador -1
        WHERE gruposreserbas.id = ID_RECERBA;
    END
//

DELIMITER //
CREATE PROCEDURE DECREMENTAR_RECERBAS_REALIZADAS_USUARIO(USUARIO CHAR(80))
    BEGIN
        #OBTENGO EL ID DEL USUARIO QUE VOY A ELIMINAR
        DECLARE ID_USUARIO INT DEFAULT (SELECT auth_user.id FROM auth_user WHERE auth_user.username = USUARIO);
        #PARA OBTENER LOS GRUPOS RECERBAS A LOS QUE SE HA INSCRIPTO
        DECLARE GRUPO INT DEFAULT (SELECT COUNT(clientes.grupo) FROM clientes WHERE clientes.datos_usuario =ID_USUARIO);
        DECLARE ID_RECERBA INT DEFAULT (SELECT clientes.grupo FROM clientes 
                              WHERE clientes.datos_usuario= ID_USUARIO 
                              LIMIT 1);
        DECLARE FECHA DATE;
        DECLARE HORA INT;
        DECLARE DEPORTE CHAR(15);
        DECLARE RECERBA INT;
        WHILE GRUPO > 0 DO
        	SET FECHA = (SELECT gruposreserbas.fecha FROM gruposreserbas 
                        WHERE gruposreserbas.id = ID_RECERBA);
            SET HORA = (SELECT gruposreserbas.hora FROM gruposreserbas 
                        WHERE gruposreserbas.id = ID_RECERBA);
            SET DEPORTE = (SELECT gruposreserbas.deporte FROM gruposreserbas 
                            WHERE gruposreserbas.id = ID_RECERBA);
            SET RECERBA = (SELECT DECREMENTAR_RECERBA(FECHA,HORA,DEPORTE));
            SET GRUPO = GRUPO - 1 ;
            SET ID_RECERBA = (SELECT clientes.grupo FROM clientes
                                WHERE clientes.grupo > ID_RECERBA
                                LIMIT 1);
        END WHILE;
    END
//