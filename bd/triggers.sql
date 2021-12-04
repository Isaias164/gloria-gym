#INSERTA UN PRODUCTO VENDIDO
DELIMITER //
CREATE TRIGGER INSERTAR_PRODUCTOS_VENDIDOS AFTER INSERT ON productos
	FOR EACH ROW
    	BEGIN
        	INSERT INTO productosvendidos
            SET productosvendidos.producto = NEW.ID;
        END

//


DELIMITER //
CREATE TRIGGER ACTUALIZAR_FECHA_ULTIMA_VENTA AFTER UPDATE ON productos
	FOR EACH ROW
    	BEGIN
        	UPDATE productosvendidos
            SET productosvendidos.cantVendida = productosvendidos.cantVendida +1,productosvendidos.fechaVenta = (SELECT NOW())
            WHERE productosvendidos.producto = OLD.ID;
END
