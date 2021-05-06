using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using WebShop.Models;
using WebShop.Services;

namespace WebShop.Controllers
{
    public class CartController : Controller
    {
        /// <summary>
        /// State store name.
        /// </summary>
        private const string StoreName = "statestore";

        /// <summary>
        /// Pubsub component name for the orders queue.
        /// </summary>
        public const string PubsubName = "pubsub";

        private readonly ICatalogService _catalogService;
        private readonly ILogger<CartController> _logger;
        private readonly string _userId = "anonymous";

        public CartController(ILogger<CartController> logger, ICatalogService catalogService)
        {
            _logger = logger;
            _catalogService = catalogService;
        }

        public async Task<IActionResult> Index([FromServices] DaprClient daprClient)
        {
            var state = await daprClient.GetStateEntryAsync<List<Item>>(StoreName, _userId);
            ViewBag.cart = state.Value;
            ViewBag.total = state.Value.Sum(item => item.Product.Price * item.Quantity);
            return View();
        }

        public async Task<IActionResult> Buy(string id, [FromServices] DaprClient daprClient)
        {
            _logger.LogDebug("Enter Buy");
            var state = await daprClient.GetStateEntryAsync<List<Item>>(StoreName, _userId);
            if (state.Value == null)
            {
                state.Value = new List<Item>();
                state.Value.Add(new Item {Product = await _catalogService.GetProductById(id), Quantity = 1});
            }
            else
            {
                int index = state.Value.FindIndex(i => i.Product.Id == id);
                if (index != -1)
                    state.Value[index].Quantity++;
                else
                    state.Value.Add(new Item {Product = await _catalogService.GetProductById(id), Quantity = 1});
            }

            await state.SaveAsync();
            return RedirectToAction("Index");
        }

        public async Task<IActionResult> Remove(string id, [FromServices] DaprClient daprClient)
        {
            var state = await daprClient.GetStateEntryAsync<List<Item>>(StoreName, _userId);
            int index = state.Value.FindIndex(i => i.Product.Id == id);
            state.Value.RemoveAt(index);
            await state.SaveAsync();
            return RedirectToAction("Index");
        }

        public async Task<IActionResult> Checkout([FromServices] DaprClient daprClient)
        {
            _logger.LogDebug($"Enter Checkout");
            var state = await daprClient.GetStateEntryAsync<List<Item>>(StoreName, _userId);
            _logger.LogInformation($"Submitting Order with {state.Value.Count} items");
            await daprClient.PublishEventAsync<List<Item>>(
                PubsubName,
                "order",
                state.Value
            );
            /*
            var response = await daprClient.InvokeMethodAsync<List<Item>, dynamic>(
                "orderservice",
                "order",
                state.Value
            );
            */
            return RedirectToAction("Completed");
        }

        public IActionResult Completed()
        {
            return View();
        }
    }
}