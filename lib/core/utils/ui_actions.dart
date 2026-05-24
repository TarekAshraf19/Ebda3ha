import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';

class UIActions {
  static Future<void> addToCart(
      BuildContext context,
      Product product, {
        int qty = 1,
        String? size,
        String? color,
      }) async {
    try {
      await CartService.instance.addToCart(
        product,
        qty: qty,
        size: size,
        color: color,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to cart ✅"),
          duration: Duration(seconds: 2),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cart Error: ${e.code} - ${e.message}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Cart Error: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> toggleWishlist(
      BuildContext context,
      Product product,
      ) async {
    try {
      final isInWishlist =
      await WishlistService.instance.isInWishlist(product.id);

      if (isInWishlist) {
        await WishlistService.instance.remove(product.id);
      } else {
        await WishlistService.instance.add(product);
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isInWishlist
                ? "Removed from wishlist 💔"
                : "Added to wishlist ❤️",
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } on FirebaseException catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wishlist Error: ${e.code} - ${e.message}"),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Wishlist Error: $e"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}