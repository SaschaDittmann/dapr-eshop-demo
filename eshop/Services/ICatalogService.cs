using System.Collections.Generic;
using eshop.Models;

namespace eshop.Services
{
    public interface ICatalogService
    {
        List<Product> GetProducts();

        Product GetProductById(string id);
    }
}