using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Client;
using eshop.Models;
using eshop.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace eshop.Controllers
{
    public class CartController : Controller
    {
        private const string StoreName = "statestore";
        private readonly string _userId = "anonymous";
        private readonly ILogger<CartController> _logger;
        private readonly ICatalogService _catalogService;

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
                state.Value.Add(new Item { Product = _catalogService.GetProductById(id), Quantity = 1 }); 
            }
            else
            {
                int index = state.Value.FindIndex(i => i.Product.Id == id);
                if (index != -1)
                    state.Value[index].Quantity++;
                else
                    state.Value.Add(new Item { Product = _catalogService.GetProductById(id), Quantity = 1 });
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
    }
}
