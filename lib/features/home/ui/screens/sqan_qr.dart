// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:loyalty_app/core/helpers/spacing.dart';
// import 'package:loyalty_app/core/helpers/user_roles.dart';
// import 'package:loyalty_app/core/theming/colors.dart';
// import 'package:loyalty_app/features/auth/logic/auth_cubit.dart';
// import 'package:loyalty_app/features/auth/logic/auth_states.dart';
// import 'package:provider/provider.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'dart:convert';

// class ScanQRScreen extends StatefulWidget {
//   const ScanQRScreen({super.key});

//   @override
//   State<ScanQRScreen> createState() => _ScanQRScreenState();
// }

// class _ScanQRScreenState extends State<ScanQRScreen> {
//   MobileScannerController cameraController = MobileScannerController();
//   Map<String, dynamic>? _scannedProductData;
//   int _quantity = 1;
//   bool _isProcessing = false;
//   bool _isTorchOn = false;

//   @override
//   void dispose() {
//     cameraController.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture capture) {
//     if (_isProcessing || !mounted) return;

//     final List<Barcode> barcodes = capture.barcodes;
//     for (final barcode in barcodes) {
//       if (barcode.rawValue != null) {
//         if (!mounted) return;

//         setState(() {
//           _isProcessing = true;
//         });

//         try {
//           // Parse QR data
//           final qrData = jsonDecode(barcode.rawValue!);

//           // Validate QR data
//           if (qrData is Map<String, dynamic> &&
//               qrData.containsKey('productName') &&
//               qrData.containsKey('userType')) {
//             final user = context.read<AuthProvider>().currentUser!;

//             // Check if QR matches user type
//             if (user.role == UserRole.technician) {
//               if (qrData['userType'] != 'technician') {
//                 _showErrorDialog(
//                     'هذا الكود غير صالح للفنيين. استخدم الكود الخاص بالفنيين.');
//                 if (mounted) {
//                   setState(() {
//                     _isProcessing = false;
//                   });
//                 }
//                 return;
//               }
//             } else {
//               if (qrData['userType'] != 'trader_distributor') {
//                 _showErrorDialog(
//                     'هذا الكود غير صالح للتجار/الموزعين. استخدم الكود المخصص لك.');
//                 if (mounted) {
//                   setState(() {
//                     _isProcessing = false;
//                   });
//                 }
//                 return;
//               }
//             }

//             if (mounted) {
//               setState(() {
//                 _scannedProductData = qrData;
//                 _quantity = 1;
//               });
//               _showTransactionDialog();
//             }
//           } else {
//             _showErrorDialog('كود QR غير صالح. تأكد من مسح الكود الصحيح.');
//             if (mounted) {
//               setState(() {
//                 _isProcessing = false;
//               });
//             }
//           }
//         } catch (e) {
//           _showErrorDialog('خطأ في قراءة الكود. تأكد من صحة الكود.');
//           if (mounted) {
//             setState(() {
//               _isProcessing = false;
//             });
//           }
//         }
//         break;
//       }
//     }
//   }

//   void _showErrorDialog(String message) {
//     if (!mounted) return;

//     // ⛔ وقف الكاميرا
//     cameraController.stop();

//     showDialog(
//       context: context,
//       barrierDismissible: false, // مهم
//       builder: (dialogContext) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         title: Row(
//           children: [
//             Icon(Icons.error_outline, color: AppTheme.errorColor),
//             horizontalSpace(8),
//             Text('خطأ', style: TextStyle(fontSize: 18.sp)),
//           ],
//         ),
//         content: Text(message, style: TextStyle(fontSize: 16.sp)),
//         actions: [
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(dialogContext);

//               // ▶️ شغل الكاميرا تاني
//               await cameraController.start();

//               if (mounted) {
//                 setState(() {
//                   _isProcessing = false;
//                 });
//               }
//             },
//             child: Text('حسناً', style: TextStyle(fontSize: 14.sp)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTransactionDialog() {
//     if (!mounted) return;

//     final user = context.read<AuthProvider>().currentUser!;
//     final isTechnician = user.role == UserRole.technician;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: true,
//       builder: (modalContext) => StatefulBuilder(
//         builder: (builderContext, setModalState) => Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//           ),
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(builderContext).viewInsets.bottom,
//           ),
//           child: SingleChildScrollView(
//             child: Padding(
//               padding: EdgeInsets.all(24.w),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   // Handle
//                   Container(
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade300,
//                       borderRadius: BorderRadius.circular(2.r),
//                     ),
//                   ),
//                   verticalSpace(24),

