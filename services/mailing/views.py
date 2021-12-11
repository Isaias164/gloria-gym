from django.conf import settings
from django.http.response import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.viewsets import ViewSet
# Create your views here.
class S(ViewSet):
    def create(self,request):
        import os
        from sendgrid import SendGridAPIClient
        from sendgrid.helpers.mail import Mail

        message = Mail(
            from_email="sosaisaias250@gmail.com",
            to_emails="sosaisaias250@gmail.com",
            subject="Sending with Twilio SendGrid is Fun",
            html_content="<strong>and easy to do anywhere, even with Python</strong>",
        )
        try:
            sg = SendGridAPIClient(api_key=settings.SG_API_KEY)
            response = sg.send(message)
            print(response.status_code)
            print(response.body)
            print(response.headers)
            return HttpResponse("Correo enviado")
        except Exception as e:
            print(str(e))
        finally:
            return HttpResponse("llegue al finaly")
