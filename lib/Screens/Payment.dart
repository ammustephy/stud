import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:stud/Screens/HomePage.dart';

class Payment {
  final String id, type, amount, dueDate;
  final String? paidDate, transactionId, method;
  final String? description;
  final String status;
  Payment({
    required this.id,
    required this.type,
    required this.amount,
    required this.dueDate,
    this.paidDate,
    this.transactionId,
    this.method,
    this.description,
    required this.status,
  });
}

final List<Payment> paidPayments = [
  Payment(
    id: '1',
    type: 'Tuition Fee',
    amount: '₹500',
    dueDate: '2025-01-01',
    paidDate: '2024-12-28T14:30:00',
    transactionId: 'TXN001',
    status: 'paid',
    method: 'Online',
  ),
  Payment(
    id: '2',
    type: 'Bus Fee',
    amount: '₹25',
    dueDate: '2025-01-01',
    paidDate: '2024-12-30T10:00:00',
    transactionId: 'TXN002',
    status: 'paid',
    method: 'Cash',
  ),
];

final List<Payment> pendingPayments = [
  Payment(
    id: '3',
    type: 'Library Fee',
    amount: '₹15',
    dueDate: '2025-01-25',
    status: 'pending',
    description: 'Annual library maintenance fee',
  ),
  Payment(
    id: '4',
    type: 'Lab Fee',
    amount: '₹30',
    dueDate: '2025-01-30',
    status: 'pending',
    description: 'Science laboratory equipment fee',
  ),
  Payment(
    id: '5',
    type: 'Sports Fee',
    amount: '₹20',
    dueDate: '2025-02-05',
    status: 'pending',
    description: 'Sports activities and equipment fee',
  ),
];

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadPayments extends PaymentEvent {}

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentsLoading extends PaymentState {}

class PaymentsLoaded extends PaymentState {
  final List<Payment> paid, pending;
  PaymentsLoaded({required this.paid, required this.pending});
  @override
  List<Object?> get props => [paid, pending];
}

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(PaymentsLoading()) {
    on<LoadPayments>((event, emit) {
      emit(PaymentsLoaded(paid: paidPayments, pending: pendingPayments));
    });
  }
}

class PaymentsPage extends StatelessWidget {
  final Student? student;
  const PaymentsPage({super.key, this.student});

  String formatPaidDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return 'Jan 01, 2025 12:00 PM';
    }
    try {
      final dateTime = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
    } catch (e) {
      return 'Jan 01, 2025 12:00 PM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentArg = student ??
        ModalRoute.of(context)?.settings.arguments as Student? ??
        const Student(
          name: 'Default User',
          studentClass: 'Unknown',
          division: 'Unknown',
          userId: 0,
        );
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: BlocProvider(
        create: (_) => PaymentBloc()..add(LoadPayments()),
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Row(
                children: [
                  // Icon(Icons.payment),
                  SizedBox(width: 8),
                  Text('Payments'),
                ],
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Pending'),
                  Tab(text: 'Paid'),
                ],
              ),
            ),
            body: BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, state) {
                if (state is PaymentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PaymentsLoaded) {
                  final totalPaid = state.paid.fold<int>(
                      0, (sum, p) => sum + int.parse(p.amount.replaceAll('₹', '')));
                  final totalPending = state.pending.fold<int>(
                      0, (sum, p) => sum + int.parse(p.amount.replaceAll('₹', '')));
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(child: _summaryCard('Total Paid', totalPaid, Colors.green, studentArg)),
                            const SizedBox(width: 8),
                            Expanded(child: _summaryCard('Total Pending', totalPending, Colors.orange, studentArg)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _pendingTab(state.pending),
                            _paidTab(state.paid),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, int amount, Color color, Student student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text('Class ${student.studentClass} - Division ${student.division}', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('₹$amount',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _pendingTab(List<Payment> pending) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: pending.length,
      itemBuilder: (context, i) {
        final p = pending[i];
        return Card(
          color: Colors.orange.shade50,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(p.type),
            subtitle: Text('${p.description ?? ''}\nDue: ${p.dueDate}'),
            trailing: Text(p.amount,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
            onTap: () => _payNow(context, p.id, p.type),
          ),
        );
      },
    );
  }

  Widget _paidTab(List<Payment> paid) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: paid.length,
      itemBuilder: (context, i) {
        final p = paid[i];
        return Card(
          color: Colors.green.shade50,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 16,
                  children: [
                    Text('Amount: ${p.amount}'),
                    Text('Paid: ${formatPaidDate(p.paidDate)}'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    _actionButton(() => _viewReceipt(context, p), Icons.visibility, 'View'),
                    _actionButton(() => _downloadReceipt(context, p), Icons.download, 'Download'),
                    _actionButton(() => _shareReceipt(context, p), Icons.share, 'Share'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton(VoidCallback onPressed, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(100, 35),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  void _viewReceipt(BuildContext context, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${payment.type} Receipt',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 24),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Amount: ${payment.amount}'),
              Text('Paid On: ${formatPaidDate(payment.paidDate)}'),
              Text('Transaction ID: ${payment.transactionId}'),
              Text('Method: ${payment.method}'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _downloadReceipt(BuildContext context, Payment payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading receipt for ${payment.type}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareReceipt(BuildContext context, Payment payment) {
    final shareText =
        'Payment Receipt\nType: ${payment.type}\nAmount: ${payment.amount}\nPaid On: ${formatPaidDate(payment.paidDate)}\nTransaction ID: ${payment.transactionId}\nMethod: ${payment.method}';
    Share.share(shareText, subject: 'Receipt for ${payment.type}');
  }

  void _payNow(BuildContext context, String id, String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Initiating payment for $type...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}