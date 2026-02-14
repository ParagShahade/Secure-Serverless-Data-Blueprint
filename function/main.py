import functions_framework
from webhook import receive_order as webhook_impl
from processor import process_order_pubsub as processor_impl

@functions_framework.http
def receive_order(request):
    """Entry point for the Webhook Receiver."""
    return webhook_impl(request)

@functions_framework.http
def process_order_pubsub(request):
    """Entry point for the Order Processor (v2 HTTP/Push)."""
    return processor_impl(request, None)
