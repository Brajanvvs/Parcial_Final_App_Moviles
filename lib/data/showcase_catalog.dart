import 'package:flutter/material.dart';

import '../models/catalog_item.dart';
import '../models/promo_banner.dart';

/// Vitrina estilo Alkosto (~50 artículos) organizada por secciones.
/// `remoteProductId` apunta a un producto real de la API para el carrito.
class ShowcaseCatalog {
  static const tiles = <CategoryTile>[
    CategoryTile(id: 1, name: 'Celulares', icon: Icons.smartphone, categoryId: 2),
    CategoryTile(id: 2, name: 'Electro', icon: Icons.kitchen_outlined, categoryId: 3),
    CategoryTile(id: 3, name: 'Computadores', icon: Icons.laptop_mac, categoryId: 2),
    CategoryTile(id: 4, name: 'Televisores', icon: Icons.tv, categoryId: 2),
    CategoryTile(id: 5, name: 'Videojuegos', icon: Icons.sports_esports_outlined, categoryId: 4),
    CategoryTile(id: 6, name: 'Audio', icon: Icons.speaker_outlined, categoryId: 2),
    CategoryTile(id: 7, name: 'Electrohogar', icon: Icons.blender_outlined, categoryId: 3),
    CategoryTile(id: 8, name: 'Smartwatch', icon: Icons.watch_outlined, categoryId: 2),
    CategoryTile(id: 9, name: 'Audífonos', icon: Icons.headphones, categoryId: 2),
    CategoryTile(id: 10, name: 'Accesorios', icon: Icons.mouse_outlined, categoryId: 2),
    CategoryTile(id: 11, name: 'Hogar', icon: Icons.chair_outlined, categoryId: 3),
    CategoryTile(id: 12, name: 'Deportes', icon: Icons.fitness_center, categoryId: 4),
    CategoryTile(id: 13, name: 'Belleza', icon: Icons.spa_outlined, categoryId: 5),
    CategoryTile(id: 14, name: 'Ropa', icon: Icons.checkroom, categoryId: 1),
    CategoryTile(id: 15, name: 'Ofertas', icon: Icons.local_offer_outlined),
    CategoryTile(id: 16, name: 'Hiperofertas', icon: Icons.percent),
  ];

  static final banners = <PromoBanner>[
    PromoBanner(
      id: 101,
      imageUrl: _img('photo-1517336714731-489689fd1ca8', 1200, 500),
      title: 'Novedades Apple · 0% de interés',
    ),
    PromoBanner(
      id: 102,
      imageUrl: _img('photo-1593359677879-a4bb92f829d1', 1200, 500),
      title: 'Smart TV 4K desde \$1.299.900',
    ),
    PromoBanner(
      id: 103,
      imageUrl: _img('photo-1607082348824-0a96f2a4b9da', 1200, 500),
      title: 'Black Days · Hasta 50% DTO',
    ),
    PromoBanner(
      id: 104,
      imageUrl: _img('photo-1593640408182-31c70c8268f5', 1200, 500),
      title: 'Portátiles gamer con RTX',
    ),
  ];

  static const sections = <HomeSection>[
    HomeSection(
      id: 'phones',
      title: 'Llévate el que estabas esperando',
      emoji: '📲',
      productIds: [1, 2, 3, 4, 5, 6, 7, 8],
    ),
    HomeSection(
      id: 'offers',
      title: 'Ofertas que no querrás dejar pasar',
      emoji: '🔥',
      productIds: [9, 10, 11, 12, 13, 14, 15, 16],
    ),
    HomeSection(
      id: 'tv',
      title: 'Vive cada momento en pantalla grande',
      emoji: '📺',
      productIds: [17, 18, 19, 20, 21, 22],
    ),
    HomeSection(
      id: 'computers',
      title: 'Esa potencia con ese precio',
      emoji: '💻',
      productIds: [23, 24, 25, 26, 27, 28],
    ),
    HomeSection(
      id: 'home',
      title: 'Electrodomésticos de última tecnología',
      emoji: '🏠',
      productIds: [29, 30, 31, 32, 33, 34, 35, 36],
    ),
    HomeSection(
      id: 'audio',
      title: 'Los accesorios que completan tu experiencia',
      emoji: '🎧',
      productIds: [37, 38, 39, 40, 41, 42],
    ),
    HomeSection(
      id: 'sports',
      title: 'Listo para cualquier aventura',
      emoji: '🏁',
      productIds: [43, 44, 45, 46, 47, 48, 49, 50],
    ),
  ];

