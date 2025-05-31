import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../models/friend_request.dart';
import '../models/message.dart';

/// Service für Social Features
class SocialService {
  // Singleton-Instanz
  static final SocialService _instance = SocialService._internal();
  factory SocialService() => _instance;
  SocialService._internal();

  // Firebase-Instanzen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Benutzerprofile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Benutzerprofils: $e');
      return null;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      return getUserProfile(user.uid);
    }
    return null;
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.id)
          .update(profile.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren des Benutzerprofils: $e');
      return false;
    }
  }

  Future<bool> createUserProfile(UserProfile profile) async {
    try {
      await _firestore.collection('users').doc(profile.id).set(profile.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Erstellen des Benutzerprofils: $e');
      return false;
    }
  }

  // Freundschaftsanfragen
  Future<bool> sendFriendRequest(String toUserId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final request = FriendRequest(
        fromUserId: currentUser.uid,
        toUserId: toUserId,
        status: 'pending',
        timestamp: DateTime.now(),
      );

      await _firestore.collection('friendRequests').add(request.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Senden der Freundschaftsanfrage: $e');
      return false;
    }
  }

  Future<bool> respondToFriendRequest(String requestId, String response) async {
    if (response != 'accepted' && response != 'declined') {
      return false;
    }

    try {
      await _firestore.collection('friendRequests').doc(requestId).update({
        'status': response,
        'respondedAt': DateTime.now(),
      });

      if (response == 'accepted') {
        final request =
            await _firestore.collection('friendRequests').doc(requestId).get();
        final data = request.data();

        if (data != null) {
          final fromUserId = data['fromUserId'] as String;
          final toUserId = data['toUserId'] as String;

          // Füge Freund zu beiden Benutzerprofilen hinzu
          await _firestore.collection('users').doc(fromUserId).update({
            'friends': FieldValue.arrayUnion([toUserId]),
          });

          await _firestore.collection('users').doc(toUserId).update({
            'friends': FieldValue.arrayUnion([fromUserId]),
          });
        }
      }

      return true;
    } catch (e) {
      print('Fehler beim Beantworten der Freundschaftsanfrage: $e');
      return false;
    }
  }

  Stream<List<FriendRequest>> getPendingFriendRequests() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('friendRequests')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => FriendRequest.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Freundesliste
  Stream<List<UserProfile>> getFriends() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      if (data == null) return [];

      final friends = data['friends'] as List<dynamic>? ?? [];
      if (friends.isEmpty) return [];

      final friendProfiles = <UserProfile>[];
      for (final friendId in friends) {
        final profile = await getUserProfile(friendId as String);
        if (profile != null) {
          friendProfiles.add(profile);
        }
      }

      return friendProfiles;
    });
  }

  // Nachrichten
  Future<bool> sendMessage(String toUserId, String content) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      final message = Message(
        fromUserId: currentUser.uid,
        toUserId: toUserId,
        content: content,
        timestamp: DateTime.now(),
        read: false,
      );

      await _firestore.collection('messages').add(message.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Senden der Nachricht: $e');
      return false;
    }
  }

  Stream<List<Message>> getMessages(String otherUserId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('messages')
        .where('fromUserId', whereIn: [currentUser.uid, otherUserId])
        .where('toUserId', whereIn: [currentUser.uid, otherUserId])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Future<bool> markMessageAsRead(String messageId) async {
    try {
      await _firestore.collection('messages').doc(messageId).update({
        'read': true,
      });
      return true;
    } catch (e) {
      print('Fehler beim Markieren der Nachricht als gelesen: $e');
      return false;
    }
  }

  // Online-Status
  Future<bool> updateOnlineStatus(bool isOnline) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren des Online-Status: $e');
      return false;
    }
  }

  // Spieleinladungen
  Future<bool> sendGameInvitation(
      String toUserId, Map<String, dynamic> gameSettings) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore.collection('gameInvitations').add({
        'fromUserId': currentUser.uid,
        'toUserId': toUserId,
        'gameSettings': gameSettings,
        'status': 'pending',
        'timestamp': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Fehler beim Senden der Spieleinladung: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getGameInvitations() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('gameInvitations')
        .where('toUserId', isEqualTo: currentUser.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  Future<bool> respondToGameInvitation(
      String invitationId, String response) async {
    if (response != 'accepted' && response != 'declined') {
      return false;
    }

    try {
      await _firestore.collection('gameInvitations').doc(invitationId).update({
        'status': response,
        'respondedAt': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Fehler beim Beantworten der Spieleinladung: $e');
      return false;
    }
  }

  // Benutzersuche
  Future<List<UserProfile>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isGreaterThanOrEqualTo: query)
          .where('username', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => UserProfile.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Fehler bei der Benutzersuche: $e');
      return [];
    }
  }

  // Aktivitäts-Feed
  Future<bool> addActivityToFeed(
      String activityType, Map<String, dynamic> activityData) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      await _firestore.collection('activityFeed').add({
        'userId': currentUser.uid,
        'type': activityType,
        'data': activityData,
        'timestamp': DateTime.now(),
      });
      return true;
    } catch (e) {
      print('Fehler beim Hinzufügen der Aktivität: $e');
      return false;
    }
  }

  Stream<List<Map<String, dynamic>>> getFriendActivityFeed() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) return [];

      final data = snapshot.data();
      if (data == null) return [];

      final friends = data['friends'] as List<dynamic>? ?? [];
      if (friends.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('activityFeed')
          .where('userId', whereIn: friends)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }
}
