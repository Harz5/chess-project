import 'package:flutter/material.dart';
import '../services/social_service.dart';
import '../models/user_profile.dart';
import '../models/friend_request.dart';
import '../models/message.dart';

/// Provider für die Verwaltung der Social Features
class SocialProvider extends ChangeNotifier {
  final SocialService _socialService = SocialService();

  // Benutzerprofil
  UserProfile? _currentUserProfile;
  bool _isLoadingProfile = false;
  String _profileError = '';

  // Freunde
  List<UserProfile> _friends = [];
  final bool _isLoadingFriends = false;
  String _friendsError = '';

  // Freundschaftsanfragen
  List<FriendRequest> _pendingRequests = [];
  final bool _isLoadingRequests = false;
  String _requestsError = '';

  // Nachrichten
  final Map<String, List<Message>> _messages = {};
  bool _isSendingMessage = false;
  String _messageError = '';

  // Spieleinladungen
  List<Map<String, dynamic>> _gameInvitations = [];
  final bool _isLoadingInvitations = false;
  String _invitationsError = '';

  // Aktivitäts-Feed
  List<Map<String, dynamic>> _activityFeed = [];
  final bool _isLoadingFeed = false;
  String _feedError = '';

  // Benutzersuche
  List<UserProfile> _searchResults = [];
  bool _isSearching = false;
  String _searchError = '';

  // Getter
  UserProfile? get currentUserProfile => _currentUserProfile;
  bool get isLoadingProfile => _isLoadingProfile;
  String get profileError => _profileError;

  List<UserProfile> get friends => _friends;
  bool get isLoadingFriends => _isLoadingFriends;
  String get friendsError => _friendsError;

  List<FriendRequest> get pendingRequests => _pendingRequests;
  bool get isLoadingRequests => _isLoadingRequests;
  String get requestsError => _requestsError;

  Map<String, List<Message>> get messages => _messages;
  bool get isSendingMessage => _isSendingMessage;
  String get messageError => _messageError;

  List<Map<String, dynamic>> get gameInvitations => _gameInvitations;
  bool get isLoadingInvitations => _isLoadingInvitations;
  String get invitationsError => _invitationsError;

  List<Map<String, dynamic>> get activityFeed => _activityFeed;
  bool get isLoadingFeed => _isLoadingFeed;
  String get feedError => _feedError;

  List<UserProfile> get searchResults => _searchResults;
  bool get isSearching => _isSearching;
  String get searchError => _searchError;

  // Konstruktor
  SocialProvider() {
    _initializeStreams();
    loadCurrentUserProfile();
  }

  // Initialisiert alle Streams
  void _initializeStreams() {
    // Freunde-Stream
    _socialService.getFriends().listen((friends) {
      _friends = friends;
      notifyListeners();
    }, onError: (error) {
      _friendsError = 'Fehler beim Laden der Freunde: $error';
      notifyListeners();
    });

    // Freundschaftsanfragen-Stream
    _socialService.getPendingFriendRequests().listen((requests) {
      _pendingRequests = requests;
      notifyListeners();
    }, onError: (error) {
      _requestsError = 'Fehler beim Laden der Anfragen: $error';
      notifyListeners();
    });

    // Spieleinladungen-Stream
    _socialService.getGameInvitations().listen((invitations) {
      _gameInvitations = invitations;
      notifyListeners();
    }, onError: (error) {
      _invitationsError = 'Fehler beim Laden der Einladungen: $error';
      notifyListeners();
    });

    // Aktivitäts-Feed-Stream
    _socialService.getFriendActivityFeed().listen((feed) {
      _activityFeed = feed;
      notifyListeners();
    }, onError: (error) {
      _feedError = 'Fehler beim Laden des Feeds: $error';
      notifyListeners();
    });
  }

