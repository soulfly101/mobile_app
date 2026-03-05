import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/coin_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CoinViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Market (Live)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<CoinViewModel>().refresh(),
          ),
        ],
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, CoinViewModel vm) {
    // Loading first time
    if (vm.isLoading && vm.coins.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                'Error loading coins',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                vm.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<CoinViewModel>().loadCoins(),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (vm.coins.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    // List + pull-to-refresh
    return RefreshIndicator(
      onRefresh: () => context.read<CoinViewModel>().refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: vm.coins.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final coin = vm.coins[index];
          final change = coin.change24h;

          final changeText = (change == null)
              ? 'N/A'
              : '${change.toStringAsFixed(2)}%';

          final changeColor = (change != null && change < 0)
              ? Colors.red
              : Colors.green;

          return Card(
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  coin.imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.currency_bitcoin),
                ),
              ),
              title: Text('${coin.name} (${coin.symbol})'),
              subtitle: Text(
                '24h: $changeText',
                style: TextStyle(color: changeColor),
              ),
              trailing: Text(
                '\$${coin.currentPrice.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}