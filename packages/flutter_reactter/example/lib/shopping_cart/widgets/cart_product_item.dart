import 'package:flutter/material.dart';
import 'package:flutter_reactter/flutter_reactter.dart';

import '../controllers/cart_controller.dart';
import '../models/product_state.dart';

class CartProductItem extends StatelessWidget {
  final ProductState product;
  final int quantity;
  final Color? color;

  const CartProductItem({
    Key? key,
    required this.product,
    required this.quantity,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartController = context.use<CartController>();

    return ListTile(
      tileColor: color,
      title: Text(
        product.name,
        style: Theme.of(context).textTheme.titleLarge,
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Price: '),
          Text(
            formatCurrency(product.price),
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatCurrency(product.price * quantity),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          Text(
            "x$quantity",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 8),
          IconButton(
            color: Colors.red.shade400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 42),
            splashRadius: 18,
            iconSize: 24,
            icon: const Icon(Icons.delete),
            onPressed: () => cartController.deleteProduct(product),
          ),
          IconButton(
            color: Colors.red.shade400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 42),
            splashRadius: 18,
            iconSize: 24,
            icon: const Icon(Icons.remove_circle),
            onPressed: () => cartController.removeProduct(product),
          ),
          IconButton(
            color: Colors.green.shade400,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 42),
            splashRadius: 18,
            iconSize: 24,
            icon: const Icon(Icons.add_circle),
            onPressed: product.stock == 0
                ? null
                : () => cartController.addProduct(product),
          ),
        ],
      ),
    );
  }
}
