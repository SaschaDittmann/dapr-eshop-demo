using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using WebShop.Models;

namespace WebShop.Services
{
    public class FakeCatalogService : ICatalogService
    {
        private readonly List<Product> _products;

        public FakeCatalogService()
        {
            _products = new List<Product>();
            _products.Add(new Product
            {
                Id = "p01",
                Name = "Name 1",
                Price = 5,
            });
            _products.Add(new Product
            {
                Id = "p02",
                Name = "Name 2",
                Price = 3,
            });
            _products.Add(new Product
            {
                Id = "p03",
                Name = "Name 3",
                Price = 10,
            });
        }

        public async Task<IEnumerable<Product>> GetProducts()
        {
            return _products;
        }

        public async Task<Product> GetProductById(string id)
        {
            return _products.SingleOrDefault(p => p.Id == id);
        }
    }
}