  static final products = <CatalogItem>[
    _item(1, 6, 'Galaxy A56 5G 256GB', 'SAMSUNG', 'Celular', 2, 'Electrónica', 1899900, 2499900, 18, 'photo-1610945415295-d9bbf067e59c'),
    _item(2, 6, 'iPhone 15 128GB', 'APPLE', 'Celular', 2, 'Electrónica', 3299900, 3899900, 12, 'photo-1592750475338-74b7b21085ab'),
    _item(3, 5, 'Redmi Note 14 Pro 256GB', 'XIAOMI', 'Celular', 2, 'Electrónica', 1299900, 1699900, 22, 'photo-1511707171634-5f897ff02aa9'),
    _item(4, 5, 'Pova Curve2 256GB 5G', 'TECNO', 'Celular', 2, 'Electrónica', 899900, 1249900, 20, 'photo-1598327105666-5b89351aff97'),
    _item(5, 7, 'Nova Y74 256GB + audífonos', 'HUAWEI', 'Celular', 2, 'Electrónica', 999900, 1399900, 15, 'photo-1580910051074-3eb694886505'),
    _item(6, 6, 'Moto G85 256GB', 'MOTOROLA', 'Celular', 2, 'Electrónica', 1099900, 1499900, 16, 'photo-1567581935884-3349723552ca'),
    _item(7, 5, 'Honor 600 Smart + reloj', 'HONOR', 'Celular', 2, 'Electrónica', 1199900, 1599900, 14, 'photo-1510557880182-3d4d3cba35a5'),
    _item(8, 8, 'Infinix Hot 70 Pro 256GB', 'INFINIX', 'Celular', 2, 'Electrónica', 799900, 1099900, 25, 'photo-1574944985070-8f3ebc6b79d2'),
    _item(9, 1, 'Camiseta básica algodón', 'BASICS', 'Ropa', 1, 'Ropa', 39900, 59900, 50, 'photo-1521572163474-6864f9cf17ab'),
    _item(10, 2, 'Jean slim fit azul', 'DENIM CO', 'Ropa', 1, 'Ropa', 119900, 169900, 30, 'photo-1542272604-787c3835535d'),
    _item(11, 3, 'Chaqueta impermeable', 'OUTDOOR', 'Ropa', 1, 'Ropa', 189900, 259900, 15, 'photo-1551028719-00167b16eac5'),
    _item(12, 4, 'Sudadera con capucha', 'URBAN', 'Ropa', 1, 'Ropa', 89900, 129900, 25, 'photo-1556821840-3a63f95609a7'),
    _item(13, 17, 'Crema hidratante facial 50 ml', 'DERMA', 'Belleza', 5, 'Belleza', 59900, 89900, 28, 'photo-1556228720-195a672e8a03'),
    _item(14, 18, 'Perfume floral 100 ml', 'AROMA', 'Belleza', 5, 'Belleza', 199900, 279900, 11, 'photo-1541643600914-78b084683601'),
    _item(15, 19, 'Kit de brochas de maquillaje', 'GLAM', 'Belleza', 5, 'Belleza', 74900, 109900, 20, 'photo-1596462502278-27bfdc403348'),
    _item(16, 20, 'Protector solar SPF 50', 'SUNCARE', 'Belleza', 5, 'Belleza', 54900, 79900, 33, 'photo-1556228578-0d85b1a4d571'),
    _item(17, 8, 'Smart TV 55" 4K UHD', 'KALLEY', 'Televisor', 2, 'Electrónica', 1499900, 2199900, 10, 'photo-1593359677879-a4bb92f829d1'),
    _item(18, 7, 'TV 65" QLED 4K Google TV', 'TCL', 'Televisor', 2, 'Electrónica', 2499900, 3499900, 8, 'photo-1461151304267-38535e780c79'),
    _item(19, 6, 'TV 50" Mini LED Smart TV', 'HISENSE', 'Televisor', 2, 'Electrónica', 1899900, 2699900, 9, 'photo-1593784991095-a205069470b6'),
    _item(20, 7, 'TV 43" Full HD Android', 'LG', 'Televisor', 2, 'Electrónica', 999900, 1399900, 12, 'photo-1567690187548-f07b1d7bf5a9'),
    _item(21, 5, 'Soundbar 2.1 con subwoofer', 'SONY', 'Audio', 2, 'Electrónica', 699900, 999900, 14, 'photo-1545454675-3531b543be5d'),
    _item(22, 8, 'TV 32" HD Ready', 'HYUNDAI', 'Televisor', 2, 'Electrónica', 599900, 799900, 18, 'photo-1571415060716-baff5f717c37'),
    _item(23, 8, 'Portátil IdeaPad Slim 15.6"', 'LENOVO', 'Computador', 2, 'Electrónica', 1599900, 2199900, 10, 'photo-1496181133206-80ce9b88a853'),
    _item(24, 6, 'Vivobook 16" Ultra 5 16GB', 'ASUS', 'Computador', 2, 'Electrónica', 2899900, 3599900, 7, 'photo-1484788984921-03950022c9ef'),
    _item(25, 6, 'TUF F16 Gamer RTX 3050', 'ASUS', 'Computador', 2, 'Electrónica', 3999900, 4899900, 5, 'photo-1593640408182-31c70c8268f5'),
    _item(26, 8, 'Teclado mecánico RGB', 'HYPERX', 'Accesorio', 2, 'Electrónica', 219900, 299900, 10, 'photo-1511467687858-23d96c32e4ae'),
    _item(27, 5, 'Audífonos inalámbricos ANC', 'SOUNDCORE', 'Audio', 2, 'Electrónica', 249900, 349900, 20, 'photo-1505740420928-5e560c06d30e'),
    _item(28, 7, 'Parlante portátil 360°', 'JBL', 'Audio', 2, 'Electrónica', 159900, 229900, 18, 'photo-1608043152269-423dbba4e7e1'),
    _item(29, 10, 'Nevecón Side by Side 529 L', 'KALLEY', 'Nevera', 3, 'Hogar', 2499900, 3299900, 6, 'photo-1571175443880-49e1d25b2bc5'),
    _item(30, 11, 'Cafetera de goteo 12 tazas', 'OSTER', 'Cocina', 3, 'Hogar', 139900, 199900, 14, 'photo-1495474472287-4d71bcdd2085'),
    _item(31, 10, 'Set de ollas antiadherentes', 'IMUSA', 'Cocina', 3, 'Hogar', 299900, 399900, 8, 'photo-1556909114-f6e7ad7d3136'),
    _item(32, 9, 'Lámpara de escritorio LED', 'PHILIPS', 'Hogar', 3, 'Hogar', 79900, 119900, 22, 'photo-1507473885765-e6ed057f782c'),
    _item(33, 12, 'Cojín decorativo 45x45', 'HOME', 'Hogar', 3, 'Hogar', 34900, 49900, 40, 'photo-1584100936595-c0654b55a2e2'),
    _item(34, 11, 'Licuadora Multiblend 2 en 1', 'BLACK+DECKER', 'Cocina', 3, 'Hogar', 189900, 259900, 12, 'photo-1570222094114-d054a817e56b'),
    _item(35, 10, 'Freidora de aire 3.5 L', 'KALLEY', 'Cocina', 3, 'Hogar', 179900, 249900, 15, 'photo-1635436338433-89747d0ca0ef'),
    _item(36, 11, 'Aspiradora trapeadora 2 en 1', 'T-FAL', 'Hogar', 3, 'Hogar', 459900, 599900, 9, 'photo-1558317374-067fb5f30001'),
    _item(37, 5, 'Audífonos over-ear Bluetooth', 'SONY', 'Audio', 2, 'Electrónica', 329900, 449900, 16, 'photo-1484704849700-f032a568e944'),
    _item(38, 6, 'Smartwatch deportivo GPS', 'HUAWEI', 'Wearable', 2, 'Electrónica', 329900, 459900, 12, 'photo-1579586337278-3befd40fd17a'),
    _item(39, 8, 'Mouse gamer RGB', 'LOGITECH', 'Accesorio', 2, 'Electrónica', 129900, 179900, 24, 'photo-1527814050087-3793815479db'),
    _item(40, 7, 'Cargador USB-C 65W', 'ANKER', 'Accesorio', 2, 'Electrónica', 89900, 129900, 30, 'photo-1583863788434-e58a36330cf0'),
    _item(41, 5, 'Power bank 20000 mAh', 'XIAOMI', 'Accesorio', 2, 'Electrónica', 119900, 169900, 26, 'photo-1597872200969-2b65d56bd16b'),
    _item(42, 8, 'Hub USB-C 7 en 1', 'UGREEN', 'Accesorio', 2, 'Electrónica', 149900, 199900, 17, 'photo-1555617981-dac3880eac6e'),
    _item(43, 13, 'Balón de fútbol profesional', 'ADIDAS', 'Deporte', 4, 'Deportes', 89900, 129900, 30, 'photo-1574629810360-7efbbe195018'),
    _item(44, 14, 'Mat de yoga 6 mm', 'FITNESS', 'Deporte', 4, 'Deportes', 69900, 99900, 35, 'photo-1601925260368-ae2f83cf8b7f'),
    _item(45, 15, 'Mancuernas ajustables 2-10 kg', 'SPORTPRO', 'Deporte', 4, 'Deportes', 279900, 369900, 9, 'photo-1517836357463-d25dfeac3438'),
    _item(46, 16, 'Botella térmica 750 ml', 'HYDRO', 'Deporte', 4, 'Deportes', 49900, 79900, 45, 'photo-1602143407151-7111542de6e8'),
    _item(47, 14, 'Bicicleta estática magnética', 'SPORTLINE', 'Deporte', 4, 'Deportes', 699900, 949900, 7, 'photo-1485965120184-e220f721d03e'),
    _item(48, 15, 'Cuerda de saltar con contador', 'FITNESS', 'Deporte', 4, 'Deportes', 39900, 59900, 40, 'photo-1518611012118-696072aa579a'),
    _item(49, 13, 'Guantes de gym antideslizantes', 'SPORTPRO', 'Deporte', 4, 'Deportes', 44900, 69900, 28, 'photo-1583454110551-21f2fa2afe61'),
    _item(50, 16, 'Mochila deportiva 30 L', 'OUTDOOR', 'Deporte', 4, 'Deportes', 119900, 169900, 20, 'photo-1553062407-98eeb64c6a62'),
  ];

