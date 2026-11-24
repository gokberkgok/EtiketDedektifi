import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../services/product_api_service.dart';

Future<String?> showManualBarcodeSheet(BuildContext context) {
  return showAppBottomSheet<String>(
    context,
    builder: (_) => const _ManualBarcodeSheet(),
  );
}

class _ManualBarcodeSheet extends StatefulWidget {
  const _ManualBarcodeSheet();

  @override
  State<_ManualBarcodeSheet> createState() => _ManualBarcodeSheetState();
}

class _ManualBarcodeSheetState extends State<_ManualBarcodeSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _controller.text.trim();
    if (!ProductApiService.isValidBarcode(code)) {
      setState(() => _error = 'Barkodun altındaki 8–14 haneli numarayı gir.');
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Barkod numarası',
      child: Column(
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.search,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(14),
            ],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Örn. 8690504017301',
              errorText: _error,
              prefixIcon: const Icon(Icons.dialpad_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Ürünü bul',
            icon: Icons.search_rounded,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
