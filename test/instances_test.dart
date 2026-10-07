import 'package:capidock/features/instances/domain/server_instance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Endpoint validation rejects credentials, insecure URLs and shell input',
    () {
      expect(
        ServerInstance.validateHost(
          'https://user:token@coolify.example.com',
          InstanceType.coolify,
        ),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost(
          'http://coolify.example.com',
          InstanceType.coolify,
        ),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost(
          'https://coolify.example.com?token=secret',
          InstanceType.coolify,
        ),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost('host;whoami', InstanceType.ssh),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost(
          'https://coolify.example.com:99999',
          InstanceType.coolify,
        ),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost(
          'https://coolify.example.com:0',
          InstanceType.coolify,
        ),
        isNotNull,
      );
      expect(
        ServerInstance.validateHost(
          'https://coolify.example.com:8443',
          InstanceType.coolify,
        ),
        isNull,
      );
      expect(
        ServerInstance.validateHost('2001:db8::1', InstanceType.ssh),
        isNull,
      );
    },
  );
}
