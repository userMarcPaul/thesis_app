// lib/client/client_preferences_form_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../client/client_home_page.dart';

class ClientPreferencesFormPage extends StatefulWidget {
  final String userId;
  final VoidCallback? onComplete;

  const ClientPreferencesFormPage({
    Key? key,
    required this.userId,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ClientPreferencesFormPage> createState() => _ClientPreferencesFormPageState();
}

class _ClientPreferencesFormPageState extends State<ClientPreferencesFormPage> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  // Step index
  int _currentStep = 0;

  // Personal info
  final TextEditingController _firstNameCtl = TextEditingController();
  final TextEditingController _lastNameCtl = TextEditingController();
  final TextEditingController _ageCtl = TextEditingController();

  // Location (single-select)
  final List<String> _locations = [
    'Naval',
    'Almeria',
    'Kawayan',
    'Culaba',
    'Caibiran',
    'Cabucgayan',
    'Biliran',
    'Maripipi',
  ];
  String? _selectedLocation;

  // Types (multi-select)
  final List<String> _types = [
    'Wedding',
    'Birthday',
    'Corporate Event',
    'Concert / Live Music',
    'Festival',
    'Photoshoot',
    'Video Production',
    'Catering',
    'Fashion Styling',
    'Hair & Makeup',
    'Graphic Design',
    'Logo & Branding',
    'Painting / Visual Arts',
    'Digital Art',
    'Theater / Stage Play',
    'Dance Performance',
    'Cultural Performance',
    'DJ Services',
    'Photography (Event / Portrait)',
    'Videography (Event / Commercial)',
    'Social Media Content Creation',
    'Product Shoot',
    'Exhibition / Art Show',
    'Conference / Seminar',
    'Workshop / Training',
    'Private Party',
    'Anniversary / Reunion',
    'Debut / Quinceañera',
    'Engagement / Proposal Setup',
    'Funeral / Memorial Service',
    'Festival Booth / Stall Design',
    'Interior / Event Styling',
    'Lights & Sound Setup',
    'Hosting / Emceeing',
    'Live Streaming / Virtual Event',
    'Marketing & Advertising Media',
    'Costume Design',
    'Props & Set Design',
    'Culinary Arts / Food Styling',
    'Crafts & Handmade Art',
    'Animation / Motion Graphics',
  ];
  final List<String> _selectedTypes = [];

  // Likes (multi-select)
  final List<String> _likes = [
    'Music',
    'Arts',
    'Food',
    'Fashion',
    'Tech',
    'Photography',
    'Outdoors',
    'Family-friendly',
    'Luxury',
    'Budget-friendly'
  ];
  final List<String> _selectedLikes = [];

  // Budget range
  final double _minBudget = 5000;
  final double _maxBudget = 100000;
  RangeValues _budgetRange = const RangeValues(15000, 50000);

  bool _saving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameCtl.dispose();
    _lastNameCtl.dispose();
    _ageCtl.dispose();
    super.dispose();
  }

