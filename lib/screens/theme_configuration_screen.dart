import 'package:flutter/material.dart';
import '../services/theme_config_service.dart';
import '../services/theme_customization_service.dart';
import '../utils/colors.dart';
import '../widgets/animated_list_item.dart';

class ThemeConfigurationScreen extends StatefulWidget {
  @override
  _ThemeConfigurationScreenState createState() => _ThemeConfigurationScreenState();
}

class _ThemeConfigurationScreenState extends State<ThemeConfigurationScreen> {
  final _themeConfigService = ThemeConfigService();
  late ThemeConfig _config;
  final List<String> _fontFamilies = [
    'Inter',
    'Roboto',
    'Poppins',
    'Montserrat',
    'Open Sans',
  ];

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _themeConfigService.getConfig();
    setState(() => _config = config);
  }

  Future<void> _saveConfig() async {
    await _themeConfigService.saveConfig(_config);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Theme settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Theme Configuration'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Layout',
            children: [
              AnimatedListItem(
                index: 0,
                child: _buildSliderTile(
                  title: 'Corner Radius',
                  value: _config.cornerRadius,
                  min: 0,
                  max: 24,
                  onChanged: (value) {
                    setState(() {
                      _config = ThemeConfig(
                        cornerRadius: value,
                        fontFamily: _config.fontFamily,
                        spacing: _config.spacing,
                        useMaterial3: _config.useMaterial3,
                      );
                    });
                  },
                ),
              ),
              AnimatedListItem(
                index: 1,
                child: _buildSliderTile(
                  title: 'Spacing',
                  value: _config.spacing,
                  min: 8,
                  max: 24,
                  onChanged: (value) {
                    setState(() {
                      _config = ThemeConfig(
                        cornerRadius: _config.cornerRadius,
                        fontFamily: _config.fontFamily,
                        spacing: value,
                        useMaterial3: _config.useMaterial3,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Typography',
            children: [
              AnimatedListItem(
                index: 2,
                child: _buildFontFamilySelector(),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildSection(
            title: 'Advanced',
            children: [
              AnimatedListItem(
                index: 3,
                child: SwitchListTile(
                  title: Text('Use Material 3'),
                  subtitle: Text('Enable Material You design'),
                  value: _config.useMaterial3,
                  onChanged: (value) {
                    setState(() {
                      _config = ThemeConfig(
                        cornerRadius: _config.cornerRadius,
                        fontFamily: _config.fontFamily,
                        spacing: _config.spacing,
                        useMaterial3: value,
                      );
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: secondaryBackgroundColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: textColor),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  onChanged: onChanged,
                  activeColor: buttonColor,
                ),
              ),
              SizedBox(width: 16),
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(color: textColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFontFamilySelector() {
    return Column(
      children: _fontFamilies.map((font) {
        return RadioListTile<String>(
          title: Text(
            font,
            style: TextStyle(
              fontFamily: font,
              color: textColor,
            ),
          ),
          value: font,
          groupValue: _config.fontFamily,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _config = ThemeConfig(
                  cornerRadius: _config.cornerRadius,
                  fontFamily: value,
                  spacing: _config.spacing,
                  useMaterial3: _config.useMaterial3,
                );
              });
            }
          },
        );
      }).toList(),
    );
  }
} 