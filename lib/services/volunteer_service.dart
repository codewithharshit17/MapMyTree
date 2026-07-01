import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/dev_session.dart';
import '../models/profile_model.dart';

class VolunteerService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _volunteersKey = 'local_volunteers';

  // Seed default data
  static const List<Map<String, dynamic>> _defaultVolunteers = [
    {
      'id': 'vol-1',
      'email': 'amit.vol@mapmytree.com',
      'role': 'ngo_volunteer',
      'full_name': 'Amit Shinde',
      'phone_number': '+91 9012345678',
      'is_verified': true,
      'is_active': true,
      'created_at': '2026-06-01T12:00:00.000Z',
    },
    {
      'id': 'vol-2',
      'email': 'sneha.vol@mapmytree.com',
      'role': 'ngo_volunteer',
      'full_name': 'Sneha Patil',
      'phone_number': '+91 9876543210',
      'is_verified': true,
      'is_active': true,
      'created_at': '2026-06-05T14:30:00.000Z',
    },
  ];

  Future<void> _initializeLocalSeeds() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_volunteersKey) == null) {
      await prefs.setString(_volunteersKey, jsonEncode(_defaultVolunteers));
    }
  }

  Future<List<ProfileModel>> getVolunteers() async {
    await _initializeLocalSeeds();
    if (!DevSession().isActive) {
      try {
        final data = await _supabase
            .from('profiles')
            .select()
            .or('role.eq.ngo_volunteer,role.eq.ngo')
            .order('full_name');
        return (data as List).map((x) => ProfileModel.fromJson(x)).toList();
      } catch (e) {
        debugPrint('Supabase getVolunteers failed: $e. Using local cache.');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_volunteersKey);
    if (jsonStr != null) {
      final List list = jsonDecode(jsonStr);
      return list.map((x) => ProfileModel.fromJson(x)).toList();
    }
    return [];
  }

  Future<void> createVolunteer({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final newId = 'vol-${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'id': newId,
      'email': email,
      'role': 'ngo_volunteer',
      'full_name': name,
      'phone_number': phone,
      'is_verified': true,
      'is_active': true,
      'created_at': DateTime.now().toIso8601String(),
    };

    if (!DevSession().isActive) {
      try {
        await _supabase.from('profiles').insert(payload);
        debugPrint('Supabase createVolunteer success');
      } catch (e) {
        debugPrint('Supabase createVolunteer failed: $e. Saving locally.');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final list = await getVolunteers();
    list.add(ProfileModel.fromJson(payload));
    await prefs.setString(_volunteersKey, jsonEncode(list.map((x) => x.toJson()).toList()));
  }

  Future<void> updateVolunteer(ProfileModel profile) async {
    if (!DevSession().isActive) {
      try {
        await _supabase
            .from('profiles')
            .update(profile.toJson())
            .eq('id', profile.id);
      } catch (e) {
        debugPrint('Supabase updateVolunteer failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final list = await getVolunteers();
    final idx = list.indexWhere((x) => x.id == profile.id);
    if (idx >= 0) {
      list[idx] = profile;
      await prefs.setString(_volunteersKey, jsonEncode(list.map((x) => x.toJson()).toList()));
    }
  }

  Future<void> deleteVolunteer(String id) async {
    if (!DevSession().isActive) {
      try {
        await _supabase.from('profiles').delete().eq('id', id);
      } catch (e) {
        debugPrint('Supabase deleteVolunteer failed: $e');
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final list = await getVolunteers();
    list.removeWhere((x) => x.id == id);
    await prefs.setString(_volunteersKey, jsonEncode(list.map((x) => x.toJson()).toList()));
  }
}
