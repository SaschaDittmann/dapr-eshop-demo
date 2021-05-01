using System.Collections.Generic;
using System.Linq;
using eshop.Models;

namespace eshop.Services
{
    public static class CatalogService
    {
        private static readonly List<Product> _products;

        static CatalogService()
        {
            _products = new List<Product>();
            _products.Add(new Product{
                Id = "p01",
                Name = "Name 1",
                Price = 5,
            });
            _products.Add(new Product{
                Id = "p02",
                Name = "Name 2",
                Price = 3,
            });
            _products.Add(new Product{
                Id = "p03",
                Name = "Name 3",
                Price = 10,
            });
        }

        public static List<Product> List()
        {
            return _products;
        }

        public static Product Find(string id)
        {
            return _products.SingleOrDefault(p => p.Id == id);
        }
    }
}