  // Lädt das aktuelle Benutzerprofil
  Future<void> loadCurrentUserProfile() async {
    _isLoadingProfile = true;
    _profileError = '';
    notifyListeners();

    try {
      _currentUserProfile = await _socialService.getCurrentUserProfile();
      _isLoadingProfile = false;
      notifyListeners();
    } catch (e) {
      _profileError = 'Fehler beim Laden des Profils: $e';
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  // Aktualisiert das Benutzerprofil
  Future<bool> updateUserProfile(UserProfile profile) async {
    _isLoadingProfile = true;
    _profileError = '';
    notifyListeners();

    try {
      final success = await _socialService.updateUserProfile(profile);

      if (success) {
        _currentUserProfile = profile;
      } else {
        _profileError = 'Fehler beim Aktualisieren des Profils';
      }

      _isLoadingProfile = false;
      notifyListeners();

      return success;
    } catch (e) {
      _profileError = 'Fehler beim Aktualisieren des Profils: $e';
      _isLoadingProfile = false;
      notifyListeners();
      return false;
    }
  }

  // Sendet eine Freundschaftsanfrage
  Future<bool> sendFriendRequest(String toUserId) async {
    try {
      return await _socialService.sendFriendRequest(toUserId);
    } catch (e) {
      _requestsError = 'Fehler beim Senden der Anfrage: $e';
      notifyListeners();
      return false;
    }
  }

  // Beantwortet eine Freundschaftsanfrage
  Future<bool> respondToFriendRequest(String requestId, String response) async {
    try {
      return await _socialService.respondToFriendRequest(requestId, response);
    } catch (e) {
      _requestsError = 'Fehler beim Beantworten der Anfrage: $e';
      notifyListeners();
      return false;
    }
  }

  // Lädt Nachrichten für einen bestimmten Benutzer
  void loadMessages(String userId) {
    _socialService.getMessages(userId).listen((messageList) {
      _messages[userId] = messageList;
      notifyListeners();
    }, onError: (error) {
      _messageError = 'Fehler beim Laden der Nachrichten: $error';
      notifyListeners();
    });
  }

  // Sendet eine Nachricht
  Future<bool> sendMessage(String toUserId, String content) async {
    _isSendingMessage = true;
    _messageError = '';
    notifyListeners();

    try {
      final success = await _socialService.sendMessage(toUserId, content);

      if (!success) {
        _messageError = 'Fehler beim Senden der Nachricht';
      }

      _isSendingMessage = false;
      notifyListeners();

      return success;
    } catch (e) {
      _messageError = 'Fehler beim Senden der Nachricht: $e';
      _isSendingMessage = false;
      notifyListeners();
      return false;
    }
  }

  // Markiert eine Nachricht als gelesen
  Future<bool> markMessageAsRead(String messageId) async {
    try {
      return await _socialService.markMessageAsRead(messageId);
    } catch (e) {
      _messageError = 'Fehler beim Markieren der Nachricht: $e';
      notifyListeners();
      return false;
    }
  }

  // Aktualisiert den Online-Status
  Future<bool> updateOnlineStatus(bool isOnline) async {
    try {
      return await _socialService.updateOnlineStatus(isOnline);
    } catch (e) {
      _profileError = 'Fehler beim Aktualisieren des Status: $e';
      notifyListeners();
      return false;
    }
  }

  // Sendet eine Spieleinladung
  Future<bool> sendGameInvitation(
      String toUserId, Map<String, dynamic> gameSettings) async {
    try {
      return await _socialService.sendGameInvitation(toUserId, gameSettings);
    } catch (e) {
      _invitationsError = 'Fehler beim Senden der Einladung: $e';
      notifyListeners();
      return false;
    }
  }

  // Beantwortet eine Spieleinladung
  Future<bool> respondToGameInvitation(
      String invitationId, String response) async {
    try {
      return await _socialService.respondToGameInvitation(
          invitationId, response);
    } catch (e) {
      _invitationsError = 'Fehler beim Beantworten der Einladung: $e';
      notifyListeners();
      return false;
    }
  }

  // Sucht nach Benutzern
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _searchError = '';
    notifyListeners();

    try {
      _searchResults = await _socialService.searchUsers(query);
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _searchError = 'Fehler bei der Suche: $e';
      _isSearching = false;
      notifyListeners();
    }
  }

  // Fügt eine Aktivität zum Feed hinzu
  Future<bool> addActivityToFeed(
      String activityType, Map<String, dynamic> activityData) async {
    try {
      return await _socialService.addActivityToFeed(activityType, activityData);
    } catch (e) {
      _feedError = 'Fehler beim Hinzufügen der Aktivität: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    // Aktualisiere den Online-Status auf offline
    updateOnlineStatus(false);
    super.dispose();
  }
}
