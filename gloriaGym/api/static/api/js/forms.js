
    //logging
    $("#button").click(function () { 
        let datos;
        if ($("#recordar").val() === "off" ) {
            datos = {"user":$("#user").val(),"pwd":$("#pwd").val()}
        } else {
            datos = {"user":$("#user").val(),"pwd":$("#pwd").val(),"recordar1":true}
        }
        $.ajax({
            type: $("form").attr("method"),
            url: $("form").attr("action"),
            dataType:"json",
            data: datos
        }); 
    });

    //create users
    $("#recovery").click(function () { 
        datos = [$("#fn").val(),("#ln").val(),$("#email").val(),$("#user").val(),$("#pwd").val()]
        id_objetos = ["#fn","#ln","#email","#user","#pwd"]
        $.ajax({
            type: $("form").attr("method"),
            url: $("form").attr("action"),
            data: {"firstName":$("#fn").val(),"lastName":$("#ln").val(),"email":$("#email").val(),"username":$("#user").val(),"pwd":$("#pwd").val()},
        }); 
    });
    //udate password users
    $("#pass").click(function () { 
        if ($("#password2").val() === $("#password3").val()){
            $.ajax({
                type: $("#password").attr("method"),
                url: $("#password").attr("action"),
                dataType: "json",
                data: {"passwordOld":$("#password1").val(),"passwordNew":$("#password2").val(),"csrfmiddlewaretoken":csrf_token}
            });
        }
        else alert("Las contraseñas no son iguales.Verifique que las contraseñas se han las mismas");
        
    });

    $("#email").click(function () { 
        $.ajax({
            type: $("#email").attr("method"),
            url: $("#email").attr("action"),
            data: JSON.stringify({"email":$("#newEmail").val(),"csrfmiddlewaretoken":csrf_token})
        });
    });

    //reserbas
    $("#botonEnviar").on("click", function () {
            $("form").css("display","none");
        const deporte1 = localStorage.getItem("deporte");
        $("#deporte").attr("value", deporte1);
        var h = $("#hora").val();
        localStorage.removeItem('deporte');
        $.ajax({
            type: $("#formInscrip").attr("method"),
            url: $("#formInscrip").attr("action"),
            dataType: "json",
            data:JSON.stringify({nombre:$("#nombre").val(),
                                apellido:$("#apellido").val(),
                                deporte:$("#deporte").val(),
                                fecha:$("#fecha").val(),
                                hora:parseInt(h,10),
                                "csrfmiddlewaretoken":csrf_token})
        }).
            done(function(datos) {
                alert(datos);
                var cadena = datos.mensaje;
                var palabra = "SU";
                var posiscion = cadena.indexOf(palabra);
                if(posiscion !== -1){
                    $("#divServidor").css("display","block");
                    $("#pServidor").text(datos.mensaje);
                }
                else{
                    $("#divServidor").css("display","block");
                    $("#divServidor").css("background-color","red");
                    $("#pServidor").text(datos.mensaje);
                    $("#cara").attr("src","/static/api/img/cara triste.png");
                
                }
            }).
            fail(function (xhr, textStatus, error) {
                alert("algo salio mal");
                alert(xhr);
                alert(textStatus);
                alert(error);
            });
        });

    //eliminar recerba
    $(".botonCancelarRecerba").click(function () { 
        var valores = [];
        var idFila = 0
        $(this).parents("tr").find("td").each(function(){
            valores.push($(this).html());
        });
        idFila = valores[0];
        $(this).closest('tr').remove();
        $.ajax({
            type: "get",
            url: "/api/eliminar/recerba/",
            data: {"id":idFila}
        });
    });

    $("#recuperar_contrasena").click(function (event) { 
        email_user = $(".email1").val();
        pass_user = $(".password1").val();
        $.ajax({
            type: $("#form_recu_contra").attr("method"),
            url: $("#form_recu_contra").attr("action"),
            data:{"correo":email_user,"password":pass_user}//,"csrfmiddlewaretoken":csrf_token} {"correo":"sosa@gmail.com","password":"12345678"}
        }).done(function (respond){
            alert(JSON.parse(respond));
            $(location).attr('href',"/api/login/");
        });
        return false;
    }); 

$("#eliminar_cuenta").click(function () { 
    $.ajax({
        type: "GET",
        url: "/api/eliminar/cuenta/",
    });
});