using System.Collections.Generic;
using WebShop.Models;

namespace WebShop.Services
{
    public interface ICatalogService
    {
        List<Product> GetProducts();

        Product GetProductById(string id);
    }
}