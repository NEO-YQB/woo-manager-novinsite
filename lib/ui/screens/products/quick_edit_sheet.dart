import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/custom_text_field.dart';

class QuickEditSheet extends StatefulWidget {
  final ProductModel product;

  const QuickEditSheet({
    super.key,
    required this.product,
  });

  @override
  State<QuickEditSheet> createState() => _QuickEditSheetState();
}

class _QuickEditSheetState extends State<QuickEditSheet> {
  late final TextEditingController _regularPriceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late bool _isPublished;
  late String _stockStatus;

  @override
  void initState() {
    super.initState();
    _regularPriceController = TextEditingController(
      text: widget.product.regularPrice > 0 ? widget.product.regularPrice.toStringAsFixed(0) : '',
    );
    _salePriceController = TextEditingController(
      text: widget.product.salePrice != null && widget.product.salePrice! > 0
          ? widget.product.salePrice!.toStringAsFixed(0)
          : '',
    );
    _stockController = TextEditingController(
      text: widget.product.stockQuantity != null ? widget.product.stockQuantity.toString() : '',
    );
    _isPublished = widget.product.isPublished;
    _stockStatus = widget.product.stockStatus;
  }

  @override
  void dispose() {
    _regularPriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final productsProvider = context.read<ProductsProvider>();

    final regPrice = double.tryParse(_regularPriceController.text.trim());
    final sPrice = double.tryParse(_salePriceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    final success = await productsProvider.quickUpdateProduct(
      widget.product.id,
      regularPrice: regPrice,
      salePrice: sPrice,
      stockQuantity: stock,
      stockStatus: _stockStatus,
      status: _isPublished ? 'publish' : 'draft',
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('محصول با موفقیت بروزرسانی شد.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productsProvider.errorMessage ?? 'خطا در ویرایش محصول.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'ویرایش سریع: ${widget.product.name}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),

            // قیمت‌ها
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _regularPriceController,
                    label: 'قیمت عادی (تومان)',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomTextField(
                    controller: _salePriceController,
                    label: 'قیمت فروش ویژه (تخفیف)',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // موجودی انبار
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _stockController,
                    label: 'تعداد موجودی در انبار',
                    keyboardType: TextInputType.number,
                    textDirection: TextDirection.ltr,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('وضعیت انبار', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _stockStatus,
                        decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                        items: const [
                          DropdownMenuItem(value: 'instock', child: Text('موجود')),
                          DropdownMenuItem(value: 'outofstock', child: Text('ناموجود')),
                          DropdownMenuItem(value: 'onbackorder', child: Text('پیش‌سفارش')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _stockStatus = val);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // وضعیت انتشار
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('وضعیت انتشار در فروشگاه', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(
                _isPublished ? 'محصول در سایت فعال و منتشر شده است' : 'محصول در حالت پیش‌نویس است',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              value: _isPublished,
              onChanged: (val) => setState(() => _isPublished = val),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: productsProvider.isUpdating ? null : _handleSave,
                child: productsProvider.isUpdating
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('ذخیره تغییرات محصول', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
