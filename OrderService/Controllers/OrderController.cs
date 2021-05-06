using System;
using System.Collections.Generic;
using System.Linq;
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
        private readonly ILogger<OrderController> _logger;

        public OrderController(ILogger<OrderController> logger)
        {
            _logger = logger;
        }

        //[Topic("pubsub", "submit")]
        //[HttpPost("submit")]
        [HttpPost()]
        public async Task<ActionResult<OrderResponse>> Post(List<Item> items, [FromServices] DaprClient daprClient)
        {
            _logger.LogDebug("Enter submit");

            // TODO: Process Order
            _logger.LogInformation($"Received an order with {items.Count} items.");

            // Send Confirmation Email
            await daprClient.InvokeBindingAsync<string>(
                "email", 
                "create", 
                "<h1>Order Confirmation</h1>Thank you for your order at e-Shop Dapr Demo.",
                new Dictionary<string, string>{
                    {"emailTo", "sascha.dittmann@microsoft.com"},
                    {"subject", "e-Shop Dapr Demo - Order Confimation"},
                });

            return new OrderResponse();
        }
    }
}