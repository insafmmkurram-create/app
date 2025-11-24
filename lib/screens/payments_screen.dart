import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/services/payment_service.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final PaymentService _paymentService = PaymentService();
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    _paymentService.getPayments().listen(
      (payments) {
        if (mounted) {
          setState(() {
            _payments = payments;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _error = 'Failed to load payments: ${error.toString()}';
            _isLoading = false;
          });
        }
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
      case 'received':
        return AppTheme.accentColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(String? status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status ?? 'Unknown',
            style: AppTheme.bodyStyle(
              fontSize: 12,
              color: color,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment, int index) {
    final paymentDate = payment['paymentDate'] as DateTime?;
    final status = payment['paymentStatus'] as String?;
    final amount = payment['paymentTotal'] as num?;
    final applicantName = payment['applicantName'] as String?;

    return GestureDetector(
      onTap: () => _showPaymentDetails(payment),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: AppTheme.modernCardDecoration(
          borderRadius: 20,
          hasShadow: true,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showPaymentDetails(payment),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatDate(paymentDate),
                              style: AppTheme.subheadingStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            if (applicantName != null && applicantName.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                applicantName,
                                style: AppTheme.bodyStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildStatusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount',
                            style: AppTheme.bodyStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            amount != null
                                ? 'PKR ${amount.toStringAsFixed(2)}'
                                : 'N/A',
                            style: AppTheme.subheadingStyle(
                              fontSize: 20,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, delay: (index * 100).ms)
          .slideX(begin: 0.2, end: 0, duration: 400.ms, delay: (index * 100).ms),
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentDetailsSheet(payment: payment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Colors.grey[50]!,
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Modern Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payments',
                              style: AppTheme.headingStyle(
                                fontSize: 28,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'View your payment history',
                              style: AppTheme.bodyStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3, end: 0, duration: 600.ms),

              // Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Loading payments...',
                              style: AppTheme.bodyStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 64,
                                    color: AppTheme.errorColor,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    style: AppTheme.bodyStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 24),
                                  ElevatedButton(
                                    onPressed: _loadPayments,
                                    style: AppTheme.modernButtonStyle(),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _payments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.payment_outlined,
                                        size: 64,
                                        color: AppTheme.primaryColor.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No Payments Found',
                                      style: AppTheme.subheadingStyle(
                                        fontSize: 20,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Your payment history will appear here',
                                      style: AppTheme.bodyStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment History',
                                      style: AppTheme.subheadingStyle(
                                        fontSize: 20,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ..._payments.asMap().entries.map((entry) {
                                      return _buildPaymentCard(entry.value, entry.key);
                                    }).toList(),
                                  ],
                                ),
                              ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> payment;

  const _PaymentDetailsSheet({required this.payment});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'success':
      case 'received':
        return AppTheme.accentColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'failed':
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey[600]),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.bodyStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.subheadingStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentDate = payment['paymentDate'] as DateTime?;
    final status = payment['paymentStatus'] as String?;
    final amount = payment['paymentTotal'] as num?;
    final applicantName = payment['applicantName'] as String?;
    final nic = payment['nic'] as String?;
    final accountNumber = payment['accountNumber'] as String?;
    final bankName = payment['bankName'] as String?;
    final createdAt = payment['createdAt'] as DateTime?;
    final dateStr = payment['date'] as String?;

    final statusColor = _getStatusColor(status);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Details',
                          style: AppTheme.headingStyle(
                            fontSize: 24,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(paymentDate),
                          style: AppTheme.bodyStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status ?? 'Unknown',
                          style: AppTheme.bodyStyle(
                            fontSize: 14,
                            color: statusColor,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount Paid',
                            style: AppTheme.bodyStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            amount != null
                                ? 'PKR ${amount.toStringAsFixed(2)}'
                                : 'N/A',
                            style: AppTheme.headingStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Details
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: AppTheme.modernCardDecoration(
                        borderRadius: 20,
                        hasShadow: true,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Information',
                            style: AppTheme.subheadingStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Payment Date',
                            paymentDate != null 
                                ? _formatDateTime(paymentDate)
                                : (dateStr ?? 'N/A'),
                            icon: Icons.calendar_today,
                          ),
                          const Divider(),
                          if (bankName != null && bankName.isNotEmpty)
                            _buildDetailRow(
                              'Bank Name',
                              bankName,
                              icon: Icons.account_balance,
                            ),
                          if (bankName != null && bankName.isNotEmpty)
                            const Divider(),
                          if (accountNumber != null && accountNumber.isNotEmpty)
                            _buildDetailRow(
                              'Account Number',
                              accountNumber,
                              icon: Icons.account_circle,
                            ),
                          if (accountNumber != null && accountNumber.isNotEmpty)
                            const Divider(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Applicant Info
                    if (applicantName != null || nic != null)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: AppTheme.modernCardDecoration(
                          borderRadius: 20,
                          hasShadow: true,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Applicant Information',
                              style: AppTheme.subheadingStyle(
                                fontSize: 18,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (applicantName != null && applicantName.isNotEmpty)
                              _buildDetailRow(
                                'Name',
                                applicantName,
                                icon: Icons.person,
                              ),
                            if (applicantName != null && applicantName.isNotEmpty)
                              const Divider(),
                            if (nic != null && nic.isNotEmpty)
                              _buildDetailRow(
                                'CNIC',
                                nic,
                                icon: Icons.badge,
                              ),
                            if (nic != null && nic.isNotEmpty)
                              const Divider(),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