  static CatalogItem? byId(int id) {
    for (final item in products) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<CatalogItem> bySection(String sectionId) {
    final section = sections.firstWhere((item) => item.id == sectionId);
    return section.productIds.map(byId).whereType<CatalogItem>().toList();
  }

  static List<CatalogItem> search({String? query, int? categoryId}) {
    final needle = query?.trim().toLowerCase() ?? '';
    return products.where((item) {
      final matchesCategory = categoryId == null || item.categoryId == categoryId;
      if (!matchesCategory) return false;
      if (needle.isEmpty) return true;
      return item.name.toLowerCase().contains(needle) ||
          item.brand.toLowerCase().contains(needle) ||
          item.categoryName.toLowerCase().contains(needle);
    }).toList();
  }

  static CatalogItem _item(
    int id,
    int remoteProductId,
    String name,
    String brand,
    String kind,
    int categoryId,
    String categoryName,
    double price,
    double oldPrice,
    int stock,
    String photoId,
  ) {
    return CatalogItem(
      id: id,
      remoteProductId: remoteProductId,
      name: name,
      brand: brand,
      description:
          '$brand $name. $kind con garantía del fabricante, envío a todo el país y opción de pago a cuotas.',
      price: price,
      oldPrice: oldPrice,
      imageUrl: _img(photoId),
      categoryId: categoryId,
      categoryName: categoryName,
      sectionId: categoryName.toLowerCase(),
      stock: stock,
    );
  }

  static String _img(String photoId, [int width = 600, int height = 600]) {
    return 'https://images.unsplash.com/$photoId?auto=format&fit=crop&w=$width&h=$height&q=80';
  }
}
