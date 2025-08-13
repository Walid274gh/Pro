import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import '../../services/subscription_service.dart';
import '../../services/payment_service.dart';
import '../../utils/firebase_config.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _subs = SubscriptionService();
  final _pay = PaymentService();
  final _picker = ImagePicker();

  String _plan = 'monthly';
  String _method = 'barid_mob';
  bool _busy = false;
  String? _paymentId;
  File? _receipt;

  double get _amount => _plan == 'monthly' ? FirebaseConfig.monthlySubscriptionPrice : FirebaseConfig.yearlySubscriptionPrice;

  Future<void> _startPayment() async {
    setState(() => _busy = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
      final pid = await _pay.createPaymentIntent(workerId: uid, amount: _amount, method: _method);
      setState(() => _paymentId = pid);
      if (_method == 'paiement_poste') {
        _snack('Veuillez téléverser la photo du reçu');
      } else {
        // Ici, on intégrerait la webview/SDK réel et récupérerait transactionId
        // Pour l'instant, on confirme directement pour la structure
        await _pay.confirmOnlinePayment(paymentId: pid, transactionId: 'TX-${DateTime.now().millisecondsSinceEpoch}');
        await _subs.setPaidPlan(workerId: uid, plan: _plan, amount: _amount);
        _snack('Paiement confirmé');
      }
    } catch (e) {
      _snack('Erreur paiement: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _pickReceipt() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (x != null) setState(() => _receipt = File(x.path));
  }

  Future<void> _uploadReceipt() async {
    if (_paymentId == null || _receipt == null) {
      _snack('Reçu ou paiement inexistant');
      return;
    }
    setState(() => _busy = true);
    try {
      final uid = fb_auth.FirebaseAuth.instance.currentUser!.uid;
      await _pay.uploadPostReceipt(workerId: uid, paymentId: _paymentId!, receipt: _receipt!);
      _snack('Reçu envoyé, en cours de validation');
    } catch (e) {
      _snack('Erreur envoi reçu: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Abonnement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Choisir un plan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'monthly', label: Text('Mensuel')),
                ButtonSegment(value: 'yearly', label: Text('Annuel')),
              ],
              selected: {_plan},
              onSelectionChanged: (s) => setState(() => _plan = s.first),
            ),
            const SizedBox(height: 16),
            const Text('Méthode de paiement', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _method,
              items: const [
                DropdownMenuItem(value: 'barid_mob', child: Text('Barid Mob')),
                DropdownMenuItem(value: 'carte_bancaire', child: Text('Carte bancaire')),
                DropdownMenuItem(value: 'paiement_poste', child: Text('Paiement en poste')),
              ],
              onChanged: (v) => setState(() => _method = v ?? _method),
            ),
            const SizedBox(height: 16),
            Text('Montant: ${_amount.toStringAsFixed(0)} DZD'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _busy ? null : _startPayment,
              child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Payer'),
            ),
            const SizedBox(height: 24),
            if (_method == 'paiement_poste') ...[
              const Text('Téléverser le reçu (poste)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton.icon(onPressed: _pickReceipt, icon: const Icon(Icons.camera_alt), label: const Text('Prendre une photo')),
                  const SizedBox(width: 8),
                  if (_receipt != null) const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: (_busy || _receipt == null) ? null : _uploadReceipt,
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Envoyer le reçu'),
              ),
            ]
          ],
        ),
      ),
    );
  }
}