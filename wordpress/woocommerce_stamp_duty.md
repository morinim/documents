# How to add a stamp duty in WooCommerce

According to the Italian tax law, stamp duty (*imposta di bollo*) is applicable on invoices (both paper and electronic) in all cases where the relevant transaction is Value Added Tax ([VAT](https://en.wikipedia.org/wiki/Value-added_tax)) excluded, non-taxable or VAT exempt, for a value exceeding a given treshold (currently € 77.47).

The amount due for the invoices issued is a fixed value (currently € 2).

We would like to check if the stamp duty is applicable and add/display the additional fee in the WooCommerce cart.

#### Example 1
```
PRODUCT  PRICE  QUANTITY  TOTAL            TAXABLE
-------------------------------
0001      10           7     70            NO
-------------------------------
0002      30           1     30            YES
-------------------------------

                    Cart totals
    ---------------------------
    CART SUBTOTAL 100
    ---------------------------
    SHIPPING      Free shipping
    ---------------------------
    ORDER TOTAL   100
    ---------------------------
```

Here the non taxable subtotal is `70` so stamp duty is not due (`70 <= 77.47`).

#### Example 2
```
PRODUCT  PRICE  QUANTITY  TOTAL            TAXABLE 
-------------------------------
0001      10           8     80            NO
-------------------------------
0002      30           1     30            YES
-------------------------------

                    Cart totals
    ---------------------------
    CART SUBTOTAL 110
    ---------------------------
    SHIPPING      Free shipping
    ---------------------------
    STAMP DUTY    2
    ---------------------------
    ORDER TOTAL   112
    ---------------------------
```

Here the non taxable subtotal is `80` so stamp duty is due (`80 > 77.47`).

## Generalities

WooCommerce has a built-in function in the [cart object](https://woocommerce.github.io/code-reference/classes/WC-Cart.html) for adding fees (`woocommerce_cart_calculate_fees`).

All we need is to hook onto the right action and with the provided cart object call a function to add a fee (`add_fee()`).

WooCommerce will automatically display fees in the cart and checkout totals. You decide the fee's label and amount.

## Base framework

Adding a custom fee is done in its simplest form like this:

```php
add_action('woocommerce_cart_calculate_fees', function()
{
  if (is_admin() && !defined('DOING_AJAX'))
    return;

  WC()->cart->add_fee(__('Imposta di bollo', 'txtdomain'), 2);
});
```

## Calculate the relevant transactions

Now we add the code to calculate the relevant transactions (`my_subtotal`):

```php
add_action('woocommerce_cart_calculate_fees', function()
{
  if (is_admin() && !defined('DOING_AJAX'))
    return;

  $my_subtotal = 0;

  foreach (WC()->cart->get_cart() as $cart_item)
  {
    $product = $cart_item['data'];
    $quantity = $cart_item['quantity'];
    $price = $product->get_price();

    if (!$product->is_taxable())
      $my_subtotal += $price * $quantity;
  }

  if ($my_subtotal > 77.47)
    WC()->cart->add_fee(__('Imposta di bollo', 'txtdomain'), 2);
});
```

**Remark**: in production code [magic numbers](https://en.wikipedia.org/wiki/Magic_number_(programming)) should not be used.

## Apply possible coupons

Last but not least we have to consider possible [coupons](https://woocommerce.github.io/code-reference/classes/WC-Coupon.html) (`WC()->cart->applied_coupons` / [`get_discount_amount`](https://woocommerce.github.io/code-reference/classes/WC-Coupon.html#method_get_discount_amount)):

```php
add_action('woocommerce_cart_calculate_fees', function()
{
  if (is_admin() && !defined('DOING_AJAX'))
    return;

  $my_subtotal = 0;
  $applied_coupons = WC()->cart->applied_coupons;

  foreach (WC()->cart->get_cart() as $cart_item)
  {
    $product = $cart_item['data'];
    $quantity = $cart_item['quantity'];
    $price = $product->get_price();

    if (!empty($applied_coupons))
      foreach ($applied_coupons as $code)
      {
        $coupon = new WC_Coupon($code);
        if ($coupon->is_valid())
          if ($coupon->is_valid_for_product($product) || $coupon->is_valid_for_cart())
          {
            $discount_amount = $coupon->get_discount_amount($price);
            $price = max($price - $discount_amount, 0);
          }
      }

    if (!$product->is_taxable())
      $my_subtotal += $price * $quantity;
  }

  if ($my_subtotal > 77.47)
    WC()->cart->add_fee(__('Imposta di bollo', 'txtdomain'), 2);
});
```

## General recommendations

Add code to your child theme's `functions.php` file or via a plugin that allows custom functions to be added, such as the [Code snippets](https://wordpress.org/plugins/code-snippets/) plugin. Avoid adding custom code directly to your parent theme's `functions.php` file as this will be wiped entirely when you update the theme.

## Insights

- [Guide on How to Add Custom Fees to WooCommerce Checkout by Code](https://awhitepixel.com/blog/woocommerce-checkout-add-custom-fees/)
- [Add a surcharge to cart and checkout – uses fees API](https://docs.woocommerce.com/document/add-a-surcharge-to-cart-and-checkout-uses-fees-api/)
