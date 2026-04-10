import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/universal_app_bar.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MridaColors.surface,
      appBar: UniversalAppBar(
        title: 'NEW FIELD',
        showSettings: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FIELD DETAILS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: MridaColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Field Name', 'e.g. North Plot', Icons.landscape_outlined),
              const SizedBox(height: 20),
              _buildDropdownField('Terrain Type', ['Plain', 'Hilly', 'Terrace', 'Wetland']),
              const SizedBox(height: 20),
              _buildTextField('Area (in acres)', 'e.g. 2.5', Icons.square_foot),
              const SizedBox(height: 40),
              
              Text(
                'LOCATION',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: MridaColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MridaColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: MridaColors.outlineVariant.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location, color: MridaColors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Automatically detect location',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: MridaColors.onSurface,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: MridaColors.outlineVariant),
                  ],
                ),
              ),
              const SizedBox(height: 64),
              
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('CREATE FIELD'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: MridaColors.primary),
      ),
      validator: (v) => v == null || v.isEmpty ? 'Required field' : null,
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.category_outlined, color: MridaColors.primary),
      ),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: (_) {},
      validator: (v) => v == null ? 'Required selection' : null,
    );
  }
}
