import 'package:bc_app/resources/pages/shopping_cart_page.dart';
import 'package:bc_app/resources/widgets/components/icon_with_badge_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class ShoppingCart extends StatefulWidget {
  
  const ShoppingCart({super.key});
  
  static String state = "shopping_cart";

  @override
  createState() => _ShoppingCartState();
}

class _ShoppingCartState extends NyState<ShoppingCart> {
  int? _cartValue;


  _ShoppingCartState() {
    stateName = ShoppingCart.state;
  }

  @override
  init() async {
     _cartValue = await _getCartValue();
  }
  
  @override
  stateUpdated(dynamic data) async {
    // e.g. to update this state from another class
    // updateState(ShoppingCart.state, data: "example payload");
    reboot(); 
  }

  Future<int> _getCartValue() async{
    List<dynamic>? cartList = await NyStorage.readJson("cart_list");
    return cartList == null ? 0 : cartList.length;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          40.0, // Set the width to the desired square size // Set the height to the same value
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, ShoppingCartPage.path);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA08D47),
          padding:
              EdgeInsets.zero, // Adjust padding as necessary
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius
                .zero, // Set border radius to zero for sharp corners
          ),
        ),
        child: IconWithBadge(
          icon: Icons.shopping_cart,
          badgeCount: _cartValue?? 0,
          size: 26,
        ),
      ),
    );
  }
}
