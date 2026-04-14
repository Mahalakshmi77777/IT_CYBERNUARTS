import 'dart:io';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Data model for a club.
class Club {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final DateTime createdAt;

  Club({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logo_base64'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// Repository for club CRUD operations using Supabase.
class ClubRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> createClub(Club club) async {
    await _client.from('clubs').insert({
      'name': club.name,
      'description': club.description,
      'logo_base64': club.logoUrl,
    });
  }

  Future<void> updateClub(String clubId, Map<String, dynamic> data) async {
    final Map<String, dynamic> updates = {};

    if (data.containsKey('name')) updates['name'] = data['name'];
    if (data.containsKey('description')) updates['description'] = data['description'];
    if (data.containsKey('logoUrl')) updates['logo_base64'] = data['logoUrl'];

    if (updates.isEmpty) return;

    await _client.from('clubs').update(updates).eq('id', clubId);
  }

  Future<void> deleteClub(String clubId) async {
    await _client.from('clubs').delete().eq('id', clubId);
  }

  Future<List<Club>> getClubs() async {
    final data = await _client
        .from('clubs')
        .select()
        .order('name', ascending: true);
    return (data as List).map((row) => Club.fromJson(row)).toList();
  }

  Future<Club> getClub(String clubId) async {
    final row = await _client
        .from('clubs')
        .select()
        .eq('id', clubId)
        .single();
    return Club.fromJson(row);
  }

  Future<String> uploadLogo(String clubId, File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    return base64String;
  }
}
