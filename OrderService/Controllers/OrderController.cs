using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapr;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using OrderService.Models;

namespace OrderService.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class OrderController : ControllerBase
    {
        /// <summary>
        /// Pubsub component name for the orders queue.
        /// </summary>
        public const string PubsubName = "pubsub";

        private readonly ILogger<OrderController> _logger;

        public OrderController(ILogger<OrderController> logger)
        {
            _logger = logger;
        }

        [Topic(PubsubName, "order")]
        [HttpPost("order")]
        public async Task<ActionResult<OrderResponse>> Order(List<Item> items, [FromServices] DaprClient daprClient)
        {
            _logger.LogDebug("Enter Order");

            // TODO: Process Order
            _logger.LogInformation($"Received an order with {items.Count} items.");

            await SendEmail(items, daprClient);

            return new OrderResponse();
        }

        private async Task SendEmail(List<Item> items, DaprClient daprClient)
        {
            _logger.LogDebug("Retrieving Email Default Setting");
            var defaultEmailSettings = await daprClient.GetSecretAsync(
                "kubernetes", "email-default-settings");

            _logger.LogDebug("Building Email Content");
            var emailContent = new StringBuilder();
            emailContent.Append("<h1>Order Confirmation</h1>");
            emailContent.Append("e-Shop Dapr Demo - Order Confimation<br/>");

            emailContent.Append("<table cellpadding=\"2\" cellspacing=\"2\" border=\"1\">");
            emailContent.Append("<tr><th>Id</th><th>Name</th><th>Price</th><th>Quantity</th><th>Sub Total</th></tr>");
            foreach(var item in items) {
                emailContent.Append("<tr>");
                emailContent.Append($"<td>{item.Product.Id}</td>");
                emailContent.Append($"<td>{item.Product.Name}</td>");
                emailContent.Append($"<td>{item.Product.Price}</td>");
                emailContent.Append($"<td>{item.Quantity}</td>");
                emailContent.Append($"<td>{item.Product.Price * item.Quantity}</td>");
                emailContent.Append("</tr>");
            }
            emailContent.Append("<tr>");
            emailContent.Append("<td align=\"right\" colspan=\"4\">Sum</td>");
            emailContent.Append($"<td>{items.Sum(item => item.Product.Price * item.Quantity)}</td>");
            emailContent.Append("</tr></table>");

            _logger.LogDebug("Sending Confirmation Email");
            await daprClient.InvokeBindingAsync<string>(
                "email", 
                "create", 
                emailContent.ToString(),
                new Dictionary<string, string>{
                    {"emailTo", defaultEmailSettings["email-to"]},
                    {"subject", "Thank you for your order at e-Shop Dapr Demo"},
                });
        }
    }
}