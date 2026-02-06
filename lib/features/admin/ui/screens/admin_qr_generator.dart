import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:loyalty_app/core/theming/colors.dart';
import 'package:loyalty_app/core/helpers/spacing.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class AdminQRGeneratorScreen extends StatefulWidget {
  const AdminQRGeneratorScreen({super.key});

  @override
  State<AdminQRGeneratorScreen> createState() => _AdminQRGeneratorScreenState();
}

class _AdminQRGeneratorScreenState extends State<AdminQRGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productCodeController = TextEditingController();
  final TextEditingController _productSizeController = TextEditingController();
  final TextEditingController _buyPointsController = TextEditingController();
  final TextEditingController _sellPointsController = TextEditingController();
  final TextEditingController _technicianBuyPointsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedCategory;
  String? _qrDataTrader; // QR للتاجر والموزع
  String? _qrDataTechnician; // QR للفني

  final List<String> _categories = [
    'سلك 1.5 مم',
    'سلك 2 مم',
    'سلك 2.5 مم',
    'سلك 4 مم',
    'سلك 6 مم',
    'كابل أرضي',
    'كابل هوائي',
  ];

  @override
  void dispose() {
    _productNameController.dispose();
    _productCodeController.dispose();
    _productSizeController.dispose();
    _buyPointsController.dispose();
    _sellPointsController.dispose();
    _technicianBuyPointsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _generateQRCodes() {
    if (_formKey.currentState!.validate()) {
      final baseData = {
        "productName": _productNameController.text.trim(),
        "productCode": _productCodeController.text.trim(),
        "category": _selectedCategory,
        "size": _productSizeController.text.trim(),
        "price": double.parse(_priceController.text.trim()),
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      };

      // QR للتاجر والموزع (شراء وبيع)
      final traderData = {
        ...baseData,
        "userType": "trader_distributor",
        "buyPoints": double.parse(_buyPointsController.text.trim()),
        "sellPoints": double.parse(_sellPointsController.text.trim()),
      };

      // QR للفني (شراء فقط)
      final technicianData = {
        ...baseData,
        "userType": "technician",
        "buyPoints": double.parse(_technicianBuyPointsController.text.trim()),
      };

      setState(() {
        _qrDataTrader = jsonEncode(traderData);
        _qrDataTechnician = jsonEncode(technicianData);
      });
    }
  }

  void _copyQRData(String data, String type) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            horizontalSpace(8),
            Text('تم نسخ بيانات QR $type'),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _productNameController.clear();
    _productCodeController.clear();
    _productSizeController.clear();
    _buyPointsController.clear();
    _sellPointsController.clear();
    _technicianBuyPointsController.clear();
    _priceController.clear();
    setState(() {
      _selectedCategory = null;
      _qrDataTrader = null;
      _qrDataTechnician = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء QR للمنتج'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_qrDataTrader != null || _qrDataTechnician != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _resetForm,
              tooltip: 'إعادة تعيين',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form Section
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيانات المنتج',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  verticalSpace(16),

                  // Product Name
                  TextFormField(
                    controller: _productNameController,
                    decoration: InputDecoration(
                      labelText: 'اسم المنتج *',
                      hintText: 'مثال: سلك كهرباء نحاس',
                      prefixIcon: const Icon(Icons.label),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'يرجى إدخال اسم المنتج' : null,
                  ),
                  verticalSpace(16),

                  // Product Code
                  TextFormField(
                    controller: _productCodeController,
                    decoration: InputDecoration(
                      labelText: 'كود المنتج *',
                      hintText: 'مثال: WR-1.5-100',
                      prefixIcon: const Icon(Icons.qr_code),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'يرجى إدخال كود المنتج' : null,
                  ),
                  verticalSpace(16),

                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'الفئة *',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) => value == null ? 'يرجى اختيار الفئة' : null,
                  ),
                  verticalSpace(16),

                  // Size
                  TextFormField(
                    controller: _productSizeController,
                    decoration: InputDecoration(
                      labelText: 'المقاس *',
                      hintText: 'مثال: 1.5 مم',
                      prefixIcon: const Icon(Icons.straighten),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'يرجى إدخال المقاس' : null,
                  ),
                  verticalSpace(16),

                  // Price
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'السعر (ج.م) *',
                      hintText: 'مثال: 150.00',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال السعر';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(24),

                  // Points Section
                  Text(
                    'النقاط',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  verticalSpace(16),

                  // Buy Points for Trader/Distributor
                  TextFormField(
                    controller: _buyPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'نقاط الشراء (تاجر/موزع) *',
                      hintText: 'مثال: 5',
                      prefixIcon: const Icon(Icons.shopping_cart),
                      suffixText: 'نقطة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال نقاط الشراء';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(16),

                  // Sell Points for Trader/Distributor
                  TextFormField(
                    controller: _sellPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'نقاط البيع (تاجر/موزع) *',
                      hintText: 'مثال: 8',
                      prefixIcon: const Icon(Icons.sell),
                      suffixText: 'نقطة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال نقاط البيع';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(16),

                  // Buy Points for Technician
                  TextFormField(
                    controller: _technicianBuyPointsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'نقاط الشراء (فني) *',
                      hintText: 'مثال: 3',
                      prefixIcon: const Icon(Icons.build),
                      suffixText: 'نقطة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال نقاط الشراء للفني';
                      }
                      if (double.tryParse(value) == null) {
                        return 'يرجى إدخال رقم صحيح';
                      }
                      return null;
                    },
                  ),
                  verticalSpace(24),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: _generateQRCodes,
                      icon: const Icon(Icons.qr_code_2),
                      label: const Text('إنشاء أكواد QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // QR Codes Display Section
            if (_qrDataTrader != null || _qrDataTechnician != null) ...[
              verticalSpace(40),
              Divider(thickness: 1, color: Colors.grey.shade300),
              verticalSpace(24),

              Text(
                'أكواد QR الجاهزة',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              verticalSpace(16),

              // QR for Trader/Distributor
              if (_qrDataTrader != null) ...[
                _buildQRCard(
                  title: 'QR للتاجر والموزع',
                  subtitle: 'يدعم الشراء والبيع',
                  qrData: _qrDataTrader!,
                  color: AppTheme.successColor,
                  icon: Icons.store,
                  onCopy: () => _copyQRData(_qrDataTrader!, 'التاجر/الموزع'),
                ),
                verticalSpace(16),
              ],

              // QR for Technician
              if (_qrDataTechnician != null) ...[
                _buildQRCard(
                  title: 'QR للفني',
                  subtitle: 'يدعم الشراء فقط',
                  qrData: _qrDataTechnician!,
                  color: AppTheme.accentColor,
                  icon: Icons.build,
                  onCopy: () => _copyQRData(_qrDataTechnician!, 'الفني'),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard({
    required String title,
    required String subtitle,
    required String qrData,
    required Color color,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: color, size: 28.sp),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                    verticalSpace(4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(20),

          // QR Code
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.w,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),
          ),
          verticalSpace(16),

          // Copy Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCopy,
              icon: const Icon(Icons.copy),
              label: const Text('نسخ بيانات QR'),
              style: OutlinedButton.styleFrom(
                foregroundColor: color,
                side: BorderSide(color: color),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}