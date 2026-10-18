import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/notification_channel.dart';
import '../cubit/checkin_cubit.dart';
import '../cubit/checkin_state.dart';

class CreateCheckInPage extends StatefulWidget {
  const CreateCheckInPage({super.key});

  @override
  State<CreateCheckInPage> createState() => _CreateCheckInPageState();
}

class _CreateCheckInPageState extends State<CreateCheckInPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _durationController = TextEditingController();

  final Set<NotificationChannel> _selectedChannels = {};

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _toggleChannel(NotificationChannel channel) {
    setState(() {
      if (_selectedChannels.contains(channel)) {
        _selectedChannels.remove(channel);
      } else {
        _selectedChannels.add(channel);
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedChannels.isEmpty) {
      _showError('Select at least one notification channel.');
      return;
    }

    final duration = int.tryParse(
      _durationController.text.trim(),
    );

    if (duration == null || duration <= 0) {
      _showError('Enter a valid duration greater than 0 minutes.');
      return;
    }

    if (_selectedChannels.contains(NotificationChannel.email) &&
        _emailController.text.trim().isEmpty) {
      _showError(
        'Enter a recipient email when email notifications are enabled.',
      );
      return;
    }

    if (_selectedChannels.contains(NotificationChannel.sms) &&
        _phoneController.text.trim().isEmpty) {
      _showError(
        'Enter a recipient phone number when SMS notifications are enabled.',
      );
      return;
    }

    context.read<CheckInCubit>().create(
          name: _nameController.text.trim(),
          message: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          recipientEmail: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          recipientPhone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          channels: _selectedChannels.toList(),
          durationMinutes: duration,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckInCubit, CheckInState>(
      listener: (context, state) {
        if (state is CheckInCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in created successfully.'),
            ),
          );

          Navigator.of(context).pop(state.checkIn);
        }

        if (state is CheckInError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Check-In'),
        ),
        body: SafeArea(
          child: BlocBuilder<CheckInCubit, CheckInState>(
            builder: (context, state) {
              final isLoading = state is CheckInLoading;

              return Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Set up your check-in',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'If you do not check in before the deadline, '
                      'your selected notification channels can be triggered.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Check-in name',
                        hintText: 'e.g. Morning check-in',
                        prefixIcon: Icon(Icons.title),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a check-in name.';
                        }

                        if (value.trim().length > 255) {
                          return 'Name cannot exceed 255 characters.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _messageController,
                      enabled: !isLoading,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Message',
                        hintText: 'Optional message to send...',
                        prefixIcon: Icon(Icons.message_outlined),
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text(
                      'Notification channels',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Choose how the notification should be delivered.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const SizedBox(height: 12),

                    CheckboxListTile(
                      value: _selectedChannels.contains(
                        NotificationChannel.email,
                      ),
                      onChanged: isLoading
                          ? null
                          : (_) {
                              _toggleChannel(
                                NotificationChannel.email,
                              );
                            },
                      title: const Text('Email'),
                      subtitle: const Text(
                        'Send a notification by email',
                      ),
                      secondary: const Icon(Icons.email_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),

                    CheckboxListTile(
                      value: _selectedChannels.contains(
                        NotificationChannel.sms,
                      ),
                      onChanged: isLoading
                          ? null
                          : (_) {
                              _toggleChannel(
                                NotificationChannel.sms,
                              );
                            },
                      title: const Text('SMS'),
                      subtitle: const Text(
                        'Send a notification by SMS',
                      ),
                      secondary: const Icon(Icons.sms_outlined),
                      contentPadding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 20),

                    if (_selectedChannels.contains(
                      NotificationChannel.email,
                    )) ...[
                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Recipient email',
                          hintText: 'recipient@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_selectedChannels.contains(
                            NotificationChannel.email,
                          )) {
                            return null;
                          }

                          if (value == null || value.trim().isEmpty) {
                            return 'Enter the recipient email.';
                          }

                          final emailRegex = RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          );

                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Enter a valid email address.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                    ],

                    if (_selectedChannels.contains(
                      NotificationChannel.sms,
                    )) ...[
                      TextFormField(
                        controller: _phoneController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Recipient phone',
                          hintText: '+251...',
                          prefixIcon: Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (!_selectedChannels.contains(
                            NotificationChannel.sms,
                          )) {
                            return null;
                          }

                          if (value == null || value.trim().isEmpty) {
                            return 'Enter the recipient phone number.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _durationController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: 'e.g. 60',
                        suffixText: 'minutes',
                        prefixIcon: Icon(Icons.timer_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter a duration.';
                        }

                        final duration = int.tryParse(
                          value.trim(),
                        );

                        if (duration == null || duration <= 0) {
                          return 'Enter a valid duration greater than 0.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Check-In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}