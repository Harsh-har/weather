import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_weather_hub/data/datasources/remote/weather_api.dart';
import 'package:news_weather_hub/data/models/weather/weather_model.dart';
import 'package:news_weather_hub/presentations/providers/weather_provider.dart';

class CitySearchDialog extends ConsumerStatefulWidget {
  const CitySearchDialog({super.key});

  @override
  ConsumerState<CitySearchDialog> createState() => _CitySearchDialogState();
}

class _CitySearchDialogState extends ConsumerState<CitySearchDialog> {
  final TextEditingController _controller = TextEditingController();
  List<LocationResult> _results = [];
  bool _isSearching = false;
  String? _error;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.length < 2) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _isSearching = true;
        _error = null;
      });

      try {
        final results = await ref.read(weatherProvider.notifier).searchCity(query);
        setState(() {
          _results = results;
          _isSearching = false;
          if (results.isEmpty) {
            _error = 'No cities found';
          }
        });
      } catch (e) {
        setState(() {
          _isSearching = false;
          _error = e.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Search City'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter city name...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_results.isNotEmpty)
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (context, index) {
                  final location = _results[index];
                  return ListTile(
                    title: Text(location.name),
                    subtitle: Text(
                      [location.admin1, location.country]
                          .where((e) => e != null && e!.isNotEmpty)
                          .join(', '),
                    ),
                    onTap: () {
                      // Fetch weather for this location
                      final weatherNotifier = ref.read(weatherProvider.notifier);
                      weatherNotifier.fetchWeather(
                        location.latitude,
                        location.longitude,
                      );
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}