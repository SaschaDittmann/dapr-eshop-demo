using System.Collections.Generic;
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

            _logger.LogDebug("Retrieving Secrets");
            var defaultEmailSettings = await daprClient.GetSecretAsync(
                "kubernetes", "email-default-settings");

            _logger.LogDebug("Sending Confirmation Email");
            await daprClient.InvokeBindingAsync<string>(
                "email", 
                "create", 
                "<h1>Order Confirmation</h1>Thank you for your order at e-Shop Dapr Demo.",
                new Dictionary<string, string>{
                    {"emailTo", defaultEmailSettings["email-to"]},
                    {"subject", "e-Shop Dapr Demo - Order Confimation"},
                });

            return new OrderResponse();
        }
    }
}