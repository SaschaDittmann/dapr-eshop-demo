using System.Collections.Generic;
using System.Threading.Tasks;
using WebShop.Models;

namespace WebShop.Services
{
    public interface ICatalogService
    {
        Task<IEnumerable<Product>> GetProducts();

        Task<Product> GetProductById(string id);
    }
}