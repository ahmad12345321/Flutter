

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csv/csv.dart';
// import 'package:excel/excel.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'package:intl/intl.dart';
// import 'TransactionCard.dart';
// import 'TransactionModel.dart';
// import 'AddTransactionScreen.dart';
// import 'EditTransactionScreen.dart' hide AnimatedField, FadeInUp;
// import 'trensctionhestory.dart'; // Note: Fix typo (should be transactionhistory.dart)
//
// class TransactionScreen extends StatefulWidget {
//   const TransactionScreen({super.key});
//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }
//
// class _TransactionScreenState extends State<TransactionScreen> {
//   String searchQuery = "";
//   static bool _hasRequestedPermission = false;
//   static const String _permissionKey = 'storage_permission_requested';
//   bool _isDeleting = false;
//
//   // Filter variables
//   String filterType = 'All'; // All, Daily, Monthly, Yearly, Range
//   DateTime? selectedDate;
//   int? selectedMonth;
//   int? selectedYear;
//   DateTime? startDate; // For date range
//   DateTime? endDate;   // For date range
//
//   // Delete transaction method
//   void _deleteTransaction(String id, BuildContext context) async {
//     if (_isDeleting) return;
//     setState(() {
//       _isDeleting = true;
//     });
//     try {
//       print('Attempting to delete transaction with ID: $id');
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('transactions')
//           .doc(id)
//           .get();
//       if (!docSnapshot.exists) {
//         print('Error: Document with ID $id does not exist');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Error: Transaction not found"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//       await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
//       print('Transaction with ID $id deleted successfully');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Transaction deleted successfully"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting transaction with ID $id: $e');
//       String errorMessage;
//       if (e is FirebaseException) {
//         switch (e.code) {
//           case 'permission-denied':
//             errorMessage = 'Permission denied. Please check Firestore security rules.';
//             break;
//           case 'not-found':
//             errorMessage = 'Transaction not found.';
//             break;
//           default:
//             errorMessage = 'Failed to delete transaction: ${e.message}';
//         }
//       } else {
//         errorMessage = 'Failed to delete transaction: $e';
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.redAccent,
//             duration: const Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDeleting = false;
//         });
//       }
//     }
//   }
//
//   // Permission handling methods
//   Future<bool> _checkPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_permissionKey) ?? false;
//   }
//
//   Future<void> _setPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_permissionKey, true);
//     _hasRequestedPermission = true;
//   }
//
//   Future<bool> _requestStoragePermission(BuildContext context) async {
//     if (Platform.isAndroid) {
//       if (_hasRequestedPermission || await _checkPermissionRequested()) {
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.status;
//         }
//         if (!status.isGranted) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text(
//                     "Storage permission denied. Please enable it in app settings."),
//                 backgroundColor: Colors.redAccent,
//                 action: SnackBarAction(
//                   label: 'Settings',
//                   textColor: Colors.white,
//                   onPressed: () => openAppSettings(),
//                 ),
//                 duration: const Duration(seconds: 3),
//                 behavior: SnackBarBehavior.floating,
//                 margin: const EdgeInsets.all(16),
//               ),
//             );
//           }
//           return false;
//         }
//         return true;
//       }
//
//       bool? permissionRequested = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('Storage Permission Required'),
//           content: const Text(
//               'This app needs storage access to save exported files (CSV, Excel, PDF). Please grant permission to proceed.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Deny', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Allow', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//           ],
//         ),
//       );
//
//       if (permissionRequested != true) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Storage permission denied"),
//               backgroundColor: Colors.redAccent,
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//       }
//
//       if (!status.isGranted) {
//         status = await Permission.manageExternalStorage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.request();
//         }
//       }
//
//       if (!status.isGranted) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                   "Storage permission denied. Please enable it in app settings."),
//               backgroundColor: Colors.redAccent,
//               action: SnackBarAction(
//                 label: 'Settings',
//                 textColor: Colors.white,
//                 onPressed: () => openAppSettings(),
//               ),
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       await _setPermissionRequested();
//       return true;
//     }
//     return true;
//   }
//
//   // Export confirmation dialog
//   Future<bool> _confirmExport(BuildContext context, String fileType) async {
//     bool? proceed = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Export $fileType', style: const TextStyle(fontFamily: 'Lexend')),
//         content: Text(
//           'You are about to export transactions as a $fileType file. Please select a destination to save the file.',
//           style: const TextStyle(fontFamily: 'Lexend'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Proceed',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//     return proceed ?? false;
//   }
//
//   // Date range picker for export
//   Future<bool> _selectExportDateRange(BuildContext context) async {
//     DateTime? tempStartDate;
//     DateTime? tempEndDate;
//
//     bool? confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Export Date Range', style: TextStyle(fontFamily: 'Lexend')),
//         content: SizedBox(
//           height: 400,
//           width: 300,
//           child: SfDateRangePicker(
//             view: DateRangePickerView.month,
//             selectionMode: DateRangePickerSelectionMode.range,
//             minDate: DateTime(2000),
//             maxDate: DateTime.now(),
//             headerStyle: const DateRangePickerHeaderStyle(
//               textAlign: TextAlign.center,
//               textStyle: TextStyle(
//                 fontFamily: 'Lexend',
//                 color: Color(0xFF1B0E0E),
//                 fontSize: 16,
//               ),
//             ),
//             monthViewSettings: const DateRangePickerMonthViewSettings(
//               firstDayOfWeek: 1,
//             ),
//             selectionTextStyle: const TextStyle(
//               fontFamily: 'Lexend',
//               color: Color(0xFF1B0E0E),
//             ),
//             selectionColor: const Color(0xFFE61919),
//             startRangeSelectionColor: const Color(0xFFE61919),
//             endRangeSelectionColor: const Color(0xFFE61919),
//             rangeSelectionColor: const Color(0xFFE61919).withOpacity(0.3),
//             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//               if (args.value is PickerDateRange) {
//                 tempStartDate = args.value.startDate;
//                 tempEndDate = args.value.endDate ?? args.value.startDate;
//               }
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               if (tempStartDate != null && tempEndDate != null) {
//                 startDate = tempStartDate;
//                 endDate = tempEndDate;
//                 Navigator.pop(context, true);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please select both start and end dates"),
//                     backgroundColor: Colors.redAccent,
//                     duration: Duration(seconds: 3),
//                     behavior: SnackBarBehavior.floating,
//                     margin: EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//
//     return confirmed ?? false;
//   }
//
//   // Modified export CSV with date range filtering
//   Future<void> _exportCSV() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'CSV');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     List<List<dynamic>> rows = [];
//     rows.add([
//       "Name",
//       "Date",
//       "Total Amount",
//       "Paid Amount",
//       "Is Paid",
//       "Contact No",
//       "Address"
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       rows.add([
//         data["name"]?.toString() ?? "",
//         data["date"]?.toString() ?? "",
//         data["totalAmount"]?.toString() ?? "0",
//         data["paidAmount"]?.toString() ?? "0",
//         data["isPaid"]?.toString() ?? "false",
//         data["contactNo"]?.toString() ?? "",
//         data["address"]?.toString() ?? "",
//       ]);
//     }
//
//     String csvData = const ListToCsvConverter().convert(rows);
//     final bytes = Uint8List.fromList(utf8.encode(csvData));
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.csv";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save CSV File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("CSV exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export CSV: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export Excel with date range filtering
//   Future<void> _exportExcel() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'Excel');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     var excel = Excel.createExcel();
//     Sheet sheetObject = excel["Transactions"];
//
//     sheetObject.appendRow([
//       TextCellValue("Name"),
//       TextCellValue("Date"),
//       TextCellValue("Total Amount"),
//       TextCellValue("Paid Amount"),
//       TextCellValue("Is Paid"),
//       TextCellValue("Contact No"),
//       TextCellValue("Address"),
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       sheetObject.appendRow([
//         TextCellValue(data["name"]?.toString() ?? ""),
//         TextCellValue(data["date"]?.toString() ?? ""),
//         IntCellValue((data["totalAmount"] ?? 0).toInt()),
//         IntCellValue((data["paidAmount"] ?? 0).toInt()),
//         BoolCellValue(data["isPaid"] ?? false),
//         TextCellValue(data["contactNo"]?.toString() ?? ""),
//         TextCellValue(data["address"]?.toString() ?? ""),
//       ]);
//     }
//
//     final bytes = Uint8List.fromList(excel.encode()!);
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.xlsx";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Excel File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Excel exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export Excel: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export PDF with date range filtering
//   Future<void> _exportPDF() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'PDF');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Text(
//               'Transactions Report',
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 font: pw.Font.timesBold(),
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             defaultColumnWidth: const pw.FlexColumnWidth(),
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                 children: [
//                   _buildTableCell('Name', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Date', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Total Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Paid Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Is Paid', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Contact No', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Address', isHeader: true, font: pw.Font.timesBold()),
//                 ],
//               ),
//               ...docs.map((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 return pw.TableRow(
//                   children: [
//                     _buildTableCell(data["name"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["date"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["totalAmount"]?.toString() ?? "0", font: pw.Font.times()),
//                     _buildTableCell(data["paidAmount"]?.toString() ?? "0", font: pw.Font.times()),
//                     _buildTableCell(data["isPaid"]?.toString() ?? "false", font: pw.Font.times()),
//                     _buildTableCell(data["contactNo"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["address"]?.toString() ?? "", font: pw.Font.times()),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Text(
//             'Generated on: ${DateTime.now().toString()}',
//             style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: pw.Font.times()),
//           ),
//         ],
//       ),
//     );
//
//     final bytes = await pdf.save();
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.pdf";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save PDF File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("PDF exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export PDF: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   pw.Widget _buildTableCell(String text, {bool isHeader = false, required pw.Font font}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 12,
//           font: font,
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }
//
//   // Date range picker for filtering
//   Future<void> _selectDateRange(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Date Range', style: TextStyle(fontFamily: 'Lexend')),
//         content: SizedBox(
//           height: 400,
//           width: 300,
//           child: SfDateRangePicker(
//             view: DateRangePickerView.month,
//             selectionMode: DateRangePickerSelectionMode.range,
//             minDate: DateTime(2000),
//             maxDate: DateTime.now(),
//             initialSelectedRange: startDate != null && endDate != null
//                 ? PickerDateRange(startDate, endDate)
//                 : null,
//             headerStyle: const DateRangePickerHeaderStyle(
//               textAlign: TextAlign.center,
//               textStyle: TextStyle(
//                 fontFamily: 'Lexend',
//                 color: Color(0xFF1B0E0E),
//                 fontSize: 16,
//               ),
//             ),
//             monthViewSettings: const DateRangePickerMonthViewSettings(
//               firstDayOfWeek: 1,
//             ),
//             selectionTextStyle: const TextStyle(
//               fontFamily: 'Lexend',
//               color: Color(0xFF1B0E0E),
//             ),
//             selectionColor: const Color(0xFFE61919),
//             startRangeSelectionColor: const Color(0xFFE61919),
//             endRangeSelectionColor: const Color(0xFFE61919),
//             rangeSelectionColor: const Color(0xFFE61919).withOpacity(0.3),
//             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//               if (args.value is PickerDateRange) {
//                 setState(() {
//                   startDate = args.value.startDate;
//                   endDate = args.value.endDate ?? args.value.startDate;
//                 });
//               }
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               if (startDate != null && endDate != null) {
//                 setState(() {
//                   filterType = 'Range';
//                 });
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please select both start and end dates"),
//                     backgroundColor: Colors.redAccent,
//                     duration: Duration(seconds: 3),
//                     behavior: SnackBarBehavior.floating,
//                     margin: EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Daily date picker
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   // Month/year picker
//   Future<void> _selectMonthYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//     int? tempMonth = selectedMonth ?? now.month;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Month and Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButton<int>(
//               value: tempMonth,
//               items: List.generate(12, (index) => index + 1).map((month) {
//                 return DropdownMenuItem(
//                   value: month,
//                   child: Text(
//                     DateTime(2023, month).toString().split(' ')[0].substring(5, 7),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempMonth = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//             DropdownButton<int>(
//               value: tempYear,
//               items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//                 return DropdownMenuItem(
//                   value: year,
//                   child: Text(
//                     year.toString(),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempYear = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedMonth = tempMonth;
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Year picker
//   Future<void> _selectYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: DropdownButton<int>(
//           value: tempYear,
//           items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//             return DropdownMenuItem(
//               value: year,
//               child: Text(
//                 year.toString(),
//                 style: const TextStyle(fontFamily: 'Lexend'),
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             tempYear = value;
//             setState(() {});
//           },
//           style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//           dropdownColor: Colors.white,
//           underline: Container(
//             height: 2,
//             color: const Color(0xFFE61919),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Firestore query with date range filtering
//   Stream<QuerySnapshot> _buildTransactionQuery() {
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     // Apply date-based filters
//     if (filterType == 'Daily' && selectedDate != null) {
//       final startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
//           .where('date', isLessThan: endOfDay.toIso8601String());
//     } else if (filterType == 'Monthly' && selectedMonth != null && selectedYear != null) {
//       final startOfMonth = DateTime(selectedYear!, selectedMonth!);
//       final endOfMonth =
//       DateTime(selectedYear!, selectedMonth! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
//           .where('date', isLessThan: endOfMonth.toIso8601String());
//     } else if (filterType == 'Yearly' && selectedYear != null) {
//       final startOfYear = DateTime(selectedYear!);
//       final endOfYear = DateTime(selectedYear! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfYear.toIso8601String())
//           .where('date', isLessThan: endOfYear.toIso8601String());
//     } else if (filterType == 'Range' && startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     return query.snapshots();
//   }
//
//   // Modified filter menu with Range option
//   void _showFilterMenu(BuildContext context) {
//     showMenu<String>(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//       items: <PopupMenuEntry<String>>[
//         PopupMenuItem<String>(
//           value: 'All',
//           child: Text(
//             'Filter By: All',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'All' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Daily',
//           child: Text(
//             'Filter By: Daily',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Daily' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Monthly',
//           child: Text(
//             'Filter By: Monthly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Monthly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Yearly',
//           child: Text(
//             'Filter By: Yearly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Yearly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Range',
//           child: Text(
//             'Filter By: Date Range',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Range' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//       ],
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ).then((value) {
//       if (value != null) {
//         setState(() {
//           filterType = value;
//           if (value != 'Daily') selectedDate = null;
//           if (value != 'Monthly') selectedMonth = null;
//           if (value != 'Yearly' && value != 'Monthly') selectedYear = null;
//           if (value != 'Range') {
//             startDate = null;
//             endDate = null;
//           }
//           if (value == 'Daily') _selectDate(context);
//           if (value == 'Monthly') _selectMonthYear(context);
//           if (value == 'Yearly') _selectYear(context);
//           if (value == 'Range') _selectDateRange(context);
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isMobile = screenWidth < 600;
//     final isTablet = screenWidth >= 600 && screenWidth < 900;
//     final isDesktop = screenWidth >= 900;
//
//     // Responsive padding and font sizes
//     final padding = screenWidth * (isMobile ? 0.04 : isTablet ? 0.03 : 0.02);
//     final fontSizeTitle = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
//     final fontSizeBody = isMobile ? 14.0 : isTablet ? 16.0 : 18.0;
//     final filterContainerWidth = isDesktop ? screenWidth * 0.6 : screenWidth * 0.9;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF8F8),
//       appBar: AppBar(
//         title: Text(
//           'Transactions',
//           style: TextStyle(
//             fontFamily: 'PublicSans',
//             fontWeight: FontWeight.bold,
//             fontSize: fontSizeTitle,
//             color: const Color(0xFF1B0E0E),
//           ),
//         ),
//         backgroundColor: const Color(0xFFFCF8F8),
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.file_download, color: Color(0xFFE61919)),
//             onSelected: (value) async {
//               if (value == "csv") {
//                 await _exportCSV();
//               } else if (value == "excel") {
//                 await _exportExcel();
//               } else if (value == "pdf") {
//                 await _exportPDF();
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: "csv",
//                 child: Text("Export CSV", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "excel",
//                 child: Text("Export Excel", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "pdf",
//                 child: Text("Export PDF", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//             ],
//             color: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: Column(
//                     children: [
//                       // Search Bar with Filter Icon
//                       Container(
//                         width: filterContainerWidth,
//                         padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
//                         child: AnimatedField(
//                           delay: 200,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Search by name or contact...",
//                               hintStyle: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 color: const Color(0xFF666666),
//                                 fontSize: fontSizeBody,
//                               ),
//                               prefixIcon: const Icon(Icons.search, color: Color(0xFFE61919)),
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.filter_list, color: Color(0xFFE61919)),
//                                 onPressed: () => _showFilterMenu(context),
//                               ),
//                               filled: true,
//                               fillColor: const Color(0xFFF5F6F5),
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: 'Lexend',
//                               color: const Color(0xFF1B0E0E),
//                               fontSize: fontSizeBody,
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 searchQuery = value.toLowerCase();
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       // Display selected filter
//                       if (filterType != 'All')
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
//                           child: FadeInUp(
//                             delay: 300,
//                             child: Text(
//                               filterType == 'Daily' && selectedDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
//                                   : filterType == 'Monthly' && selectedMonth != null && selectedYear != null
//                                   ? 'Selected: $selectedMonth/$selectedYear'
//                                   : filterType == 'Yearly' && selectedYear != null
//                                   ? 'Selected: $selectedYear'
//                                   : filterType == 'Range' && startDate != null && endDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} to ${DateFormat('yyyy-MM-dd').format(endDate!)}'
//                                   : '',
//                               style: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 fontSize: fontSizeBody - 2,
//                                 color: const Color(0xFF666666),
//                               ),
//                             ),
//                           ),
//                         ),
//                       // Transaction List
//                       SizedBox(
//                         height: screenHeight * (isMobile ? 0.8 : isTablet ? 0.65 : 0.7),
//                         child: StreamBuilder<QuerySnapshot>(
//                           stream: _buildTransactionQuery(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasError) {
//                               String errorMessage = "Error loading transactions: ${snapshot.error}";
//                               if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
//                                 errorMessage =
//                                 "This query requires a Firestore index. Please check the console logs or contact support.";
//                               }
//                               return Center(
//                                 child: Text(
//                                   errorMessage,
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: Colors.redAccent,
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//                               );
//                             }
//
//                             final docs = snapshot.data!.docs.where((doc) {
//                               final data = doc.data() as Map<String, dynamic>;
//                               final name = data["name"]?.toString().toLowerCase() ?? "";
//                               final contact = data["contactNo"]?.toString().toLowerCase() ?? "";
//                               return name.contains(searchQuery) || contact.contains(searchQuery);
//                             }).toList();
//
//                             if (docs.isEmpty) {
//                               return Center(
//                                 child: Text(
//                                   "No transactions available",
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: const Color(0xFF666666),
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//
//                             return ListView.builder(
//                               padding: EdgeInsets.all(padding),
//                               itemCount: docs.length,
//                               itemBuilder: (context, index) {
//                                 final transaction = TransactionModel.fromFirestore(docs[index]);
//
//                                 return AnimatedField(
//                                   delay: 200 + (index * 100),
//                                   child: TransactionCard(
//                                     id: transaction.id,
//                                     name: transaction.name,
//                                     date: transaction.date,
//                                     totalAmount: transaction.totalAmount,
//                                     paidAmount: transaction.paidAmount,
//                                     isPaid: transaction.isPaid,
//                                     contactNo: transaction.contactNo,
//                                     address: transaction.address,
//                                     padding: padding,
//                                     isLargeScreen: isDesktop || isTablet,
//                                     onEdit: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               EditTransactionScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                     onDelete: () {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             "Are you sure you want to delete this transaction?",
//                                             style: TextStyle(
//                                               fontFamily: 'Lexend',
//                                               fontSize: fontSizeBody - 2,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           backgroundColor: Colors.redAccent,
//                                           duration: const Duration(seconds: 5),
//                                           behavior: SnackBarBehavior.floating,
//                                           margin: EdgeInsets.all(padding),
//                                           action: SnackBarAction(
//                                             label: 'Delete',
//                                             textColor: Colors.white,
//                                             onPressed: () {
//                                               if (!_isDeleting) {
//                                                 _deleteTransaction(transaction.id, context);
//                                               }
//                                             },
//                                           ),
//                                           showCloseIcon: true,
//                                           closeIconColor: Colors.white,
//                                         ),
//                                       );
//                                     },
//                                     onHistory: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               TransactionHistoryScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (_isDeleting)
//             Container(
//               color: Colors.black.withOpacity(0.6),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isDeleting
//             ? null
//             : () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
//           );
//         },
//         backgroundColor: const Color(0xFFE61919),
//         child: Icon(Icons.add, size: fontSizeBody + 4, color: Colors.white),
//       ),
//     );
//   }
// }




//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csv/csv.dart';
// import 'package:excel/excel.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'TransactionCard.dart';
// import 'TransactionModel.dart';
// import 'AddTransactionScreen.dart';
// import 'EditTransactionScreen.dart' hide AnimatedField, FadeInUp;
// import 'trensctionhestory.dart'; // Note: Fix typo (should be transactionhistory.dart)
//
// class TransactionScreen extends StatefulWidget {
//   const TransactionScreen({super.key});
//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }
//
// class _TransactionScreenState extends State<TransactionScreen> {
//   String searchQuery = "";
//   static bool _hasRequestedPermission = false;
//   static const String _permissionKey = 'storage_permission_requested';
//   bool _isDeleting = false;
//
//   // Filter variables
//   String filterType = 'All'; // All, Daily, Monthly, Yearly, Range
//   DateTime? selectedDate;
//   int? selectedMonth;
//   int? selectedYear;
//   DateTime? startDate; // For date range
//   DateTime? endDate;   // For date range
//
//   // Delete transaction method
//   void _deleteTransaction(String id, BuildContext context) async {
//     if (_isDeleting) return;
//     setState(() {
//       _isDeleting = true;
//     });
//     try {
//       print('Attempting to delete transaction with ID: $id');
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('transactions')
//           .doc(id)
//           .get();
//       if (!docSnapshot.exists) {
//         print('Error: Document with ID $id does not exist');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Error: Transaction not found"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//       await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
//       print('Transaction with ID $id deleted successfully');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Transaction deleted successfully"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting transaction with ID $id: $e');
//       String errorMessage;
//       if (e is FirebaseException) {
//         switch (e.code) {
//           case 'permission-denied':
//             errorMessage = 'Permission denied. Please check Firestore security rules.';
//             break;
//           case 'not-found':
//             errorMessage = 'Transaction not found.';
//             break;
//           default:
//             errorMessage = 'Failed to delete transaction: ${e.message}';
//         }
//       } else {
//         errorMessage = 'Failed to delete transaction: $e';
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.redAccent,
//             duration: const Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDeleting = false;
//         });
//       }
//     }
//   }
//
//   // Permission handling methods
//   Future<bool> _checkPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_permissionKey) ?? false;
//   }
//
//   Future<void> _setPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_permissionKey, true);
//     _hasRequestedPermission = true;
//   }
//
//   Future<bool> _requestStoragePermission(BuildContext context) async {
//     if (Platform.isAndroid) {
//       if (_hasRequestedPermission || await _checkPermissionRequested()) {
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.status;
//         }
//         if (!status.isGranted) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text(
//                     "Storage permission denied. Please enable it in app settings."),
//                 backgroundColor: Colors.redAccent,
//                 action: SnackBarAction(
//                   label: 'Settings',
//                   textColor: Colors.white,
//                   onPressed: () => openAppSettings(),
//                 ),
//                 duration: const Duration(seconds: 3),
//                 behavior: SnackBarBehavior.floating,
//                 margin: const EdgeInsets.all(16),
//               ),
//             );
//           }
//           return false;
//         }
//         return true;
//       }
//
//       bool? permissionRequested = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('Storage Permission Required'),
//           content: const Text(
//               'This app needs storage access to save exported files (CSV, Excel, PDF). Please grant permission to proceed.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Deny', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Allow', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//           ],
//         ),
//       );
//
//       if (permissionRequested != true) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Storage permission denied"),
//               backgroundColor: Colors.redAccent,
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//       }
//
//       if (!status.isGranted) {
//         status = await Permission.manageExternalStorage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.request();
//         }
//       }
//
//       if (!status.isGranted) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                   "Storage permission denied. Please enable it in app settings."),
//               backgroundColor: Colors.redAccent,
//               action: SnackBarAction(
//                 label: 'Settings',
//                 textColor: Colors.white,
//                 onPressed: () => openAppSettings(),
//               ),
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       await _setPermissionRequested();
//       return true;
//     }
//     return true;
//   }
//
//   // Export confirmation dialog
//   Future<bool> _confirmExport(BuildContext context, String fileType) async {
//     bool? proceed = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Export $fileType', style: const TextStyle(fontFamily: 'Lexend')),
//         content: Text(
//           'You are about to export transactions as a $fileType file. Please select a destination to save the file.',
//           style: const TextStyle(fontFamily: 'Lexend'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Proceed',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//     return proceed ?? false;
//   }
//
//   // Date pickers for export
//   Future<bool> _selectExportDateRange(BuildContext context) async {
//     DateTime? tempStartDate;
//     DateTime? tempEndDate;
//
//     // First date picker for start date
//     tempStartDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (tempStartDate == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Start date not selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     // Second date picker for end date
//     tempEndDate = await showDatePicker(
//       context: context,
//       initialDate: tempStartDate,
//       firstDate: tempStartDate,
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (tempEndDate == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("End date not selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     // Validate that end date is not before start date
//     if (tempEndDate.isBefore(tempStartDate)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("End date cannot be before start date"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     setState(() {
//       startDate = tempStartDate;
//       endDate = tempEndDate;
//     });
//     return true;
//   }
//
//   // Modified export CSV with date range filtering
//   Future<void> _exportCSV() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'CSV');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     List<List<dynamic>> rows = [];
//     rows.add([
//       "Name",
//       "Date",
//       "Total Amount",
//       "Paid Amount",
//       "Is Paid",
//       "Contact No",
//       "Address"
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       rows.add([
//         data["name"]?.toString() ?? "",
//         data["date"]?.toString() ?? "",
//         data["totalAmount"]?.toString() ?? "0",
//         data["paidAmount"]?.toString() ?? "0",
//         data["isPaid"]?.toString() ?? "false",
//         data["contactNo"]?.toString() ?? "",
//         data["address"]?.toString() ?? "",
//       ]);
//     }
//
//     String csvData = const ListToCsvConverter().convert(rows);
//     final bytes = Uint8List.fromList(utf8.encode(csvData));
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.csv";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save CSV File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("CSV exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export CSV: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export Excel with date range filtering
//   Future<void> _exportExcel() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'Excel');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     var excel = Excel.createExcel();
//     Sheet sheetObject = excel["Transactions"];
//
//     sheetObject.appendRow([
//       TextCellValue("Name"),
//       TextCellValue("Date"),
//       TextCellValue("Total Amount"),
//       TextCellValue("Paid Amount"),
//       TextCellValue("Is Paid"),
//       TextCellValue("Contact No"),
//       TextCellValue("Address"),
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       sheetObject.appendRow([
//         TextCellValue(data["name"]?.toString() ?? ""),
//         TextCellValue(data["date"]?.toString() ?? ""),
//         IntCellValue((data["totalAmount"] ?? 0).toInt()),
//         IntCellValue((data["paidAmount"] ?? 0).toInt()),
//         BoolCellValue(data["isPaid"] ?? false),
//         TextCellValue(data["contactNo"]?.toString() ?? ""),
//         TextCellValue(data["address"]?.toString() ?? ""),
//       ]);
//     }
//
//     final bytes = Uint8List.fromList(excel.encode()!);
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.xlsx";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Excel File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Excel exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export Excel: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export PDF with date range filtering
//   Future<void> _exportPDF() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'PDF');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Text(
//               'Transactions Report',
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 font: pw.Font.timesBold(),
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             defaultColumnWidth: const pw.FlexColumnWidth(),
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                 children: [
//                   _buildTableCell('Name', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Date', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Total Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Paid Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Is Paid', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Contact No', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Address', isHeader: true, font: pw.Font.timesBold()),
//                 ],
//               ),
//               ...docs.map((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 return pw.TableRow(
//                   children: [
//                     _buildTableCell(data["name"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["date"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["totalAmount"]?.toString() ?? "0", font: pw.Font.times()),
//                     _buildTableCell(data["paidAmount"]?.toString() ?? "0", font: pw.Font.times()),
//                     _buildTableCell(data["isPaid"]?.toString() ?? "false", font: pw.Font.times()),
//                     _buildTableCell(data["contactNo"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["address"]?.toString() ?? "", font: pw.Font.times()),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Text(
//             'Generated on: ${DateTime.now().toString()}',
//             style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: pw.Font.times()),
//           ),
//         ],
//       ),
//     );
//
//     final bytes = await pdf.save();
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.pdf";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save PDF File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("PDF exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export PDF: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   pw.Widget _buildTableCell(String text, {bool isHeader = false, required pw.Font font}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 12,
//           font: font,
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }
//
//   // Date range picker for filtering (using SfDateRangePicker)
//   Future<void> _selectDateRange(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Date Range', style: TextStyle(fontFamily: 'Lexend')),
//         content: SizedBox(
//           height: 400,
//           width: 300,
//           child: SfDateRangePicker(
//             view: DateRangePickerView.month,
//             selectionMode: DateRangePickerSelectionMode.range,
//             minDate: DateTime(2000),
//             maxDate: DateTime.now(),
//             initialSelectedRange: startDate != null && endDate != null
//                 ? PickerDateRange(startDate, endDate)
//                 : null,
//             headerStyle: const DateRangePickerHeaderStyle(
//               textAlign: TextAlign.center,
//               textStyle: TextStyle(
//                 fontFamily: 'Lexend',
//                 color: Color(0xFF1B0E0E),
//                 fontSize: 16,
//               ),
//             ),
//             monthViewSettings: const DateRangePickerMonthViewSettings(
//               firstDayOfWeek: 1,
//             ),
//             selectionTextStyle: const TextStyle(
//               fontFamily: 'Lexend',
//               color: Color(0xFF1B0E0E),
//             ),
//             selectionColor: const Color(0xFFE61919),
//             startRangeSelectionColor: const Color(0xFFE61919),
//             endRangeSelectionColor: const Color(0xFFE61919),
//             rangeSelectionColor: const Color(0xFFE61919).withOpacity(0.3),
//             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//               if (args.value is PickerDateRange) {
//                 setState(() {
//                   startDate = args.value.startDate;
//                   endDate = args.value.endDate ?? args.value.startDate;
//                 });
//               }
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               if (startDate != null && endDate != null) {
//                 setState(() {
//                   filterType = 'Range';
//                 });
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please select both start and end dates"),
//                     backgroundColor: Colors.redAccent,
//                     duration: Duration(seconds: 3),
//                     behavior: SnackBarBehavior.floating,
//                     margin: EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Daily date picker
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   // Month/year picker
//   Future<void> _selectMonthYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//     int? tempMonth = selectedMonth ?? now.month;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Month and Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButton<int>(
//               value: tempMonth,
//               items: List.generate(12, (index) => index + 1).map((month) {
//                 return DropdownMenuItem(
//                   value: month,
//                   child: Text(
//                     DateTime(2023, month).toString().split(' ')[0].substring(5, 7),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempMonth = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//             DropdownButton<int>(
//               value: tempYear,
//               items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//                 return DropdownMenuItem(
//                   value: year,
//                   child: Text(
//                     year.toString(),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempYear = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedMonth = tempMonth;
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Year picker
//   Future<void> _selectYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: DropdownButton<int>(
//           value: tempYear,
//           items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//             return DropdownMenuItem(
//               value: year,
//               child: Text(
//                 year.toString(),
//                 style: const TextStyle(fontFamily: 'Lexend'),
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             tempYear = value;
//             setState(() {});
//           },
//           style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//           dropdownColor: Colors.white,
//           underline: Container(
//             height: 2,
//             color: const Color(0xFFE61919),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Firestore query with date range filtering
//   Stream<QuerySnapshot> _buildTransactionQuery() {
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     // Apply date-based filters
//     if (filterType == 'Daily' && selectedDate != null) {
//       final startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
//           .where('date', isLessThan: endOfDay.toIso8601String());
//     } else if (filterType == 'Monthly' && selectedMonth != null && selectedYear != null) {
//       final startOfMonth = DateTime(selectedYear!, selectedMonth!);
//       final endOfMonth =
//       DateTime(selectedYear!, selectedMonth! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
//           .where('date', isLessThan: endOfMonth.toIso8601String());
//     } else if (filterType == 'Yearly' && selectedYear != null) {
//       final startOfYear = DateTime(selectedYear!);
//       final endOfYear = DateTime(selectedYear! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfYear.toIso8601String())
//           .where('date', isLessThan: endOfYear.toIso8601String());
//     } else if (filterType == 'Range' && startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     return query.snapshots();
//   }
//
//   // Modified filter menu with Range option
//   void _showFilterMenu(BuildContext context) {
//     showMenu<String>(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//       items: <PopupMenuEntry<String>>[
//         PopupMenuItem<String>(
//           value: 'All',
//           child: Text(
//             'Filter By: All',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'All' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Daily',
//           child: Text(
//             'Filter By: Daily',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Daily' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Monthly',
//           child: Text(
//             'Filter By: Monthly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Monthly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Yearly',
//           child: Text(
//             'Filter By: Yearly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Yearly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Range',
//           child: Text(
//             'Filter By: Date Range',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Range' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//       ],
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ).then((value) {
//       if (value != null) {
//         setState(() {
//           filterType = value;
//           if (value != 'Daily') selectedDate = null;
//           if (value != 'Monthly') selectedMonth = null;
//           if (value != 'Yearly' && value != 'Monthly') selectedYear = null;
//           if (value != 'Range') {
//             startDate = null;
//             endDate = null;
//           }
//           if (value == 'Daily') _selectDate(context);
//           if (value == 'Monthly') _selectMonthYear(context);
//           if (value == 'Yearly') _selectYear(context);
//           if (value == 'Range') _selectDateRange(context);
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isMobile = screenWidth < 600;
//     final isTablet = screenWidth >= 600 && screenWidth < 900;
//     final isDesktop = screenWidth >= 900;
//
//     // Responsive padding and font sizes
//     final padding = screenWidth * (isMobile ? 0.04 : isTablet ? 0.03 : 0.02);
//     final fontSizeTitle = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
//     final fontSizeBody = isMobile ? 14.0 : isTablet ? 16.0 : 18.0;
//     final filterContainerWidth = isDesktop ? screenWidth * 0.6 : screenWidth * 0.9;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF8F8),
//       appBar: AppBar(
//         title: Text(
//           'Transactions',
//           style: TextStyle(
//             fontFamily: 'PublicSans',
//             fontWeight: FontWeight.bold,
//             fontSize: fontSizeTitle,
//             color: const Color(0xFF1B0E0E),
//           ),
//         ),
//         backgroundColor: const Color(0xFFFCF8F8),
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.file_download, color: Color(0xFFE61919)),
//             onSelected: (value) async {
//               if (value == "csv") {
//                 await _exportCSV();
//               } else if (value == "excel") {
//                 await _exportExcel();
//               } else if (value == "pdf") {
//                 await _exportPDF();
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: "csv",
//                 child: Text("Export CSV", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "excel",
//                 child: Text("Export Excel", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "pdf",
//                 child: Text("Export PDF", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//             ],
//             color: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: Column(
//                     children: [
//                       // Search Bar with Filter Icon
//                       Container(
//                         width: filterContainerWidth,
//                         padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
//                         child: AnimatedField(
//                           delay: 200,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Search by name or contact...",
//                               hintStyle: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 color: const Color(0xFF666666),
//                                 fontSize: fontSizeBody,
//                               ),
//                               prefixIcon: const Icon(Icons.search, color: Color(0xFFE61919)),
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.filter_list, color: Color(0xFFE61919)),
//                                 onPressed: () => _showFilterMenu(context),
//                               ),
//                               filled: true,
//                               fillColor: const Color(0xFFF5F6F5),
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: 'Lexend',
//                               color: const Color(0xFF1B0E0E),
//                               fontSize: fontSizeBody,
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 searchQuery = value.toLowerCase();
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       // Display selected filter
//                       if (filterType != 'All')
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
//                           child: FadeInUp(
//                             delay: 300,
//                             child: Text(
//                               filterType == 'Daily' && selectedDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
//                                   : filterType == 'Monthly' && selectedMonth != null && selectedYear != null
//                                   ? 'Selected: $selectedMonth/$selectedYear'
//                                   : filterType == 'Yearly' && selectedYear != null
//                                   ? 'Selected: $selectedYear'
//                                   : filterType == 'Range' && startDate != null && endDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} to ${DateFormat('yyyy-MM-dd').format(endDate!)}'
//                                   : '',
//                               style: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 fontSize: fontSizeBody - 2,
//                                 color: const Color(0xFF666666),
//                               ),
//                             ),
//                           ),
//                         ),
//                       // Transaction List
//                       SizedBox(
//                         height: screenHeight * (isMobile ? 0.8 : isTablet ? 0.65 : 0.7),
//                         child: StreamBuilder<QuerySnapshot>(
//                           stream: _buildTransactionQuery(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasError) {
//                               String errorMessage = "Error loading transactions: ${snapshot.error}";
//                               if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
//                                 errorMessage =
//                                 "This query requires a Firestore index. Please check the console logs or contact support.";
//                               }
//                               return Center(
//                                 child: Text(
//                                   errorMessage,
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: Colors.redAccent,
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//                               );
//                             }
//
//                             final docs = snapshot.data!.docs.where((doc) {
//                               final data = doc.data() as Map<String, dynamic>;
//                               final name = data["name"]?.toString().toLowerCase() ?? "";
//                               final contact = data["contactNo"]?.toString().toLowerCase() ?? "";
//                               return name.contains(searchQuery) || contact.contains(searchQuery);
//                             }).toList();
//
//                             if (docs.isEmpty) {
//                               return Center(
//                                 child: Text(
//                                   "No transactions available",
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: const Color(0xFF666666),
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//
//                             return ListView.builder(
//                               padding: EdgeInsets.all(padding),
//                               itemCount: docs.length,
//                               itemBuilder: (context, index) {
//                                 final transaction = TransactionModel.fromFirestore(docs[index]);
//
//                                 return AnimatedField(
//                                   delay: 200 + (index * 100),
//                                   child: TransactionCard(
//                                     id: transaction.id,
//                                     name: transaction.name,
//                                     date: transaction.date,
//                                     totalAmount: transaction.totalAmount,
//                                     paidAmount: transaction.paidAmount,
//                                     isPaid: transaction.isPaid,
//                                     contactNo: transaction.contactNo,
//                                     address: transaction.address,
//                                     padding: padding,
//                                     isLargeScreen: isDesktop || isTablet,
//                                     onEdit: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               EditTransactionScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                     onDelete: () {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             "Are you sure you want to delete this transaction?",
//                                             style: TextStyle(
//                                               fontFamily: 'Lexend',
//                                               fontSize: fontSizeBody - 2,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           backgroundColor: Colors.redAccent,
//                                           duration: const Duration(seconds: 5),
//                                           behavior: SnackBarBehavior.floating,
//                                           margin: EdgeInsets.all(padding),
//                                           action: SnackBarAction(
//                                             label: 'Delete',
//                                             textColor: Colors.white,
//                                             onPressed: () {
//                                               if (!_isDeleting) {
//                                                 _deleteTransaction(transaction.id, context);
//                                               }
//                                             },
//                                           ),
//                                           showCloseIcon: true,
//                                           closeIconColor: Colors.white,
//                                         ),
//                                       );
//                                     },
//                                     onHistory: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               TransactionHistoryScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (_isDeleting)
//             Container(
//               color: Colors.black.withOpacity(0.6),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isDeleting
//             ? null
//             : () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
//           );
//         },
//         backgroundColor: const Color(0xFFE61919),
//         child: Icon(Icons.add, size: fontSizeBody + 4, color: Colors.white),
//       ),
//     );
//   }
// }




//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:csv/csv.dart';
// import 'package:excel/excel.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_datepicker/datepicker.dart';
// import 'TransactionCard.dart';
// import 'TransactionModel.dart';
// import 'AddTransactionScreen.dart';
// import 'EditTransactionScreen.dart' hide AnimatedField, FadeInUp;
// import 'trensctionhestory.dart'; // Note: Fix typo (should be transactionhistory.dart)
//
// class TransactionScreen extends StatefulWidget {
//   const TransactionScreen({super.key});
//   @override
//   State<TransactionScreen> createState() => _TransactionScreenState();
// }
//
// class _TransactionScreenState extends State<TransactionScreen> {
//   String searchQuery = "";
//   static bool _hasRequestedPermission = false;
//   static const String _permissionKey = 'storage_permission_requested';
//   bool _isDeleting = false;
//
//   // Filter variables
//   String filterType = 'All'; // All, Daily, Monthly, Yearly, Range
//   DateTime? selectedDate;
//   int? selectedMonth;
//   int? selectedYear;
//   DateTime? startDate; // For date range
//   DateTime? endDate;   // For date range
//
//   // Delete transaction method
//   void _deleteTransaction(String id, BuildContext context) async {
//     if (_isDeleting) return;
//     setState(() {
//       _isDeleting = true;
//     });
//     try {
//       print('Attempting to delete transaction with ID: $id');
//       final docSnapshot = await FirebaseFirestore.instance
//           .collection('transactions')
//           .doc(id)
//           .get();
//       if (!docSnapshot.exists) {
//         print('Error: Document with ID $id does not exist');
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Error: Transaction not found"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//       await FirebaseFirestore.instance.collection('transactions').doc(id).delete();
//       print('Transaction with ID $id deleted successfully');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Transaction deleted successfully"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting transaction with ID $id: $e');
//       String errorMessage;
//       if (e is FirebaseException) {
//         switch (e.code) {
//           case 'permission-denied':
//             errorMessage = 'Permission denied. Please check Firestore security rules.';
//             break;
//           case 'not-found':
//             errorMessage = 'Transaction not found.';
//             break;
//           default:
//             errorMessage = 'Failed to delete transaction: ${e.message}';
//         }
//       } else {
//         errorMessage = 'Failed to delete transaction: $e';
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(errorMessage),
//             backgroundColor: Colors.redAccent,
//             duration: const Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: const EdgeInsets.all(16),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isDeleting = false;
//         });
//       }
//     }
//   }
//
//   // Permission handling methods
//   Future<bool> _checkPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_permissionKey) ?? false;
//   }
//
//   Future<void> _setPermissionRequested() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_permissionKey, true);
//     _hasRequestedPermission = true;
//   }
//
//   Future<bool> _requestStoragePermission(BuildContext context) async {
//     if (Platform.isAndroid) {
//       if (_hasRequestedPermission || await _checkPermissionRequested()) {
//         var status = await Permission.storage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.status;
//         }
//         if (!status.isGranted) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: const Text(
//                     "Storage permission denied. Please enable it in app settings."),
//                 backgroundColor: Colors.redAccent,
//                 action: SnackBarAction(
//                   label: 'Settings',
//                   textColor: Colors.white,
//                   onPressed: () => openAppSettings(),
//                 ),
//                 duration: const Duration(seconds: 3),
//                 behavior: SnackBarBehavior.floating,
//                 margin: const EdgeInsets.all(16),
//               ),
//             );
//           }
//           return false;
//         }
//         return true;
//       }
//
//       bool? permissionRequested = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) => AlertDialog(
//           title: const Text('Storage Permission Required'),
//           content: const Text(
//               'This app needs storage access to save exported files (CSV, Excel, PDF). Please grant permission to proceed.'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: const Text('Deny', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//             TextButton(
//               onPressed: () => Navigator.pop(context, true),
//               child: const Text('Allow', style: TextStyle(fontFamily: 'Lexend')),
//             ),
//           ],
//         ),
//       );
//
//       if (permissionRequested != true) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Storage permission denied"),
//               backgroundColor: Colors.redAccent,
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       var status = await Permission.storage.status;
//       if (!status.isGranted) {
//         status = await Permission.storage.request();
//       }
//
//       if (!status.isGranted) {
//         status = await Permission.manageExternalStorage.status;
//         if (!status.isGranted) {
//           status = await Permission.manageExternalStorage.request();
//         }
//       }
//
//       if (!status.isGranted) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text(
//                   "Storage permission denied. Please enable it in app settings."),
//               backgroundColor: Colors.redAccent,
//               action: SnackBarAction(
//                 label: 'Settings',
//                 textColor: Colors.white,
//                 onPressed: () => openAppSettings(),
//               ),
//               duration: const Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: const EdgeInsets.all(16),
//             ),
//           );
//         }
//         await _setPermissionRequested();
//         return false;
//       }
//
//       await _setPermissionRequested();
//       return true;
//     }
//     return true;
//   }
//
//   // Export confirmation dialog
//   Future<bool> _confirmExport(BuildContext context, String fileType) async {
//     bool? proceed = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: Text('Export $fileType', style: const TextStyle(fontFamily: 'Lexend')),
//         content: Text(
//           'You are about to export transactions as a $fileType file. Please select a destination to save the file.',
//           style: const TextStyle(fontFamily: 'Lexend'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Proceed',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//     return proceed ?? false;
//   }
//
//   // Date pickers for export
//   Future<bool> _selectExportDateRange(BuildContext context) async {
//     DateTime? tempStartDate;
//     DateTime? tempEndDate;
//
//     // First date picker for start date
//     tempStartDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (tempStartDate == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Start date not selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     // Second date picker for end date
//     tempEndDate = await showDatePicker(
//       context: context,
//       initialDate: tempStartDate,
//       firstDate: tempStartDate,
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (tempEndDate == null) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("End date not selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     // Validate that end date is not before start date
//     if (tempEndDate.isBefore(tempStartDate)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("End date cannot be before start date"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return false;
//     }
//
//     setState(() {
//       startDate = tempStartDate;
//       endDate = tempEndDate;
//     });
//     return true;
//   }
//
//   // Modified export CSV with date range filtering and remaining amount
//   Future<void> _exportCSV() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'CSV');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     List<List<dynamic>> rows = [];
//     rows.add([
//       "Name",
//       "Date",
//       "Total Amount",
//       "Paid Amount",
//       "Remaining Amount",
//       "Is Paid",
//       "Contact No",
//       "Address"
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final totalAmount = (data["totalAmount"] as num?)?.toDouble() ?? 0.0;
//       final paidAmount = (data["paidAmount"] as num?)?.toDouble() ?? 0.0;
//       final remainingAmount = totalAmount - paidAmount;
//       rows.add([
//         data["name"]?.toString() ?? "",
//         data["date"]?.toString() ?? "",
//         totalAmount.toString(),
//         paidAmount.toString(),
//         remainingAmount.toString(),
//         data["isPaid"]?.toString() ?? "false",
//         data["contactNo"]?.toString() ?? "",
//         data["address"]?.toString() ?? "",
//       ]);
//     }
//
//     String csvData = const ListToCsvConverter().convert(rows);
//     final bytes = Uint8List.fromList(utf8.encode(csvData));
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.csv";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save CSV File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("CSV exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export CSV: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export Excel with date range filtering and remaining amount
//   Future<void> _exportExcel() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'Excel');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     var excel = Excel.createExcel();
//     Sheet sheetObject = excel["Transactions"];
//
//     sheetObject.appendRow([
//       TextCellValue("Name"),
//       TextCellValue("Date"),
//       TextCellValue("Total Amount"),
//       TextCellValue("Paid Amount"),
//       TextCellValue("Remaining Amount"),
//       TextCellValue("Is Paid"),
//       TextCellValue("Contact No"),
//       TextCellValue("Address"),
//     ]);
//
//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final totalAmount = (data["totalAmount"] as num?)?.toDouble() ?? 0.0;
//       final paidAmount = (data["paidAmount"] as num?)?.toDouble() ?? 0.0;
//       final remainingAmount = totalAmount - paidAmount;
//       sheetObject.appendRow([
//         TextCellValue(data["name"]?.toString() ?? ""),
//         TextCellValue(data["date"]?.toString() ?? ""),
//         IntCellValue(totalAmount.toInt()),
//         IntCellValue(paidAmount.toInt()),
//         IntCellValue(remainingAmount.toInt()),
//         BoolCellValue(data["isPaid"] ?? false),
//         TextCellValue(data["contactNo"]?.toString() ?? ""),
//         TextCellValue(data["address"]?.toString() ?? ""),
//       ]);
//     }
//
//     final bytes = Uint8List.fromList(excel.encode()!);
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.xlsx";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save Excel File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Excel exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export Excel: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   // Modified export PDF with date range filtering, remaining amount, and Paid/Unpaid status
//   Future<void> _exportPDF() async {
//     bool dateRangeSelected = await _selectExportDateRange(context);
//     if (!dateRangeSelected) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled: No date range selected"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool proceed = await _confirmExport(context, 'PDF');
//     if (!proceed) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Export cancelled"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//       return;
//     }
//
//     bool permissionGranted = await _requestStoragePermission(context);
//     if (!permissionGranted) return;
//
//     // Fetch filtered data
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     if (startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     final snapshot = await query.get();
//     final docs = snapshot.docs;
//
//     final pdf = pw.Document();
//
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(32),
//         build: (pw.Context context) => [
//           pw.Header(
//             level: 0,
//             child: pw.Text(
//               'Transactions Report',
//               style: pw.TextStyle(
//                 fontSize: 24,
//                 font: pw.Font.timesBold(),
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 20),
//           pw.Table(
//             border: pw.TableBorder.all(),
//             defaultColumnWidth: const pw.FlexColumnWidth(),
//             children: [
//               pw.TableRow(
//                 decoration: const pw.BoxDecoration(color: PdfColors.grey200),
//                 children: [
//                   _buildTableCell('Name', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Date', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Total Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Paid Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Remaining Amount', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Is Paid', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Contact No', isHeader: true, font: pw.Font.timesBold()),
//                   _buildTableCell('Address', isHeader: true, font: pw.Font.timesBold()),
//                 ],
//               ),
//               ...docs.map((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final totalAmount = (data["totalAmount"] as num?)?.toDouble() ?? 0.0;
//                 final paidAmount = (data["paidAmount"] as num?)?.toDouble() ?? 0.0;
//                 final remainingAmount = totalAmount - paidAmount;
//                 final isPaid = data["isPaid"] as bool? ?? false;
//                 return pw.TableRow(
//                   children: [
//                     _buildTableCell(data["name"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["date"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(totalAmount.toString(), font: pw.Font.times()),
//                     _buildTableCell(paidAmount.toString(), font: pw.Font.times()),
//                     _buildTableCell(remainingAmount.toString(), font: pw.Font.times()),
//                     _buildTableCell(isPaid ? "Paid" : "Unpaid", font: pw.Font.times()),
//                     _buildTableCell(data["contactNo"]?.toString() ?? "", font: pw.Font.times()),
//                     _buildTableCell(data["address"]?.toString() ?? "", font: pw.Font.times()),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//           pw.SizedBox(height: 20),
//           pw.Text(
//             'Generated on: ${DateTime.now().toString()}',
//             style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: pw.Font.times()),
//           ),
//         ],
//       ),
//     );
//
//     final bytes = await pdf.save();
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final fileName = "transactions_$timestamp.pdf";
//
//     try {
//       String? outputFile = await FilePicker.platform.saveFile(
//         dialogTitle: 'Save PDF File',
//         fileName: fileName,
//         bytes: bytes,
//       );
//
//       if (outputFile == null) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Export cancelled"),
//               backgroundColor: Colors.redAccent,
//               duration: Duration(seconds: 3),
//               behavior: SnackBarBehavior.floating,
//               margin: EdgeInsets.all(16),
//             ),
//           );
//         }
//         return;
//       }
//
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("PDF exported to $outputFile"),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Failed to export PDF: $e"),
//             backgroundColor: Colors.redAccent,
//             duration: Duration(seconds: 3),
//             behavior: SnackBarBehavior.floating,
//             margin: EdgeInsets.all(16),
//           ),
//         );
//       }
//     }
//   }
//
//   pw.Widget _buildTableCell(String text, {bool isHeader = false, required pw.Font font}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.all(8),
//       child: pw.Text(
//         text,
//         style: pw.TextStyle(
//           fontSize: 12,
//           font: font,
//           fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
//         ),
//       ),
//     );
//   }
//
//   // Date range picker for filtering (using SfDateRangePicker)
//   Future<void> _selectDateRange(BuildContext context) async {
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Date Range', style: TextStyle(fontFamily: 'Lexend')),
//         content: SizedBox(
//           height: 400,
//           width: 300,
//           child: SfDateRangePicker(
//             view: DateRangePickerView.month,
//             selectionMode: DateRangePickerSelectionMode.range,
//             minDate: DateTime(2000),
//             maxDate: DateTime.now(),
//             initialSelectedRange: startDate != null && endDate != null
//                 ? PickerDateRange(startDate, endDate)
//                 : null,
//             headerStyle: const DateRangePickerHeaderStyle(
//               textAlign: TextAlign.center,
//               textStyle: TextStyle(
//                 fontFamily: 'Lexend',
//                 color: Color(0xFF1B0E0E),
//                 fontSize: 16,
//               ),
//             ),
//             monthViewSettings: const DateRangePickerMonthViewSettings(
//               firstDayOfWeek: 1,
//             ),
//             selectionTextStyle: const TextStyle(
//               fontFamily: 'Lexend',
//               color: Color(0xFF1B0E0E),
//             ),
//             selectionColor: const Color(0xFFE61919),
//             startRangeSelectionColor: const Color(0xFFE61919),
//             endRangeSelectionColor: const Color(0xFFE61919),
//             rangeSelectionColor: const Color(0xFFE61919).withOpacity(0.3),
//             onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
//               if (args.value is PickerDateRange) {
//                 setState(() {
//                   startDate = args.value.startDate;
//                   endDate = args.value.endDate ?? args.value.startDate;
//                 });
//               }
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               if (startDate != null && endDate != null) {
//                 setState(() {
//                   filterType = 'Range';
//                 });
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("Please select both start and end dates"),
//                     backgroundColor: Colors.redAccent,
//                     duration: Duration(seconds: 3),
//                     behavior: SnackBarBehavior.floating,
//                     margin: EdgeInsets.all(16),
//                   ),
//                 );
//               }
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Daily date picker
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFE61919),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1B0E0E),
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: const Color(0xFFE61919),
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   // Month/year picker
//   Future<void> _selectMonthYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//     int? tempMonth = selectedMonth ?? now.month;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Month and Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             DropdownButton<int>(
//               value: tempMonth,
//               items: List.generate(12, (index) => index + 1).map((month) {
//                 return DropdownMenuItem(
//                   value: month,
//                   child: Text(
//                     DateTime(2023, month).toString().split(' ')[0].substring(5, 7),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempMonth = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//             DropdownButton<int>(
//               value: tempYear,
//               items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//                 return DropdownMenuItem(
//                   value: year,
//                   child: Text(
//                     year.toString(),
//                     style: const TextStyle(fontFamily: 'Lexend'),
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 tempYear = value;
//                 setState(() {});
//               },
//               style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//               dropdownColor: Colors.white,
//               underline: Container(
//                 height: 2,
//                 color: const Color(0xFFE61919),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedMonth = tempMonth;
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Year picker
//   Future<void> _selectYear(BuildContext context) async {
//     final now = DateTime.now();
//     int? tempYear = selectedYear ?? now.year;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Select Year', style: TextStyle(fontFamily: 'Lexend')),
//         content: DropdownButton<int>(
//           value: tempYear,
//           items: List.generate(100, (index) => now.year - 50 + index).map((year) {
//             return DropdownMenuItem(
//               value: year,
//               child: Text(
//                 year.toString(),
//                 style: const TextStyle(fontFamily: 'Lexend'),
//               ),
//             );
//           }).toList(),
//           onChanged: (value) {
//             tempYear = value;
//             setState(() {});
//           },
//           style: const TextStyle(fontFamily: 'Lexend', color: Color(0xFF1B0E0E)),
//           dropdownColor: Colors.white,
//           underline: Container(
//             height: 2,
//             color: const Color(0xFFE61919),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFFE61919))),
//           ),
//           TextButton(
//             onPressed: () {
//               setState(() {
//                 selectedYear = tempYear;
//               });
//               Navigator.pop(context);
//             },
//             child: const Text('OK',
//                 style: TextStyle(fontFamily: 'Lexend', color: Color(0xFF1877F2))),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Firestore query with date range filtering
//   Stream<QuerySnapshot> _buildTransactionQuery() {
//     Query<Map<String, dynamic>> query = FirebaseFirestore.instance
//         .collection('transactions')
//         .orderBy('date', descending: true);
//
//     // Apply date-based filters
//     if (filterType == 'Daily' && selectedDate != null) {
//       final startOfDay = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day);
//       final endOfDay = startOfDay.add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
//           .where('date', isLessThan: endOfDay.toIso8601String());
//     } else if (filterType == 'Monthly' && selectedMonth != null && selectedYear != null) {
//       final startOfMonth = DateTime(selectedYear!, selectedMonth!);
//       final endOfMonth =
//       DateTime(selectedYear!, selectedMonth! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfMonth.toIso8601String())
//           .where('date', isLessThan: endOfMonth.toIso8601String());
//     } else if (filterType == 'Yearly' && selectedYear != null) {
//       final startOfYear = DateTime(selectedYear!);
//       final endOfYear = DateTime(selectedYear! + 1).subtract(const Duration(microseconds: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: startOfYear.toIso8601String())
//           .where('date', isLessThan: endOfYear.toIso8601String());
//     } else if (filterType == 'Range' && startDate != null && endDate != null) {
//       final start = DateTime(startDate!.year, startDate!.month, startDate!.day);
//       final end = DateTime(endDate!.year, endDate!.month, endDate!.day)
//           .add(const Duration(days: 1));
//       query = query
//           .where('date', isGreaterThanOrEqualTo: start.toIso8601String())
//           .where('date', isLessThan: end.toIso8601String());
//     }
//
//     return query.snapshots();
//   }
//
//   // Modified filter menu with Range option
//   void _showFilterMenu(BuildContext context) {
//     showMenu<String>(
//       context: context,
//       position: const RelativeRect.fromLTRB(100, 100, 0, 0),
//       items: <PopupMenuEntry<String>>[
//         PopupMenuItem<String>(
//           value: 'All',
//           child: Text(
//             'Filter By: All',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'All' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Daily',
//           child: Text(
//             'Filter By: Daily',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Daily' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Monthly',
//           child: Text(
//             'Filter By: Monthly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Monthly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Yearly',
//           child: Text(
//             'Filter By: Yearly',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Yearly' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//         PopupMenuItem<String>(
//           value: 'Range',
//           child: Text(
//             'Filter By: Date Range',
//             style: TextStyle(
//               fontFamily: 'Lexend',
//               color: filterType == 'Range' ? const Color(0xFF1877F2) : const Color(0xFF1B0E0E),
//             ),
//           ),
//         ),
//       ],
//       color: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//     ).then((value) {
//       if (value != null) {
//         setState(() {
//           filterType = value;
//           if (value != 'Daily') selectedDate = null;
//           if (value != 'Monthly') selectedMonth = null;
//           if (value != 'Yearly' && value != 'Monthly') selectedYear = null;
//           if (value != 'Range') {
//             startDate = null;
//             endDate = null;
//           }
//           if (value == 'Daily') _selectDate(context);
//           if (value == 'Monthly') _selectMonthYear(context);
//           if (value == 'Yearly') _selectYear(context);
//           if (value == 'Range') _selectDateRange(context);
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final mediaQuery = MediaQuery.of(context);
//     final screenWidth = mediaQuery.size.width;
//     final screenHeight = mediaQuery.size.height;
//     final isMobile = screenWidth < 600;
//     final isTablet = screenWidth >= 600 && screenWidth < 900;
//     final isDesktop = screenWidth >= 900;
//
//     // Responsive padding and font sizes
//     final padding = screenWidth * (isMobile ? 0.04 : isTablet ? 0.03 : 0.02);
//     final fontSizeTitle = isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
//     final fontSizeBody = isMobile ? 14.0 : isTablet ? 16.0 : 18.0;
//     final filterContainerWidth = isDesktop ? screenWidth * 0.6 : screenWidth * 0.9;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFFCF8F8),
//       appBar: AppBar(
//         title: Text(
//           'Transactions',
//           style: TextStyle(
//             fontFamily: 'PublicSans',
//             fontWeight: FontWeight.bold,
//             fontSize: fontSizeTitle,
//             color: const Color(0xFF1B0E0E),
//           ),
//         ),
//         backgroundColor: const Color(0xFFFCF8F8),
//         elevation: 0,
//         centerTitle: true,
//         actions: [
//           PopupMenuButton<String>(
//             icon: const Icon(Icons.file_download, color: Color(0xFFE61919)),
//             onSelected: (value) async {
//               if (value == "csv") {
//                 await _exportCSV();
//               } else if (value == "excel") {
//                 await _exportExcel();
//               } else if (value == "pdf") {
//                 await _exportPDF();
//               }
//             },
//             itemBuilder: (context) => [
//               const PopupMenuItem(
//                 value: "csv",
//                 child: Text("Export CSV", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "excel",
//                 child: Text("Export Excel", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//               const PopupMenuItem(
//                 value: "pdf",
//                 child: Text("Export PDF", style: TextStyle(fontFamily: 'Lexend')),
//               ),
//             ],
//             color: Colors.white,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                   child: Column(
//                     children: [
//                       // Search Bar with Filter Icon
//                       Container(
//                         width: filterContainerWidth,
//                         padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding),
//                         child: AnimatedField(
//                           delay: 200,
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: "Search by name or contact...",
//                               hintStyle: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 color: const Color(0xFF666666),
//                                 fontSize: fontSizeBody,
//                               ),
//                               prefixIcon: const Icon(Icons.search, color: Color(0xFFE61919)),
//                               suffixIcon: IconButton(
//                                 icon: const Icon(Icons.filter_list, color: Color(0xFFE61919)),
//                                 onPressed: () => _showFilterMenu(context),
//                               ),
//                               filled: true,
//                               fillColor: const Color(0xFFF5F6F5),
//                               contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
//                               ),
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(14),
//                                 borderSide: const BorderSide(color: Color(0xFF1877F2), width: 2),
//                               ),
//                             ),
//                             style: TextStyle(
//                               fontFamily: 'Lexend',
//                               color: const Color(0xFF1B0E0E),
//                               fontSize: fontSizeBody,
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 searchQuery = value.toLowerCase();
//                               });
//                             },
//                           ),
//                         ),
//                       ),
//                       // Display selected filter
//                       if (filterType != 'All')
//                         Padding(
//                           padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
//                           child: FadeInUp(
//                             delay: 300,
//                             child: Text(
//                               filterType == 'Daily' && selectedDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
//                                   : filterType == 'Monthly' && selectedMonth != null && selectedYear != null
//                                   ? 'Selected: $selectedMonth/$selectedYear'
//                                   : filterType == 'Yearly' && selectedYear != null
//                                   ? 'Selected: $selectedYear'
//                                   : filterType == 'Range' && startDate != null && endDate != null
//                                   ? 'Selected: ${DateFormat('yyyy-MM-dd').format(startDate!)} to ${DateFormat('yyyy-MM-dd').format(endDate!)}'
//                                   : '',
//                               style: TextStyle(
//                                 fontFamily: 'Lexend',
//                                 fontSize: fontSizeBody - 2,
//                                 color: const Color(0xFF666666),
//                               ),
//                             ),
//                           ),
//                         ),
//                       // Transaction List
//                       SizedBox(
//                         height: screenHeight * (isMobile ? 0.8 : isTablet ? 0.65 : 0.7),
//                         child: StreamBuilder<QuerySnapshot>(
//                           stream: _buildTransactionQuery(),
//                           builder: (context, snapshot) {
//                             if (snapshot.hasError) {
//                               String errorMessage = "Error loading transactions: ${snapshot.error}";
//                               if (snapshot.error.toString().contains('FAILED_PRECONDITION')) {
//                                 errorMessage =
//                                 "This query requires a Firestore index. Please check the console logs or contact support.";
//                               }
//                               return Center(
//                                 child: Text(
//                                   errorMessage,
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: Colors.redAccent,
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(
//                                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//                               );
//                             }
//
//                             final docs = snapshot.data!.docs.where((doc) {
//                               final data = doc.data() as Map<String, dynamic>;
//                               final name = data["name"]?.toString().toLowerCase() ?? "";
//                               final contact = data["contactNo"]?.toString().toLowerCase() ?? "";
//                               return name.contains(searchQuery) || contact.contains(searchQuery);
//                             }).toList();
//
//                             if (docs.isEmpty) {
//                               return Center(
//                                 child: Text(
//                                   "No transactions available",
//                                   style: TextStyle(
//                                     fontFamily: 'Lexend',
//                                     color: const Color(0xFF666666),
//                                     fontSize: fontSizeBody,
//                                   ),
//                                 ),
//                               );
//                             }
//
//                             return ListView.builder(
//                               padding: EdgeInsets.all(padding),
//                               itemCount: docs.length,
//                               itemBuilder: (context, index) {
//                                 final transaction = TransactionModel.fromFirestore(docs[index]);
//
//                                 return AnimatedField(
//                                   delay: 200 + (index * 100),
//                                   child: TransactionCard(
//                                     id: transaction.id,
//                                     name: transaction.name,
//                                     date: transaction.date,
//                                     totalAmount: transaction.totalAmount,
//                                     paidAmount: transaction.paidAmount,
//                                     isPaid: transaction.isPaid,
//                                     contactNo: transaction.contactNo,
//                                     address: transaction.address,
//                                     padding: padding,
//                                     isLargeScreen: isDesktop || isTablet,
//                                     onEdit: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               EditTransactionScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                     onDelete: () {
//                                       ScaffoldMessenger.of(context).showSnackBar(
//                                         SnackBar(
//                                           content: Text(
//                                             "Are you sure you want to delete this transaction?",
//                                             style: TextStyle(
//                                               fontFamily: 'Lexend',
//                                               fontSize: fontSizeBody - 2,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                           backgroundColor: Colors.redAccent,
//                                           duration: const Duration(seconds: 5),
//                                           behavior: SnackBarBehavior.floating,
//                                           margin: EdgeInsets.all(padding),
//                                           action: SnackBarAction(
//                                             label: 'Delete',
//                                             textColor: Colors.white,
//                                             onPressed: () {
//                                               if (!_isDeleting) {
//                                                 _deleteTransaction(transaction.id, context);
//                                               }
//                                             },
//                                           ),
//                                           showCloseIcon: true,
//                                           closeIconColor: Colors.white,
//                                         ),
//                                       );
//                                     },
//                                     onHistory: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) =>
//                                               TransactionHistoryScreen(transaction: transaction),
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           if (_isDeleting)
//             Container(
//               color: Colors.black.withOpacity(0.6),
//               child: const Center(
//                 child: CircularProgressIndicator(color: Color(0xFFE61919)),
//               ),
//             ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _isDeleting
//             ? null
//             : () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
//           );
//         },
//         backgroundColor: const Color(0xFFE61919),
//         child: Icon(Icons.add, size: fontSizeBody + 4, color: Colors.white),
//       ),
//     );
//   }
// }
