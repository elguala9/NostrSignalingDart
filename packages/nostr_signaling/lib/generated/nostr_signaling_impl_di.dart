// AUTO-GENERATED - DO NOT CHANGE
// ignore_for_file: directives_ordering, library_prefixes, unnecessary_import, unused_import, lines_longer_than_80_chars, cascade_invocations
import 'package:singleton_manager/singleton_manager.dart';
import '../src/implementations/nostr_signaling_impl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:meta/meta.dart';
import 'package:dart_nostr/dart_nostr.dart';
import 'package:nostr_signaling/nostr_signaling.dart';
import '../src/interfaces/i_compression.dart';
import '../src/interfaces/i_nostr_signaling.dart';
import '../src/interfaces/i_relay.dart';
import '../src/nostr_relay_list.dart';
import '../src/types.dart';

class NostrSignalingImplDI extends NostrSignalingImpl implements ISingletonStandardDI {

  NostrSignalingImplDI() : super.emptyForDI();

  factory NostrSignalingImplDI.initializeDI() {
    final instance = NostrSignalingImplDI();
    instance.initializeDI();
    return instance;
  }

  factory NostrSignalingImplDI.initializeWithParametersDI(NostrKeyPair keyPair, {ICompressionEngine? compressionEngine}) {
    final instance = NostrSignalingImplDI();
    instance.relays = SingletonDIAccess.get<NostrRelayList>();
    instance.compressionEngine = compressionEngine;
    instance.keyPair = keyPair;
    return instance;
  }

  @override
  void initializeDI() {
    keyPair = SingletonDIAccess.get<NostrKeyPair>();
    relays = SingletonDIAccess.get<NostrRelayList>();
    if (SingletonDIAccess.exists<ICompressionEngine>()) compressionEngine = SingletonDIAccess.get<ICompressionEngine>();
  }
}
