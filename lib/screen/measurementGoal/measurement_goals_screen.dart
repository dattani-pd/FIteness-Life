import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';


class MeasurementGoalsScreen extends StatefulWidget {
  const MeasurementGoalsScreen({super.key});

  @override
  State<MeasurementGoalsScreen> createState() => _MeasurementGoalsScreenState();
}

class _MeasurementGoalsScreenState extends State<MeasurementGoalsScreen> {

  Map<String, TextEditingController> _controllers = {};

  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }


  Future<void> _loadData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists && doc.data()!.containsKey('measurementGoals')) {
        final data = doc.data()!['measurementGoals'] as Map<String, dynamic>;

        setState(() {
          _controllers.clear();
          data.forEach((key, value) {
            _controllers[key] = TextEditingController(text: value.toString());
          });
        });
      }
    } catch (e) {
      print('Error loading goals: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveData() async {
    setState(() => isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      Map<String, String> dataToUpdate = {};
      _controllers.forEach((key, controller) {
        dataToUpdate[key] = controller.text.trim();
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'measurementGoals': dataToUpdate
      });

      Get.back();
      Get.snackbar('Success', 'Measurement goals saved',
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 થીમ મુજબ કલર સેટિંગ્સ
    final bool isDark = Get.isDarkMode;
    final Color primaryTextColor = isDark ? Colors.white : Colors.black; // ✅ Proper Black
    final Color scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final Color dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    if (isLoading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(child: CircularProgressIndicator(color: primaryTextColor)),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Measurement Goals',
          style: TextStyle(color: primaryTextColor, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),

          // લિસ્ટ સેક્શન
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _controllers.entries.map((entry) {
                  String label = entry.key;
                  String unit = 'cm';

                  // લેબલ અને યુનિટનું ફોર્મેટિંગ
                  if (label == 'bodyFat') {
                    label = 'Body Fat'; unit = '%';
                  } else if (label == 'weight') {
                    label = 'Weight'; unit = 'kg';
                  } else if (label == 'waist') {
                    label = 'Waist'; unit = 'cm';
                  } else {
                    label = label[0].toUpperCase() + label.substring(1);
                  }

                  return _buildGoalItem(label, entry.value, unit, isDark, primaryTextColor, dividerColor);
                }).toList(),
              ),
            ),
          ),

          // સેવ બટન
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black, // ડાર્ક મોડમાં સફેદ બટન
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: isSaving
                    ? CircularProgressIndicator(color: isDark ? Colors.black : Colors.white)
                    : Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.black : Colors.white)),
              ),
            ),
          ),

          TextButton(
            onPressed: () => _showTrackingOptions(context, isDark, primaryTextColor),
            child: Text(
              'Set Measurements to Track',
              style: TextStyle(color: primaryTextColor, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }


  Widget _buildGoalItem(String label, TextEditingController controller, String unit, bool isDark, Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: borderColor))),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.w500)),
          Expanded(
            child: TextField(
              controller: controller,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              decoration: InputDecoration(
                hintText: '-',
                hintStyle: TextStyle(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(unit, style: TextStyle(fontSize: 16, color: isDark ? Colors.white70 : Colors.black54)),
        ],
      ),
    );
  }

  // ✅ Selection Bottom Sheet
  void _showTrackingOptions(BuildContext context, bool isDark, Color textColor) {
    final List<String> options = ['Chest', 'Biceps', 'Thighs', 'Shoulders', 'Hips'];

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Select Measurements to Track", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 15),
            ...options.map((option) => ListTile(
              leading: Icon(Icons.add_circle_outline, color: textColor),
              title: Text(option, style: TextStyle(color: textColor, fontSize: 16)),
              onTap: () async {
                Get.back();
                final String? uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  await FirebaseFirestore.instance.collection('users').doc(uid).update({
                    'measurementGoals.${option.toLowerCase()}': '-'
                  });
                  _loadData(); // રિફ્રેશ
                }
              },
            )),
          ],
        ),
      ),
    );
  }
}