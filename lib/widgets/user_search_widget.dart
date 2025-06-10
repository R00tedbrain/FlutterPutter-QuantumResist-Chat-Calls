import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/call_provider.dart';
import '../models/user.dart';
import '../l10n/app_localizations.dart';

/// Widget de búsqueda de usuarios para crear nuevas salas de chat
class UserSearchWidget extends StatefulWidget {
  final Function(User user) onUserSelected;
  final VoidCallback? onCancel;

  const UserSearchWidget({
    super.key,
    required this.onUserSelected,
    this.onCancel,
  });

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  List<User> _searchResults = [];
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.length >= 2) {
      _performSearch(query);
    } else {
      setState(() {
        _searchResults.clear();
        _error = null;
      });
    }
  }

  Future<void> _performSearch(String query) async {
    if (_isSearching) return;

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final callProvider = Provider.of<CallProvider>(context, listen: false);
      final currentUserId = authProvider.user?.id;
      final token = authProvider.token ?? '';

      final results = await callProvider.searchUsers(query, token);

      // Filtrar el usuario actual de los resultados
      final filteredResults =
          results.where((user) => user.id != currentUserId).toList();

      if (mounted) {
        setState(() {
          _searchResults = filteredResults;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _error = l10n.errorSearchingUsersDetails(e.toString());
          _searchResults.clear();
          _isSearching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header más compacto
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.searchUser,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.onCancel != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: widget.onCancel,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Campo de búsqueda más compacto
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchByName,
              hintStyle: const TextStyle(fontSize: 14),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _isSearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults.clear();
                              _error = null;
                            });
                          },
                          visualDensity: VisualDensity.compact,
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),

          // Resultados de búsqueda con scroll mejorado
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context)!;

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
                if (_searchController.text.trim().length >= 2) {
                  _performSearch(_searchController.text.trim());
                }
              },
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.writeAtLeast2Characters,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.searchingUsers),
          ],
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.noUsersFoundWith(_searchController.text),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue,
              child: Text(
                user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            title: Text(
              user.nickname,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              'ID: ${user.id}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chat_bubble_outline, size: 20),
            onTap: () {
              widget.onUserSelected(user);
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