//                   // Success Icon
//                   Container(
//                     padding: EdgeInsets.all(24.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.successColor.withOpacity(0.1),
//                       shape: BoxShape.circle,
//                     ),
//                     child: Icon(
//                       Icons.check_circle,
//                       color: AppTheme.successColor,
//                       size: 48.sp,
//                     ),
//                   ),
//                   verticalSpace(16),

//                   // Title
//                   Text(
//                     'تم المسح بنجاح',
//                     style: Theme.of(builderContext)
//                         .textTheme
//                         .headlineSmall
//                         ?.copyWith(fontWeight: FontWeight.bold),
//                   ),
//                   verticalSpace(24),

//                   // Product Info
//                   Container(
//                     padding: EdgeInsets.all(16.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.backgroundColor,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: EdgeInsets.all(8.w),
//                               decoration: BoxDecoration(
//                                 color: AppTheme.accentColor.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Icon(
//                                 Icons.cable,
//                                 color: AppTheme.accentColor,
//                               ),
//                             ),
//                             horizontalSpace(16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'المنتج',
//                                     style: Theme.of(builderContext)
//                                         .textTheme
//                                         .bodySmall
//                                         ?.copyWith(
//                                             color: AppTheme.textSecondaryColor),
//                                   ),
//                                   Text(
//                                     _scannedProductData?['productName'] ?? '',
//                                     style: Theme.of(builderContext)
//                                         .textTheme
//                                         .titleMedium
//                                         ?.copyWith(fontWeight: FontWeight.bold),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                         verticalSpace(12),
//                         Divider(color: Colors.grey.shade300),
//                         verticalSpace(12),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             _buildProductDetail(
//                               builderContext,
//                               'الكود',
//                               _scannedProductData?['productCode'] ?? '',
//                             ),
//                             _buildProductDetail(
//                               builderContext,
//                               'المقاس',
//                               _scannedProductData?['size'] ?? '',
//                             ),
//                             _buildProductDetail(
//                               builderContext,
//                               'السعر',
//                               '${_scannedProductData?['price']} ج.م',
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   verticalSpace(16),

//                   // Quantity Selector
//                   Container(
//                     padding: EdgeInsets.all(16.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.backgroundColor,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'الكمية',
//                           style: Theme.of(builderContext)
//                               .textTheme
//                               .bodySmall
//                               ?.copyWith(color: AppTheme.textSecondaryColor),
//                         ),
//                         verticalSpace(8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 setModalState(() {
//                                   if (_quantity > 1) _quantity--;
//                                 });
//                               },
//                               icon: Icon(Icons.remove_circle_outline,
//                                   size: 32.sp),
//                               color: AppTheme.primaryColor,
//                             ),
//                             Container(
//                               width: 100.w,
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 16.w, vertical: 8.h),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12.r),
//                                 border: Border.all(
//                                   color: AppTheme.primaryColor.withOpacity(0.3),
//                                 ),
//                               ),
//                               child: Text(
//                                 '$_quantity',
//                                 style: Theme.of(builderContext)
//                                     .textTheme
//                                     .headlineSmall
//                                     ?.copyWith(fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () {
//                                 setModalState(() {
//                                   _quantity++;
//                                 });
//                               },
//                               icon: Icon(Icons.add_circle_outline, size: 32.sp),
//                               color: AppTheme.primaryColor,
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Points Preview
//                   if (!isTechnician) ...[
//                     verticalSpace(16),
//                     Container(
//                       padding: EdgeInsets.all(16.w),
//                       decoration: BoxDecoration(
//                         color: AppTheme.primaryColor.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppTheme.primaryColor.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceAround,
//                         children: [
//                           Column(
//                             children: [
//                               Text(
//                                 'نقاط الشراء',
//                                 style: Theme.of(builderContext)
//                                     .textTheme
//                                     .bodySmall
//                                     ?.copyWith(
//                                         color: AppTheme.textSecondaryColor),
//                               ),
//                               verticalSpace(4),
//                               Text(
//                                 '+${(_scannedProductData?['buyPoints'] ?? 0) * _quantity} نقطة',
//                                 style: Theme.of(builderContext)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(
//                                       color: AppTheme.accentColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           Container(
//                             width: 1,
//                             height: 40.h,
//                             color: Colors.grey.shade300,
//                           ),
//                           Column(
//                             children: [
//                               Text(
//                                 'نقاط البيع',
//                                 style: Theme.of(builderContext)
//                                     .textTheme
//                                     .bodySmall
//                                     ?.copyWith(
//                                         color: AppTheme.textSecondaryColor),
//                               ),
//                               verticalSpace(4),
//                               Text(
//                                 '+${(_scannedProductData?['sellPoints'] ?? 0) * _quantity} نقطة',
//                                 style: Theme.of(builderContext)
//                                     .textTheme
//                                     .titleMedium
//                                     ?.copyWith(
//                                       color: AppTheme.successColor,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ] else ...[
//                     verticalSpace(16),
//                     Container(
//                       padding: EdgeInsets.all(16.w),
//                       decoration: BoxDecoration(
//                         color: AppTheme.accentColor.withOpacity(0.05),
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: AppTheme.accentColor.withOpacity(0.2),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.stars,
//                               color: AppTheme.accentColor, size: 20.sp),
//                           horizontalSpace(8),
//                           Text(
//                             'ستحصل على ${(_scannedProductData?['buyPoints'] ?? 0) * _quantity} نقطة',
//                             style: Theme.of(builderContext)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(
//                                   color: AppTheme.accentColor,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],

