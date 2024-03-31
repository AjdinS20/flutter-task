import 'package:flutter/material.dart';
import 'package:flutter_assignment/components/product_card.dart';
import 'package:flutter_assignment/models/product_model.dart';
import 'package:flutter_assignment/services/product_service.dart';
import 'dart:async';

class ProductScreen extends StatefulWidget {
  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  final List<Product> _products = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;
  bool _isFetching = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  void fetchProducts() async {
    if (!_isFetching && !_isSearching) {
      setState(() {
        _isFetching = true;
      });
      final products =
          await ProductService().fetchProducts(15, _products.length);
      if (products.isNotEmpty) {
        setState(() {
          _products.addAll(products);
        });
      }
      setState(() {
        _isFetching = false;
      });
    }
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text;
      if (query.isEmpty) {
        setState(() {
          _isSearching = false;
          _products.clear();
          fetchProducts();
        });
      } else {
        setState(() {
          _isSearching = true;
        });
        ProductService().searchProducts(query).then((results) {
          setState(() {
            _products.clear();
            _products.addAll(results);
          });
        });
      }
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isSearching) {
      fetchProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _products.length,
              itemBuilder: (context, index) {
                return ProductCard(product: _products[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
