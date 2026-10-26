import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../providers/products_provider.dart';
import '../../widgets/custom_text_field.dart';

class ProductEditScreen extends StatefulWidget {
  final ProductModel? product;

  const ProductEditScreen({
    super.key,
    this.product,
  });

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _skuController;
  late final TextEditingController _regularPriceController;
  late final TextEditingController _salePriceController;
  late final TextEditingController _stockController;
  late final TextEditingController _shortDescController;
  late final TextEditingController _descController;

  late bool _manageStock;
  late String _stockStatus;
  late String _status;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _skuController = TextEditingController(text: p?.sku ?? '');
    _regularPriceController = TextEditingController(
      text: p != null && p.regularPrice > 0 ? p.regularPrice.toStringAsFixed(0) : '',
    );
    _salePriceController = TextEditingController(
      text: p != null && p.salePrice != null && p.salePrice! > 0 ? p.salePrice!.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: p?.stockQuantity != null ? p!.stockQuantity.toString() : '',
    );
    _shortDescController = TextEditingController(text: p?.shortDescription ?? '');
    _descController = TextEditingController(text: p?.description ?? '');

    _manageStock = p?.manageStock ?? true;
    _stockStatus = p?.stockStatus ?? 'instock';
    _status = p?.status ?? 'publish';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _regularPriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final productsProvider = context.read<ProductsProvider>();

    final Map<String, dynamic> data = {
      'name': _nameController.text.trim(),
      'type': 'simple',
      'regular_price': _regularPriceController.text.trim(),
      'sale_price': _salePriceController.text.trim().isNotEmpty ? _salePriceController.text.trim() : '',
      'sku': _skuController.text.trim(),
      'manage_stock': _manageStock,
      'stock_status': _stockStatus,
      'status': _status,
      'short_description': _shortDescController.text.trim(),
      'description': _descController.text.trim(),
    };

    if (_manageStock && _stockController.text.trim().isNotEmpty) {
      data['stock_quantity'] = int.tryParse(_stockController.text.trim()) ?? 0;
    }

    final success = await productsProvider.saveProduct(
      id: widget.product?.id,
      data: data,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'محصول با موفقیت ویرایش شد.' : 'محصول جدید با موفقیت ایجاد شد.'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productsProvider.errorMessage ?? 'خطا در ثبت محصول.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsProvider = context.watch<ProductsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'ویرایش محصول' : 'افزودن محصول جدید'),
        actions: [
          IconButton(
            icon: productsProvider.isUpdating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_rounded),
            tooltip: 'ذخیره',
            onPressed: productsProvider.isUpdating ? null : _handleSave,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'عنوان محصول *',
                hint: 'نام فارسی کالا را وارد کنید',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'عنوان محصول الزامی است';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _skuController,
                label: 'کد محصول (SKU)',
                hint: 'مثلاً PROD-1024',
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _regularPriceController,
                      label: 'قیمت عادی (تومان) *',
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'قیمت عادی الزامی است';
                        return null;
                      },
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

              // تنظیمات انبار
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('مدیریت موجودی انبار در سطح محصول', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                value: _manageStock,
                onChanged: (val) => setState(() => _manageStock = val),
              ),

              if (_manageStock) ...[
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _stockController,
                  label: 'تعداد موجودی در انبار',
                  keyboardType: TextInputType.number,
                  textDirection: TextDirection.ltr,
                ),
              ],

              const SizedBox(height: 14),

              // وضعیت موجودی
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('وضعیت انبار', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _stockStatus,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: 'instock', child: Text('موجود در انبار')),
                      DropdownMenuItem(value: 'outofstock', child: Text('ناموجود')),
                      DropdownMenuItem(value: 'onbackorder', child: Text('پیش‌سفارش')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _stockStatus = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // وضعیت انتشار
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('وضعیت محصول', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
                    items: const [
                      DropdownMenuItem(value: 'publish', child: Text('منتشر شده در سایت')),
                      DropdownMenuItem(value: 'draft', child: Text('پیش‌نویس (مخفی)')),
                      DropdownMenuItem(value: 'pending', child: Text('در انتظار بررسی')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _shortDescController,
                label: 'توضیحات کوتاه محصول',
                hint: 'خلاصه‌ای از ویژگی‌های کالا...',
                maxLines: 2,
              ),

              const SizedBox(height: 14),

              CustomTextField(
                controller: _descController,
                label: 'توضیحات کامل محصول',
                hint: 'متن معرفی، مشخصات و کاربری کالا...',
                maxLines: 4,
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: productsProvider.isUpdating ? null : _handleSave,
                  icon: productsProvider.isUpdating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.save_rounded),
                  label: Text(
                    isEditing ? 'ذخیره تغییرات محصول' : 'انتشار محصول جدید در ووکامرس',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
