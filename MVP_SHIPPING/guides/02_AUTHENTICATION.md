# 🔐 User Authentication Guide

> For MVP, we'll use device-based authentication. It's simple and requires no login.

---

## Why Device-Based Auth for MVP?

| Approach | Pros | Cons |
|----------|------|------|
| **Device-Based** | No friction, instant use | No cross-device sync |
| Email/Password | Cross-device sync | Friction, abandonment |
| Social Login | Easy signup | Requires Apple for iOS |

**Recommendation:** Start with device-based. Add social login in v1.1.

---

## Step 1: Add Package

```bash
cd /Users/cemyonetim/Development/KuranChat/mobile
flutter pub add flutter_secure_storage
flutter pub add uuid
```

---

## Step 2: Create Auth Service

Create `mobile/lib/services/auth_service.dart`:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  static const String _deviceIdKey = 'device_id';
  static const String _userIdKey = 'user_id';
  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() => _instance;
  AuthService._internal();

  String? _deviceId;
  String? _userId;

  String? get deviceId => _deviceId;
  String? get userId => _userId;

  /// Initialize auth - call this on app startup
  Future<void> initialize() async {
    _deviceId = await _storage.read(key: _deviceIdKey);
    _userId = await _storage.read(key: _userIdKey);
    
    // Generate device ID if first launch
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      await _storage.write(key: _deviceIdKey, value: _deviceId);
    }
  }

  /// Set user ID after backend creates/returns user
  Future<void> setUserId(String userId) async {
    _userId = userId;
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get auth headers for API requests
  Map<String, String> getAuthHeaders() {
    return {
      'X-Device-ID': _deviceId ?? '',
      if (_userId != null) 'X-User-ID': _userId!,
    };
  }

  /// Clear all auth data (for logout/reset)
  Future<void> clearAuth() async {
    await _storage.delete(key: _deviceIdKey);
    await _storage.delete(key: _userIdKey);
    _deviceId = null;
    _userId = null;
  }
}
```

---

## Step 3: Initialize in main.dart

```dart
import 'services/auth_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize auth first
  await AuthService().initialize();
  
  // Initialize RevenueCat with user ID
  await SubscriptionService().initialize();
  if (AuthService().deviceId != null) {
    await SubscriptionService().setUserId(AuthService().deviceId!);
  }
  
  runApp(const MyApp());
}
```

---

## Step 4: Update API Service

Update `mobile/lib/services/api_service.dart` to include auth headers:

```dart
import 'auth_service.dart';

class ApiService {
  // ... existing code ...

  Future<Map<String, String>> _getHeaders() async {
    final authHeaders = AuthService().getAuthHeaders();
    return {
      'Content-Type': 'application/json',
      ...authHeaders,
    };
  }

  // Use _getHeaders() in all API calls
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    // ... handle response
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    // ... handle response
  }
}
```

---

## Step 5: Backend Changes

### Update User Controller

In `backend/src/chat/user.controller.ts`:

```typescript
import { Controller, Post, Headers, Get } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Controller('api/user')
export class UserController {
  constructor(private prisma: PrismaService) {}

  @Post('register-device')
  async registerDevice(@Headers('x-device-id') deviceId: string) {
    if (!deviceId) {
      return { error: 'Device ID required' };
    }

    // Find or create user
    let user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          deviceId,
          progress: {
            create: {}, // Create default progress
          },
        },
        include: { progress: true },
      });
    }

    return {
      userId: user.id,
      isNewUser: !user.progress?.totalVersesRead,
      progress: user.progress,
    };
  }

  @Get('me')
  async getCurrentUser(@Headers('x-device-id') deviceId: string) {
    if (!deviceId) {
      return { error: 'Device ID required' };
    }

    const user = await this.prisma.user.findUnique({
      where: { deviceId },
      include: { progress: true },
    });

    if (!user) {
      return { error: 'User not found' };
    }

    return user;
  }
}
```

---

## Step 6: Register User on First Launch

In your app initialization (e.g., after onboarding):

```dart
Future<void> registerUser() async {
  try {
    final response = await ApiService().post('/user/register-device', {});
    
    if (response['userId'] != null) {
      await AuthService().setUserId(response['userId']);
      
      // Also update RevenueCat with the user ID
      await SubscriptionService().setUserId(response['userId']);
    }
  } catch (e) {
    print('Error registering user: $e');
    // App can still work without server registration
  }
}
```

---

## Step 7: Handle Auth in Existing Services

Update any service that needs user context:

```dart
// Example: Saving reading progress to server
Future<void> syncReadingProgress() async {
  if (AuthService().userId == null) {
    // Not registered yet, skip sync
    return;
  }
  
  final localProgress = await ReadingProgressService().getAllProgress();
  
  await ApiService().post('/user/progress/sync', {
    'progress': localProgress,
  });
}
```

---

## iOS Specific: Keychain Sharing

For iOS, add to `ios/Runner/Runner.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>keychain-access-groups</key>
    <array>
        <string>$(AppIdentifierPrefix)com.example.ayet_rehberi</string>
    </array>
</dict>
</plist>
```

---

## Testing Auth

```dart
// In debug mode, you can test:
void testAuth() async {
  await AuthService().initialize();
  print('Device ID: ${AuthService().deviceId}');
  
  // Register with backend
  await registerUser();
  print('User ID: ${AuthService().userId}');
}
```

---

## Future: Adding Social Login (v1.1)

When ready, add:
- `sign_in_with_apple` package (required for iOS)
- `google_sign_in` package

Then link social accounts to existing device-based users for cross-device sync.

---

*Auth is complete when you see User records being created in your database!*