  // Helpers for chips with enhanced style
  Widget _buildSingleChoiceChips(List<String> options, String? selected, ValueChanged<String> onSelect) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) {
        final bool isSelected = opt == selected;
        return ChoiceChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) => onSelect(opt),
          selectedColor: Colors.deepPurple.shade100,
          backgroundColor: Colors.grey.shade200,
          labelStyle: TextStyle(
            color: isSelected ? Colors.deepPurple.shade800 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? Colors.deepPurple : Colors.grey.shade400,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoiceChips(List<String> options, List<String> selectedList, ValueChanged<String> onToggle) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((opt) {
        final bool isSelected = selectedList.contains(opt);
        return FilterChip(
          label: Text(opt),
          selected: isSelected,
          onSelected: (_) => onToggle(opt),
          selectedColor: Colors.green.shade100,
          backgroundColor: Colors.grey.shade200,
          checkmarkColor: Colors.green.shade800,
          labelStyle: TextStyle(
            color: isSelected ? Colors.green.shade800 : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? Colors.green.shade700 : Colors.grey.shade400,
            ),
          ),
        );
      }).toList(),
    );
  }

  void _toggleType(String value) {
    setState(() {
      if (_selectedTypes.contains(value)) {
        _selectedTypes.remove(value);
      } else {
        _selectedTypes.add(value);
      }
    });
  }

  void _toggleLike(String value) {
    setState(() {
      if (_selectedLikes.contains(value)) {
        _selectedLikes.remove(value);
      } else {
        _selectedLikes.add(value);
      }
    });
  }

  // Navigation
  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _finishAndSave();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    }
  }

  double _progressValue() => (_currentStep + 1) / 5;

  // Validation before going next from certain steps
  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      if (!_formKey.currentState!.validate()) {
        return false;
      }
      _formKey.currentState!.save();
      return true;
    } else if (_currentStep == 1) {
      if (_selectedLocation == null) {
        _showSnack('Please select a municipality.');
        return false;
      }
      return true;
    } else if (_currentStep == 2) {
      if (_selectedTypes.isEmpty) {
        _showSnack('Please select at least one type.');
        return false;
      }
      return true;
    }
    return true;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _finishAndSave() async {
    if (!_validateCurrentStep()) return;

    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showSnack('No authenticated user found.');
        setState(() => _saving = false);
        return;
      }
      final uid = user.uid;

      final prefs = {
        'firstName': _firstNameCtl.text.trim(),
        'lastName': _lastNameCtl.text.trim(),
        'age': int.tryParse(_ageCtl.text.trim()) ?? 0,
        'location': _selectedLocation,
        'type': _selectedTypes,
        'likes': _selectedLikes,
        'budgetRange': {
          'min': _budgetRange.start.round(),
          'max': _budgetRange.end.round(),
          'currency': 'PHP'
        },
        'preferences_completed_at': DateTime.now().toUtc().toIso8601String(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'preferences': prefs, 'preferences_completed': true}, SetOptions(merge: true));

      if (!mounted) return;
      _showSnack('Preferences saved successfully!');

      widget.onComplete?.call();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ClientHomePage(clientName: '${prefs['firstName']} ${prefs['lastName']}')),
      );
    } catch (e) {
      _showSnack('Error saving preferences: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // Build each step page
  Widget _buildStepPersonalInfo() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('This helps us get to know you.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _firstNameCtl,
            decoration: InputDecoration(
              labelText: 'First name',
              hintText: 'e.g., John',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your first name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _lastNameCtl,
            decoration: InputDecoration(
              labelText: 'Last name',
              hintText: 'e.g., Doe',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your last name' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageCtl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Age',
              hintText: 'e.g., 25',
              prefixIcon: const Icon(Icons.calendar_today),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter your age';
              final age = int.tryParse(v.trim());
              if (age == null || age <= 0 || age > 120) return 'Enter a valid age';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Your Location', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Where are you located?', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        _buildSingleChoiceChips(_locations, _selectedLocation, (val) {
          setState(() {
            _selectedLocation = val;
          });
        }),
      ],
    );
  }

  Widget _buildStepType() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Service / Event Types', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Select one or more categories of interest.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: _buildMultiChoiceChips(_types, _selectedTypes, _toggleType),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLikes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Interests & Style', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Pick tags that match your taste.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        _buildMultiChoiceChips(_likes, _selectedLikes, _toggleLike),
      ],
    );
  }

  Widget _buildStepBudget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget Range', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('What is your expected budget?', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Text(
          '₱${_budgetRange.start.round()} - ₱${_budgetRange.end.round()}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Drag the sliders to adjust your budget.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 16),
        RangeSlider(
          min: _minBudget,
          max: _maxBudget,
          divisions: ((_maxBudget - _minBudget) ~/ 1000).toInt(),
          values: _budgetRange,
          labels: RangeLabels('₱${_budgetRange.start.round()}', '₱${_budgetRange.end.round()}'),
          onChanged: (r) => setState(() => _budgetRange = r),
          activeColor: Colors.deepPurple,
        ),
      ],
    );
  }

  // Main build
  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildStepPersonalInfo(),
      _buildStepLocation(),
      _buildStepType(),
      _buildStepLikes(),
      _buildStepBudget(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Onboarding',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _progressValue(),
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Step ${_currentStep + 1} of 5', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple)),
                      Text(_stepTitle(_currentStep), style: const TextStyle(fontSize: 14, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                    child: pages[index],
                  );
                },
              ),
            ),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving ? null : _prevStep,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.deepPurple,
                          side: const BorderSide(color: Colors.deepPurple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Back'),
                      ),
                    )
                  else
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () {
                              if (_validateCurrentStep()) {
                                _nextStep();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                          : Text(_currentStep < 4 ? 'Next' : 'Finish'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Info';
      case 1:
        return 'Location';
      case 2:
        return 'Event Types';
      case 3:
        return 'Interests';
      case 4:
        return 'Budget';
      default:
        return '';
    }
  }
}