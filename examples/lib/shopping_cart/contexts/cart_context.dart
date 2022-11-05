import 'package:flutter_reactter/flutter_reactter.dart';

import '../models/product_state.dart';

class CartContext extends ReactterContext {
  late final products = UseState<Map<ProductState, int>>({}, this);
  late final productsLen = UseState(0, this);
  late final quantityProducts = UseState(0, this);
  late final total = UseState(0.0, this);

  void addProduct(ProductState productState) {
    if (!productState.decreaseStock()) return;

    products.update(() {
      final quantity = (products.value[productState] ?? 0) + 1;
      products.value[productState] = quantity;
    });

    quantityProducts.value += 1;
    total.value += productState.price;
  }

  void removeProduct(ProductState productState) {
    if (!productState.increaseStock()) return;

    products.update(() {
      final quantity = (products.value[productState] ?? 0) - 1;
      products.value[productState] = quantity;

      if (quantity < 1) {
        products.value.remove(productState);
      }
    });

    quantityProducts.value -= 1;
    total.value -= productState.price;
  }

  void deleteProduct(ProductState productState) {
    if (products.value[productState] == null) {
      return;
    }

    final quantity = products.value[productState]!;
    productState.increaseStock(quantity);

    products.update(() {
      products.value.remove(productState);
    });

    quantityProducts.value -= quantity;
    total.value -= productState.price * quantity;
  }

  void checkout() {
    products.update(products.value.clear);
    productsLen.value = 0;
    quantityProducts.value = 0;
    total.value = 0;
  }
}
