import 'package:flutter_test/flutter_test.dart';
import 'package:nonna_app/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    group('Environment Detection', () {
      test('provides environment getter', () {
        expect(AppConfig.environment, isA<AppEnvironment>());
      });

      test('provides environment flags', () {
        expect(AppConfig.isDevelopment, isA<bool>());
        expect(AppConfig.isStaging, isA<bool>());
        expect(AppConfig.isProduction, isA<bool>());
      });

      test('provides environment name', () {
        expect(AppConfig.environmentName, isNotEmpty);
      });
    });

    group('Base URLs', () {
      test('provides base URL', () {
        expect(AppConfig.baseUrl, isNotEmpty);
        expect(AppConfig.baseUrl, startsWith('https://'));
        expect(AppConfig.baseUrl, contains('nonna.app'));
      });

      test('provides API base URL', () {
        expect(AppConfig.apiBaseUrl, isNotEmpty);
        expect(AppConfig.apiBaseUrl, startsWith('https://'));
      });

      test('provides web app URL', () {
        expect(AppConfig.webAppUrl, isNotEmpty);
        expect(AppConfig.webAppUrl, startsWith('https://'));
      });

      test('base URLs vary by environment', () {
        // All URLs should be well-formed regardless of environment
        expect(AppConfig.baseUrl, isNotEmpty);
        expect(AppConfig.apiBaseUrl, isNotEmpty);
        expect(AppConfig.webAppUrl, isNotEmpty);
      });
    });

    group('Feature Flags', () {
      test('provides debug logging flag', () {
        expect(AppConfig.debugLogging, isA<bool>());
      });

      test('provides analytics enabled flag', () {
        expect(AppConfig.analyticsEnabled, isA<bool>());
      });

      test('provides crash reporting flag', () {
        expect(AppConfig.crashReportingEnabled, isA<bool>());
      });

      test('provides beta features flag', () {
        expect(AppConfig.betaFeaturesEnabled, isA<bool>());
      });

      test('debug logging is enabled only in development', () {
        if (AppConfig.isDevelopment) {
          expect(AppConfig.debugLogging, isTrue);
        } else {
          expect(AppConfig.debugLogging, isFalse);
        }
      });

      test('analytics is disabled in development', () {
        if (AppConfig.isDevelopment) {
          expect(AppConfig.analyticsEnabled, isFalse);
        } else {
          expect(AppConfig.analyticsEnabled, isTrue);
        }
      });

      test('crash reporting is enabled only in production', () {
        if (AppConfig.isProduction) {
          expect(AppConfig.crashReportingEnabled, isTrue);
        } else {
          expect(AppConfig.crashReportingEnabled, isFalse);
        }
      });
    });

    group('App Information', () {
      test('provides app name', () {
        expect(AppConfig.appName, 'Nonna');
      });

      test('provides app tagline', () {
        expect(AppConfig.appTagline, isNotEmpty);
      });

      test('provides support email', () {
        expect(AppConfig.supportEmail, contains('@'));
        expect(AppConfig.supportEmail, contains('nonna.app'));
      });

      test('provides privacy policy URL', () {
        expect(AppConfig.privacyPolicyUrl, contains('privacy'));
      });

      test('provides terms of service URL', () {
        expect(AppConfig.termsOfServiceUrl, contains('terms'));
      });
    });

    group('Deep Link Configuration', () {
      test('provides deep link scheme', () {
        expect(AppConfig.deepLinkScheme, 'nonna');
      });

      test('provides deep link host', () {
        expect(AppConfig.deepLinkHost, 'app');
      });

      test('provides universal link domains', () {
        expect(AppConfig.universalLinkDomains, isNotEmpty);
        for (final domain in AppConfig.universalLinkDomains) {
          expect(domain, contains('nonna.app'));
        }
      });
    });

    group('Share Configuration', () {
      test('provides default share message', () {
        expect(AppConfig.defaultShareMessage, isNotEmpty);
      });

      test('provides app store URL', () {
        expect(AppConfig.appStoreUrl, contains('apps.apple.com'));
      });

      test('provides play store URL', () {
        expect(AppConfig.playStoreUrl, contains('play.google.com'));
      });

      test('provides share referral tracking flag', () {
        expect(AppConfig.shareReferralTracking, isA<bool>());
      });

      test('referral tracking is enabled only in production', () {
        if (AppConfig.isProduction) {
          expect(AppConfig.shareReferralTracking, isTrue);
        } else {
          expect(AppConfig.shareReferralTracking, isFalse);
        }
      });
    });

    group('Cache Configuration', () {
      test('provides max cache size', () {
        expect(AppConfig.maxCacheSizeMB, greaterThan(0));
      });

      test('cache size varies by environment', () {
        expect(AppConfig.maxCacheSizeMB, isIn([50, 100, 200]));
      });
    });

    group('Utility Methods', () {
      test('getFullUrl adds base URL to path', () {
        final url = AppConfig.getFullUrl('/test');
        expect(url, startsWith(AppConfig.baseUrl));
        expect(url, endsWith('/test'));
      });

      test('getFullUrl handles paths without leading slash', () {
        final url = AppConfig.getFullUrl('test');
        expect(url, endsWith('/test'));
      });

      test('getDeepLinkUrl creates deep link URL', () {
        final url = AppConfig.getDeepLinkUrl('/profile/123');
        expect(url, startsWith('${AppConfig.deepLinkScheme}://'));
        expect(url, contains(AppConfig.deepLinkHost));
        expect(url, endsWith('/profile/123'));
      });

      test('getDeepLinkUrl handles paths without leading slash', () {
        final url = AppConfig.getDeepLinkUrl('profile/123');
        expect(url, endsWith('/profile/123'));
      });

      test('getFullUrl and getDeepLinkUrl produce different formats', () {
        final fullUrl = AppConfig.getFullUrl('/test');
        final deepLinkUrl = AppConfig.getDeepLinkUrl('/test');
        expect(fullUrl, isNot(equals(deepLinkUrl)));
        expect(fullUrl, startsWith('https://'));
        expect(deepLinkUrl, startsWith('nonna://'));
      });
    });

    group('Environment-Specific Behavior', () {
      test('development environment has appropriate settings', () {
        if (AppConfig.isDevelopment) {
          expect(AppConfig.debugLogging, isTrue);
          expect(AppConfig.analyticsEnabled, isFalse);
          expect(AppConfig.crashReportingEnabled, isFalse);
          expect(AppConfig.betaFeaturesEnabled, isTrue);
          expect(AppConfig.baseUrl, contains('dev'));
        }
      });

      test('staging environment has appropriate settings', () {
        if (AppConfig.isStaging) {
          expect(AppConfig.debugLogging, isFalse);
          expect(AppConfig.analyticsEnabled, isTrue);
          expect(AppConfig.crashReportingEnabled, isFalse);
          expect(AppConfig.betaFeaturesEnabled, isTrue);
          expect(AppConfig.baseUrl, contains('staging'));
        }
      });

      test('production environment has appropriate settings', () {
        if (AppConfig.isProduction) {
          expect(AppConfig.debugLogging, isFalse);
          expect(AppConfig.analyticsEnabled, isTrue);
          expect(AppConfig.crashReportingEnabled, isTrue);
          expect(AppConfig.betaFeaturesEnabled, isFalse);
          expect(AppConfig.baseUrl, equals('https://nonna.app'));
        }
      });
    });
  });

  group('AppEnvironment', () {
    test('has all expected values', () {
      expect(AppEnvironment.values.length, 3);
      expect(AppEnvironment.values, contains(AppEnvironment.development));
      expect(AppEnvironment.values, contains(AppEnvironment.staging));
      expect(AppEnvironment.values, contains(AppEnvironment.production));
    });

    test('provides display names', () {
      expect(AppEnvironment.development.displayName, 'Development');
      expect(AppEnvironment.staging.displayName, 'Staging');
      expect(AppEnvironment.production.displayName, 'Production');
    });

    test('provides short names', () {
      expect(AppEnvironment.development.shortName, 'dev');
      expect(AppEnvironment.staging.shortName, 'stage');
      expect(AppEnvironment.production.shortName, 'prod');
    });

    test('display names are properly capitalized', () {
      for (final env in AppEnvironment.values) {
        expect(env.displayName[0], equals(env.displayName[0].toUpperCase()));
      }
    });

    test('short names are lowercase', () {
      for (final env in AppEnvironment.values) {
        expect(env.shortName, equals(env.shortName.toLowerCase()));
      }
    });
  });

  group('Configuration Consistency', () {
    test('URLs are consistent across config', () {
      expect(AppConfig.privacyPolicyUrl, startsWith(AppConfig.webAppUrl));
      expect(AppConfig.termsOfServiceUrl, startsWith(AppConfig.webAppUrl));
    });

    test('universal link domains match base URL domain', () {
      final baseUrlDomain = Uri.parse(AppConfig.baseUrl).host;
      expect(AppConfig.universalLinkDomains, contains(baseUrlDomain));
    });

    test('environment flags are mutually exclusive', () {
      final flagsSet = [
        AppConfig.isDevelopment,
        AppConfig.isStaging,
        AppConfig.isProduction,
      ];
      final trueCount = flagsSet.where((flag) => flag).length;
      expect(trueCount, 1,
          reason: 'Exactly one environment flag should be true');
    });

    test('all URLs are HTTPS', () {
      expect(AppConfig.baseUrl, startsWith('https://'));
      expect(AppConfig.apiBaseUrl, startsWith('https://'));
      expect(AppConfig.webAppUrl, startsWith('https://'));
      expect(AppConfig.privacyPolicyUrl, startsWith('https://'));
      expect(AppConfig.termsOfServiceUrl, startsWith('https://'));
    });
  });

  group('Edge Cases', () {
    test('handles empty paths in getFullUrl', () {
      final url = AppConfig.getFullUrl('');
      expect(url, equals('${AppConfig.baseUrl}/'));
    });

    test('handles empty paths in getDeepLinkUrl', () {
      final url = AppConfig.getDeepLinkUrl('');
      expect(url,
          equals('${AppConfig.deepLinkScheme}://${AppConfig.deepLinkHost}/'));
    });

    test('handles paths with multiple slashes', () {
      final url = AppConfig.getFullUrl('//test//path');
      expect(url, contains('//test//path'));
    });

    test('handles paths with query parameters', () {
      final url = AppConfig.getFullUrl('/test?param=value');
      expect(url, endsWith('/test?param=value'));
    });

    test('handles paths with fragments', () {
      final url = AppConfig.getFullUrl('/test#section');
      expect(url, endsWith('/test#section'));
    });
  });
}