//                   verticalSpace(24),

//                   // Action Buttons
//                   if (isTechnician)
//                     // Technician - Buy only
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.pop(modalContext);
//                           _handleTransaction('buy');
//                         },
//                         icon: const Icon(Icons.shopping_cart),
//                         label: const Text('شراء'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: AppTheme.accentColor,
//                           foregroundColor: Colors.white,
//                           padding: EdgeInsets.symmetric(vertical: 16.h),
//                         ),
//                       ),
//                     )
//                   else
//                     // Trader/Distributor - Buy and Sell
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton.icon(
//                             onPressed: () {
//                               Navigator.pop(modalContext);
//                               _handleTransaction('buy');
//                             },
//                             icon: const Icon(Icons.shopping_cart),
//                             label: const Text('شراء'),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: AppTheme.accentColor,
//                               side: BorderSide(color: AppTheme.accentColor),
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                             ),
//                           ),
//                         ),
//                         horizontalSpace(16),
//                         Expanded(
//                           child: ElevatedButton.icon(
//                             onPressed: () {
//                               Navigator.pop(modalContext);
//                               _handleTransaction('sell');
//                             },
//                             icon: const Icon(Icons.sell),
//                             label: const Text('بيع'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: AppTheme.successColor,
//                               foregroundColor: Colors.white,
//                               padding: EdgeInsets.symmetric(vertical: 16.h),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     ).whenComplete(() {
//       // Only update state if widget is still mounted
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//           _scannedProductData = null;
//           _quantity = 1;
//         });
//       }
//     });
//   }

//   Widget _buildProductDetail(BuildContext context, String label, String value) {
//     return Column(
//       children: [
//         Text(
//           label,
//           style: Theme.of(context)
//               .textTheme
//               .bodySmall
//               ?.copyWith(color: AppTheme.textSecondaryColor),
//         ),
//         verticalSpace(4),
//         Text(
//           value,
//           style: Theme.of(context)
//               .textTheme
//               .bodyMedium
//               ?.copyWith(fontWeight: FontWeight.w600),
//         ),
//       ],
//     );
//   }

//   void _handleTransaction(String type) {
//     if (!mounted) return;

//     final user = context.read<AuthProvider>().currentUser!;
//     final transactionProvider = context.read<TransactionProvider>();

//     // Calculate points based on transaction type
//     double pointsEarned;
//     if (type == 'buy') {
//       pointsEarned = (_scannedProductData?['buyPoints'] ?? 0.0) * _quantity;
//     } else {
//       pointsEarned = (_scannedProductData?['sellPoints'] ?? 0.0) * _quantity;
//     }

//     final transaction = transactionProvider.addTransaction(
//       userId: user.id,
//       productName: _scannedProductData?['productName'] ?? 'منتج',
//       quantity: _quantity,
//       type: type,
//       pointsEarned: pointsEarned,
//     );

//     context
//         .read<AuthProvider>()
//         .updateUserPoints(user.points + transaction.pointsEarned);

