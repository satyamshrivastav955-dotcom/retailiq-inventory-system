import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product; // null = add mode, non-null = edit mode
  final String? initialBarcode;
  final String? initialName;
  final String? initialCategory;
  final double? initialPrice;
  final String? initialSupplier;
  final String? initialBrand;
  final String? initialDescription;
  final String? initialImageUrl;

  const AddProductScreen({
    super.key,
    this.product,
    this.initialBarcode,
    this.initialName,
    this.initialCategory,
    this.initialPrice,
    this.initialSupplier,
    this.initialBrand,
    this.initialDescription,
    this.initialImageUrl,
  });

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _barcodeController;
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _descriptionController;
  late TextEditingController _costPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _supplierController;
  late TextEditingController _minStockController;

  String _selectedCategory = kProductCategories.first;
  DateTime? _expiryDate;
  String? _imageUrl;
  bool _isLoading = false;
  bool _autoFilled = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _barcodeController = TextEditingController(
        text: p?.barcode ?? widget.initialBarcode ?? '');
    _nameController = TextEditingController(
        text: p?.name ?? widget.initialName ?? '');
    _brandController = TextEditingController(
        text: p?.brand ?? widget.initialBrand ?? '');
    _descriptionController = TextEditingController(
        text: p?.description ?? widget.initialDescription ?? '');
    _costPriceController =
        TextEditingController(text: p?.costPrice.toString() ?? '');
    _sellingPriceController = TextEditingController(
        text: p?.sellingPrice.toString() ??
            (widget.initialPrice != null
                ? widget.initialPrice.toString()
                : ''));
    _quantityController =
        TextEditingController(text: p?.quantity.toString() ?? '');
    _supplierController = TextEditingController(
        text: p?.supplier ?? widget.initialSupplier ?? '');
    _minStockController =
        TextEditingController(text: p?.minimumStockLevel.toString() ?? '5');

    _imageUrl = p?.imageUrl ?? widget.initialImageUrl;

    if (p != null) {
      _selectedCategory = p.category;
      _expiryDate = p.expiryDate;
    } else if (widget.initialCategory != null &&
        kProductCategories.contains(widget.initialCategory)) {
      _selectedCategory = widget.initialCategory!;
    }

    _autoFilled = !isEditing &&
        (widget.initialName != null ||
            widget.initialCategory != null ||
            widget.initialPrice != null ||
            widget.initialSupplier != null ||
            widget.initialBrand != null);
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _supplierController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (date != null) {
      setState(() => _expiryDate = date);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final product = ProductModel(
      productId: widget.product?.productId ?? '',
      barcode: _barcodeController.text.trim(),
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageUrl,
      category: _selectedCategory,
      costPrice: double.tryParse(_costPriceController.text) ?? 0,
      sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0,
      quantity: int.tryParse(_quantityController.text) ?? 0,
      expiryDate: _expiryDate,
      supplier: _supplierController.text.trim(),
      minimumStockLevel: int.tryParse(_minStockController.text) ?? 5,
      createdAt: widget.product?.createdAt ?? DateTime.now(),
      lastSoldAt: widget.product?.lastSoldAt,
    );

    if (isEditing) {
      final success = await productProvider.updateProduct(product);
      setState(() => _isLoading = false);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.error ?? 'Failed to update product'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      final result = await productProvider.addProduct(product);
      setState(() => _isLoading = false);

      if (result == 'added' && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (result == 'duplicate' && mounted) {
        _showDuplicateDialog(product);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.error ?? 'Failed to add product'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDuplicateDialog(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Barcode Already Exists'),
          ],
        ),
        content: Text(
          'A product with barcode "${product.barcode}" already exists. '
          'Would you like to update the existing product\'s stock instead?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              final existing =
                  await productProvider.findByBarcode(product.barcode);
              if (existing != null) {
                await productProvider.updateStock(
                    existing.productId, product.quantity);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock updated successfully'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Product' : 'Add Product',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Auto-fill notice
              if (_autoFilled) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some fields were auto-filled from barcode data. Please review and complete the rest.',
                          style: TextStyle(
                              color: AppColors.success, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Image preview
              if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageUrl!,
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, st) => Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Barcode
              _buildSectionTitle('Barcode'),
              TextFormField(
                controller: _barcodeController,
                decoration: AppDecorations.inputDecoration(
                  'Barcode / SKU',
                  icon: Icons.qr_code,
                ),
                validator: (v) => validateRequired(v, 'Barcode'),
              ),
              const SizedBox(height: 16),

              // Product Details
              _buildSectionTitle('Product Details'),
              TextFormField(
                controller: _nameController,
                decoration: AppDecorations.inputDecoration(
                  'Product Name',
                  icon: Icons.label_outlined,
                ),
                validator: (v) => validateRequired(v, 'Product name'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brandController,
                decoration: AppDecorations.inputDecoration(
                  'Brand',
                  icon: Icons.business_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: AppDecorations.inputDecoration(
                  'Description',
                  icon: Icons.description_outlined,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: AppDecorations.inputDecoration(
                  'Category',
                  icon: Icons.category_outlined,
                ),
                items: kProductCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 16),

              // Pricing
              _buildSectionTitle('Pricing'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _costPriceController,
                      keyboardType: TextInputType.number,
                      decoration: AppDecorations.inputDecoration(
                        'Cost Price (₹)',
                        icon: Icons.money_off,
                      ),
                      validator: (v) => validatePositiveNumber(v, 'Cost price'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      keyboardType: TextInputType.number,
                      decoration: AppDecorations.inputDecoration(
                        'Selling Price (₹)',
                        icon: Icons.sell_outlined,
                      ),
                      validator: (v) =>
                          validatePositiveNumber(v, 'Selling price'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock
              _buildSectionTitle('Inventory'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: AppDecorations.inputDecoration(
                        'Quantity',
                        icon: Icons.inventory_2_outlined,
                      ),
                      validator: (v) =>
                          validateNonNegativeInt(v, 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _minStockController,
                      keyboardType: TextInputType.number,
                      decoration: AppDecorations.inputDecoration(
                        'Min Stock Level',
                        icon: Icons.low_priority,
                      ),
                      validator: (v) =>
                          validateNonNegativeInt(v, 'Min stock level'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Supplier & Expiry
              _buildSectionTitle('Supplier & Expiry'),
              TextFormField(
                controller: _supplierController,
                decoration: AppDecorations.inputDecoration(
                  'Supplier Name',
                  icon: Icons.local_shipping_outlined,
                ),
              ),
              const SizedBox(height: 12),

              // Expiry Date
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: AppDecorations.inputDecoration(
                    'Expiry Date (optional)',
                    icon: Icons.event,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _expiryDate != null
                            ? formatDate(_expiryDate!)
                            : 'No expiry date set',
                        style: TextStyle(
                          color: _expiryDate != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                      ),
                      if (_expiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            setState(() => _expiryDate = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : Text(
                          isEditing ? 'Update Product' : 'Add Product',
                          style: AppTextStyles.button,
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }
}
