using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using System.Linq;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using CatalogService.Models;

namespace CatalogService.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductsController : ControllerBase
    {
        private static readonly List<Product> ProductCatalog = new List<Product>();
        private const string ProductCountCmd = "SELECT COUNT(*) AS Count FROM products;";
        private const string GetProductsCmd = "SELECT * FROM products;";
        private const string GetProductByIdCmd = "SELECT * FROM products WHERE id='{0}';";
        private const string CreateTableCmd = "CREATE TABLE IF NOT EXISTS products (id varchar(50) PRIMARY KEY,name varchar(255) NULL,price decimal  NULL, photo varchar(255)  NULL);";
        private const string InsertProductCmd = "INSERT INTO products(id,name,price,photo) VALUES('{0}','{1}',{2},'{3}');";
        
        private readonly ILogger<ProductsController> _logger;

        public ProductsController(ILogger<ProductsController> logger)
        {
            _logger = logger;
        }

        [HttpGet]
        public async Task<IEnumerable<Product>> Get([FromServices] DaprClient daprClient)
        {
            if (ProductCatalog.Count == 0)
                await SetupDatabase(daprClient);

            _logger.LogInformation("Get all Products");
            var products = await daprClient.InvokeBindingAsync<String, List<Product>>(
                "catalogdb", 
                "query", 
                String.Empty, 
                new Dictionary<string, string>
                {
                    {"sql", GetProductsCmd}
                });
            _logger.LogInformation($"Retrieved {products.Count} Products");
            return products;
        }
        
        [HttpGet("{id}")]
        public async Task<Product> Get(string id, [FromServices] DaprClient daprClient)
        {
            if (ProductCatalog.Count == 0)
                await SetupDatabase(daprClient);

            _logger.LogInformation($"Get Products By Id ({id})");
            var productResponse = await daprClient.InvokeBindingAsync<String, List<Product>>(
                "catalogdb", 
                "query", 
                String.Empty, 
                new Dictionary<string, string>
                {
                    {"sql", String.Format(GetProductByIdCmd, id)}
                });
            return productResponse.FirstOrDefault();
        }

        private async Task SetupDatabase(DaprClient daprClient)
        {
            try
            {
                _logger.LogInformation("Creating Product Table...");
                await daprClient.InvokeBindingAsync(
                    "catalogdb",
                    "exec",
                    String.Empty,
                    new Dictionary<string, string>{{"sql", CreateTableCmd}});

                _logger.LogInformation("Checking for existing products...");
                var productCountResponse = await daprClient.InvokeBindingAsync<String, List<ProductCount>>(
                    "catalogdb", 
                    "query", 
                    String.Empty, 
                    new Dictionary<string, string>
                    {
                        {"sql", ProductCountCmd}
                    });
                if (productCountResponse.Count == 0 || productCountResponse[0].Count == 0)
                {
                    _logger.LogInformation("Inserting products...");
                    await daprClient.InvokeBindingAsync(
                        "catalogdb",
                        "exec",
                        String.Empty,
                        new Dictionary<string, string>
                        {

                            {
                                "sql", String.Format(InsertProductCmd, 
                                    "p01", "This Awesome Car", 2.5, "img/p01.jpg"
                                )
                            }
                        });
                    await daprClient.InvokeBindingAsync(
                        "catalogdb",
                        "exec",
                        String.Empty,
                        new Dictionary<string, string>
                        {

                            {
                                "sql", String.Format(InsertProductCmd, 
                                    "p02", "A Great Headset", 10, "img/p02.jpg"
                                )
                            }
                        });
                    await daprClient.InvokeBindingAsync(
                        "catalogdb",
                        "exec",
                        String.Empty,
                        new Dictionary<string, string>
                        {

                            {
                                "sql", String.Format(InsertProductCmd, 
                                    "p03", "Some Glasses", 5, "img/p03.jpg"
                                )
                            }
                        });
                }
            }
            catch (Exception e)
            {
                _logger.LogError(e, e.Message);
            }
        }
    }
}
