from django.urls import path
from . import views

a = views.S.as_view({"post": "create"})
urlpatterns = [path("mailing/", a)]

"""
DELIMITER //
create trigger actualizar_balance_amount after update on accounts_castoruser
	for each row
		begin
			
        end
//
"""
