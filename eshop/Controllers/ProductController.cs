using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using eshop.Models;
using eshop.Services;

namespace eshop.Controllers
{
    public class ProductController : Controller
    {
        public IActionResult Index()
        {
            ViewBag.products = CatalogService.List();
            return View();
        }
    }
}
