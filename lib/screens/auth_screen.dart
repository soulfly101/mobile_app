import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import '../utils/encryption_helper.dart';
import 'notes_list_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _currentPinResetController =
      TextEditingController();
  final TextEditingController _newPinResetController = TextEditingController();

  bool _isBusy = true;
  bool _isBiometricSupported = false;
  bool _hasSavedPin = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _currentPinResetController.dispose();
    _newPinResetController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final storedHash = await SecureStorageService.loadPinHash();
      final encryptionKey = await SecureStorageService.loadEncryptionKey();
      final canCheck = await _biometricService.canCheckBiometrics();
      final hasSavedPin = storedHash != null && encryptionKey != null;

      if (!mounted) {
        return;
      }

      setState(() {
        _hasSavedPin = hasSavedPin;
        _isBiometricSupported = canCheck;
        _isBusy = false;
      });

      if (hasSavedPin && canCheck) {
        await _authenticateWithBiometrics();
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isBusy = false);
      _showMessage(
        'Unable to initialize secure storage. Please restart the app.',
      );
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() => _isBusy = true);
    try {
      final authenticated = await _biometricService.authenticate();
      if (!mounted) {
        return;
      }

      if (authenticated) {
        _openNotes();
      } else {
        _showMessage('Biometric unlock was cancelled.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Biometric unlock is unavailable on this device.');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _handlePinAction() async {
    final pin = _pinController.text.trim();
    if (pin.length < 4 || pin.length > 6 || int.tryParse(pin) == null) {
      _showMessage('Enter a 4 to 6 digit PIN.');
      return;
    }

    setState(() => _isBusy = true);

    try {
      final storedHash = await SecureStorageService.loadPinHash();
      final encryptionKey = await SecureStorageService.loadEncryptionKey();
      final hasSavedPin = storedHash != null && encryptionKey != null;

      if (!hasSavedPin) {
        // Generate and save encryption key first
        final encryptionKey = EncryptionHelper.generateSecret();
        await SecureStorageService.saveEncryptionKey(encryptionKey);

        // Then save PIN hash
        final hash = sha256.convert(utf8.encode(pin)).toString();
        await SecureStorageService.savePinHash(hash);

        if (!mounted) {
          return;
        }

        setState(() => _hasSavedPin = true);
        _showMessage('PIN created. Your notes are now protected.');
        _openNotes();
        return;
      }

      final inputHash = sha256.convert(utf8.encode(pin)).toString();
      if (!mounted) {
        return;
      }

      if (inputHash == storedHash) {
        _openNotes();
      } else {
        _showMessage('Wrong PIN. Please try again.');
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Secure storage did not respond. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _showResetPinDialog() async {
    _currentPinResetController.clear();
    _newPinResetController.clear();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset PIN'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _currentPinResetController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Current PIN',
                  counterText: '',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPinResetController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'New PIN',
                  hintText: 'Enter 4 to 6 digits',
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final shouldClose = await _resetPin();
                if (shouldClose && dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _resetPin() async {
    final currentPin = _currentPinResetController.text.trim();
    final newPin = _newPinResetController.text.trim();

    if (!_isValidPin(currentPin) || !_isValidPin(newPin)) {
      _showMessage('Both current and new PINs must be 4 to 6 digits.');
      return false;
    }

    try {
      final storedHash = await SecureStorageService.loadPinHash();
      if (storedHash == null) {
        _showMessage('No saved PIN was found. Create one first.');
        return false;
      }

      final currentHash = sha256.convert(utf8.encode(currentPin)).toString();
      if (currentHash != storedHash) {
        _showMessage('Current PIN is incorrect.');
        return false;
      }

      final newHash = sha256.convert(utf8.encode(newPin)).toString();
      await SecureStorageService.savePinHash(newHash);
      if (!mounted) {
        return true;
      }

      _showMessage('PIN updated successfully.');
      return true;
    } catch (_) {
      if (!mounted) {
        return false;
      }
      _showMessage('Unable to reset PIN right now. Please try again.');
      return false;
    }
  }

  bool _isValidPin(String pin) {
    return pin.length >= 4 && pin.length <= 6 && int.tryParse(pin) != null;
  }

  void _openNotes() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const NotesListScreen()),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final helperTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[Color(0xFFE7F5EF), Color(0xFFF8FBF9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shield_outlined,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _hasSavedPin
                              ? 'Unlock Secure Notes'
                              : 'Create Your Secure Notes PIN',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _hasSavedPin
                              ? 'Use biometrics when available, or fall back to your PIN.'
                              : 'Set a 4 to 6 digit PIN to protect encrypted notes on this device.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: helperTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _pinController,
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: 'PIN',
                            hintText: 'Enter 4 to 6 digits',
                            counterText: '',
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _isBusy ? null : _handlePinAction,
                          child: _isBusy
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _hasSavedPin
                                      ? 'Unlock with PIN'
                                      : 'Create PIN',
                                ),
                        ),
                        if (_isBiometricSupported && _hasSavedPin) ...<Widget>[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: _isBusy
                                ? null
                                : _authenticateWithBiometrics,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Unlock with Biometrics'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _isBusy ? null : _showResetPinDialog,
                            child: const Text('Reset PIN'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
