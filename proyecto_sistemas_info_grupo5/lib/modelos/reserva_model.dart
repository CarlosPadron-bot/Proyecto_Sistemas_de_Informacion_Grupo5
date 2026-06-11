
class Reserva {
  final String id;
  final String usuarioId;
  final String destinoId;
  final String destinoNombre;
  final double precioTotal;
  final DateTime fechaCompra;
  final String urlImagen; // <-- 1. Agregamos la propiedad aquí

  Reserva({
    required this.id,
    required this.usuarioId,
    required this.destinoId,
    required this.destinoNombre,
    required this.precioTotal,
    required this.fechaCompra,
    required this.urlImagen, // <-- 2. La requerimos en el constructor
  });

  // 3. Mapeo para enviar los datos de forma limpia a Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'destinoId': destinoId,
      'destinoNombre': destinoNombre,
      'precioTotal': precioTotal,
      'fechaCompra': fechaCompra.toIso8601String().substring(0, 10), // Guarda "AAAA-MM-DD"
      'urlImagen': urlImagen, // <-- 4. Se incluye en el mapa de Firebase
    };
  }

  // 5. Factoría para reconstruir el objeto cuando se lee desde Firebase
  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      destinoId: json['destinoId'] ?? '',
      destinoNombre: json['destinoNombre'] ?? '',
      precioTotal: (json['precioTotal'] ?? json['precio'] ?? 0.0).toDouble(),
      fechaCompra: json['fechaCompra'] != null 
          ? DateTime.parse(json['fechaCompra']) 
          : DateTime.now(),
      urlImagen: json['urlImagen'] ?? '', // <-- 6. Lee la imagen de Firebase sin caerse si viene vacía
    );
  }
}