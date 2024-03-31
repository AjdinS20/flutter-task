import 'package:flutter/material.dart';
import 'package:flutter_assignment/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define the fixed height for the image
    const double imageHeight = 120.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: 1.0,
                  child: Image.network(product.thumbnail,
                      width: double.infinity,
                      height: imageHeight,
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 8),
              Text(product.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(product.description,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('\$${product.price}',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 16.0, color: Colors.amber),
                  Text('${product.rating}')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