//     // Navigate back to home screen
//     if (mounted) {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         '/home',
//         (route) => false,
//       );

//       // Show success message after a small delay to ensure navigation is complete
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Row(
//                 children: [
//                   const Icon(Icons.check_circle, color: Colors.white),
//                   horizontalSpace(8),
//                   Expanded(
//                     child: Text(
//                       'تمت العملية بنجاح! حصلت على ${transaction.pointsEarned.toStringAsFixed(0)} نقطة',
//                     ),
//                   ),
//                 ],
//               ),
//               backgroundColor: AppTheme.successColor,
//               behavior: SnackBarBehavior.floating,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               duration: const Duration(seconds: 3),
//             ),
//           );
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('مسح كود QR'),
//         backgroundColor: AppTheme.primaryColor,
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: Icon(
//               _isTorchOn ? Icons.flash_on : Icons.flash_off,
//               color: _isTorchOn ? Colors.yellow : Colors.white,
//             ),
//             onPressed: () {
//               cameraController.toggleTorch();
//               if (mounted) {
//                 setState(() {
//                   _isTorchOn = !_isTorchOn;
//                 });
//               }
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.flip_camera_ios),
//             onPressed: () => cameraController.switchCamera(),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Camera Scanner
//           MobileScanner(
//             controller: cameraController,
//             onDetect: _onDetect,
//           ),

//           // Overlay
//           CustomPaint(
//             painter: ScannerOverlay(),
//             child: Container(),
//           ),

//           // Instructions
//           Positioned(
//             bottom: 100.h,
//             left: 0,
//             right: 0,
//             child: Container(
//               margin: EdgeInsets.symmetric(horizontal: 24.w),
//               padding: EdgeInsets.all(16.w),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.7),
//                 borderRadius: BorderRadius.circular(12.r),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.qr_code_scanner,
//                     color: Colors.white,
//                     size: 32.sp,
//                   ),
//                   verticalSpace(8),
//                   Text(
//                     'ضع الكود داخل الإطار',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                   verticalSpace(4),
//                   Text(
//                     'سيتم المسح تلقائياً',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.white70,
//                         ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Scanner Overlay Painter
// class ScannerOverlay extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.black.withOpacity(0.5)
//       ..style = PaintingStyle.fill;

//     final scanArea = Rect.fromCenter(
//       center: Offset(size.width / 2, size.height / 2),
//       width: 280,
//       height: 280,
//     );

//     // Draw dark overlay with cutout
//     canvas.drawPath(
//       Path.combine(
//         PathOperation.difference,
//         Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
//         Path()
//           ..addRRect(
//               RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
//           ..close(),
//       ),
//       paint,
//     );

//     // Draw corner borders
//     final borderPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 4;

//     final cornerLength = 40.0;

//     // Top-left
//     canvas.drawLine(
//       Offset(scanArea.left, scanArea.top + cornerLength),
//       Offset(scanArea.left, scanArea.top),
//       borderPaint,
//     );
//     canvas.drawLine(
//       Offset(scanArea.left, scanArea.top),
//       Offset(scanArea.left + cornerLength, scanArea.top),
//       borderPaint,
//     );

//     // Top-right
//     canvas.drawLine(
//       Offset(scanArea.right - cornerLength, scanArea.top),
//       Offset(scanArea.right, scanArea.top),
//       borderPaint,
//     );
//     canvas.drawLine(
//       Offset(scanArea.right, scanArea.top),
//       Offset(scanArea.right, scanArea.top + cornerLength),
//       borderPaint,
//     );

//     // Bottom-left
//     canvas.drawLine(
//       Offset(scanArea.left, scanArea.bottom - cornerLength),
//       Offset(scanArea.left, scanArea.bottom),
//       borderPaint,
//     );
//     canvas.drawLine(
//       Offset(scanArea.left, scanArea.bottom),
//       Offset(scanArea.left + cornerLength, scanArea.bottom),
//       borderPaint,
//     );

//     // Bottom-right
//     canvas.drawLine(
//       Offset(scanArea.right - cornerLength, scanArea.bottom),
//       Offset(scanArea.right, scanArea.bottom),
//       borderPaint,
//     );
//     canvas.drawLine(
//       Offset(scanArea.right, scanArea.bottom - cornerLength),
//       Offset(scanArea.right, scanArea.bottom),
//       borderPaint,
//     );
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => false;
// }
