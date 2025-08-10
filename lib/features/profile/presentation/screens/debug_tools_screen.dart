import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../services/remote_config_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/ai_demo/ai_demo_screen.dart';
import 'push_notification_test_screen.dart';

class DebugToolsScreen extends StatefulWidget {
  const DebugToolsScreen({Key? key}) : super(key: key);

  @override
  State<DebugToolsScreen> createState() => _DebugToolsScreenState();
}

class _DebugToolsScreenState extends State<DebugToolsScreen> {
  /// Show remote config values in a clean, read-only dialog
  void _showRemoteConfigStatus() async {
    final remoteConfig = RemoteConfigService();
    final configValues = remoteConfig.getDisplayConfigValues();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remote Config Values',
            style: AppTheme.titleLarge,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: configValues['status'] == 'initialized' 
                        ? AppTheme.success.withOpacity(0.1)
                        : AppTheme.destructive.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    configValues['status'] == 'initialized' ? 'Active' : 'Not Initialized',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: configValues['status'] == 'initialized' 
                          ? AppTheme.success
                          : AppTheme.destructive,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Config values list
                ...configValues.entries
                    .where((entry) => entry.key != 'status' && 
                                     entry.key != 'last_fetch_time' && 
                                     entry.key != 'last_fetch_status' &&
                                     entry.key != 'all_parameters' &&
                                     entry.key != 'default_value' &&
                                     entry.key != 'string_value' &&
                                     entry.key != 'parameter_exists' &&
                                     entry.key != 'error')
                    .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              entry.key,
                              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.value.toString(),
                                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                
                // Last fetch time (if available)
                if (configValues['last_fetch_time'] != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${configValues['last_fetch_time']}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Refresh remote config
                Navigator.of(context).pop();
                await remoteConfig.refresh();
                // Show updated values
                _showRemoteConfigStatus();
              },
              child: const Text(
                'Refresh',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF008080),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Debug Tools',
          style: AppTheme.headlineMedium,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Debug Tools Container
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    // Firebase Test (Remote Configs)
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0x33008080),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.cloud,
                            color: Color(0xFF008080),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            'Firebase Test',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEBUG',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'Remote Config Values',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                      onTap: _showRemoteConfigStatus,
                    ),
                    const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                    
                    // AI Demo
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0x33008080),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.psychology,
                            color: Color(0xFF008080),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            'AI Demo',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEBUG',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'AI Features Testing',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const AIDemoScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: Color(0xFFF3F4F6)),
                    
                    // Push Notifications Test
                    ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(0x33008080),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications,
                            color: Color(0xFF008080),
                            size: 20,
                          ),
                        ),
                      ),
                      title: Row(
                        children: [
                          const Text(
                            'Push Notifications',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              fontSize: 18,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEBUG',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text(
                        'Notification Testing',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFF9CA3AF),
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PushNotificationTestScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Debug Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF59E0B),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFFD97706),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Debug Mode',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'These tools are only available in debug mode for development and testing purposes. They will not be visible in production builds.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 