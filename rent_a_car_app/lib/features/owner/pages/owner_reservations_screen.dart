import 'package:flutter/material.dart';
import 'package:rent_a_car_app/core/services/owner_service.dart';
import 'package:rent_a_car_app/core/models/owner.dart';
import 'package:rent_a_car_app/core/utils/base_url.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OwnerReservationsScreen extends StatefulWidget {
  @override
  _OwnerReservationsScreenState createState() => _OwnerReservationsScreenState();
}

class _OwnerReservationsScreenState extends State<OwnerReservationsScreen> {
  late Future<List<OwnerReservation>> _reservationsFuture;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _reservationsFuture = OwnerService.getOwnerReservations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reservas Recebidas'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<OwnerReservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar reservas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nenhuma reserva recebida.'));
          }
          final reservations = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: reservations.length,
            separatorBuilder: (_, __) => SizedBox(height: 16),
            itemBuilder: (context, index) {
              final r = reservations[index];
              final car = r.car;
              final client = r.client;
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          car.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    fixImageUrl(car.images.first.url),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.directions_car, color: Colors.grey[600]),
                                ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${car.marca} ${car.modelo}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                SizedBox(height: 4),
                                Text('Cliente: ${client.name}', style: TextStyle(fontSize: 14)),
                                Text('Email: ${client.email}', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _statusColor(r.status),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r.status,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.date_range, size: 18, color: Colors.grey[700]),
                          SizedBox(width: 6),
                          Text('De: ${_formatDate(r.startDate)}  Até: ${_formatDate(r.endDate)}'),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                          SizedBox(width: 6),
                          Text('Valor: ${r.price.toStringAsFixed(2)}'),
                        ],
                      ),
                      if (r.notes != null && r.notes!.isNotEmpty) ...[
                        SizedBox(height: 8),
                        Text('Observação: ${r.notes!}', style: TextStyle(color: Colors.grey[700])),
                      ],
                      if (r.status.toLowerCase() == 'pendente') ...[
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.check, color: Colors.white),
                                label: Text('Aprovar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _isLoadingAction ? null : () => _updateStatus(r.id, 'aprovada'),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.close, color: Colors.white),
                                label: Text('Rejeitar'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _isLoadingAction ? null : () => _updateStatus(r.id, 'rejeitada'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aprovada':
        return Colors.green;
      case 'rejeitada':
        return Colors.red;
      case 'pendente':
      default:
        return Colors.orange;
    }
  }

  void _updateStatus(String reservationId, String status) async {
    setState(() { _isLoadingAction = true; });
    try {
      await OwnerService.updateReservationStatus(reservationId, status);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reserva $status com sucesso!'), backgroundColor: Colors.black),
      );
      setState(() {
        _reservationsFuture = OwnerService.getOwnerReservations();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar reserva: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isLoadingAction = false; });
    }
  }

  String fixImageUrl(String url) {
    if (url.startsWith('http')) {
      return url.replaceFirst('localhost', kIsWeb ? 'localhost' : '10.0.2.2');
    } else {
      return '$baseUrl/$url';
    }
  }
} 