using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using WebShop.Models;

namespace WebShop.Services
{
    public class DaprCatalogService : ICatalogService, IDisposable
    {
        private readonly DaprClient _daprClient;

        public DaprCatalogService()
        {
            _daprClient = new DaprClientBuilder().Build();
        }

        public DaprCatalogService(DaprClient daprClient)
        {
            _daprClient = daprClient;
        }

        public async Task<IEnumerable<Product>> GetProducts()
        {
            return await _daprClient.InvokeMethodAsync<object, List<Product>>(
                HttpMethod.Get,
                "productcatalog",
                "products",
                null);
        }

        public async Task<Product> GetProductById(string id)
        {
            var data = new {id = id};
            var productResponse = await _daprClient.InvokeMethodAsync<object, List<Product>>(
                HttpMethod.Get,
                "productcatalog",
                "products",
                data);
            return productResponse.FirstOrDefault();
        }

        public void Dispose()
        {
            _daprClient?.Dispose();
        }
    }
}