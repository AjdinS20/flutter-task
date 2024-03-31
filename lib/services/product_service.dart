import 'base_service.dart';
import '../models/product_model.dart';

class ProductService extends BaseService {
  Future<List<Product>> fetchProducts(int limit, int skip) async {
    final response = await dio.get('/products?limit=$limit&skip=$skip');
    return (response.data['products'] as List)
        .map((p) => Product.fromJson(p))
        .toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final response = await dio.get('/products/search?q=$query');
    return (response.data['products'] as List)
        .map((p) => Product.fromJson(p))
        .toList();
  }
}
