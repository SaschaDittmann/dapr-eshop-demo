using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace CatalogService.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductsController : ControllerBase
    {
        private static readonly List<Product> ProductCatalog = new List<Product>();
        /*{
            new Product
            {
                Id = "p01",
                Name = "Name 1",
                Price = 5,
            },
            new Product
            {
                Id = "p02",
                Name = "Name 2",
                Price = 3,
            },
            new Product
            {
                Id = "p03",
                Name = "Name 3",
                Price = 10,
            }
        };*/

        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ILogger<ProductsController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<Product>> Get([FromServices] DaprClient daprClient)
        {
            var metadata = new Dictionary<string, string>();
            metadata.Add("sql", "SELECT * FROM products");
            await daprClient.InvokeBindingAsync<List<Product>>("catalogdb", "query", ProductCatalog, metadata);
            return ProductCatalog;
        }
        
        [HttpGet("{id}")]
        public Product Get(string id)
        {
            return ProductCatalog.SingleOrDefault(p => p.Id == id);
        }
    }
}
