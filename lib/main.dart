// ===========================================================================
// APP CONDUCTOR (DRIVER) - VERSIÓN MAESTRA FINAL (CORREGIDA)
// ===========================================================================
//
// CARACTERÍSTICAS INCLUIDAS:
// 1. Auth & Dashboard (Online/Offline).
// 2. Servicios Agendados/En Curso en el Dashboard.
// 3. Historial Detallado (Ruta, Carga, Ganancia Neta).
// 4. Módulo de Pagos (Consignaciones de la App al Conductor).
// 5. Registro de Vehículo (Normativa Colombia: SOAT, Tecno, Tarjeta Propiedad).

import 'package:flutter/material.dart'; // [EDU] UI Base
import 'package:google_fonts/google_fonts.dart'; // [EDU] Fuentes
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // [EDU] Iconos
import 'package:intl/intl.dart'; // [EDU] Formatos de moneda y fecha
import 'dart:async'; // [EDU] Timers

// ---------------------------------------------------------------------------
// 1. CONFIGURACIÓN VISUAL
// ---------------------------------------------------------------------------
class AppColors {
  static const Color orange = Color(0xFFFF6B35);
  static const Color blue = Color(0xFF0F2537);   // Color principal
  static const Color background = Color(0xFFF3F4F6); // Gris suave
  static const Color green = Color(0xFF10B981);  // Dinero / Éxito
  static const Color red = Color(0xFFEF4444);    // Error / Offline
  static const Color text = Color(0xFF1F2937);   // [CORRECCIÓN] Agregado color de texto
}

void main() {
  runApp(const AppCarreosDriver());
}

class AppCarreosDriver extends StatelessWidget {
  const AppCarreosDriver({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AppCarreos Driver',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.interTextTheme(), // Fuente técnica y legible
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        // [EDU] Estilo unificado para Inputs de formularios (Vehículos, Login)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          labelStyle: const TextStyle(color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      home: const DriverAuthScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. AUTENTICACIÓN
// ---------------------------------------------------------------------------
class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});
  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Icon(FontAwesomeIcons.truckFront, size: 60, color: AppColors.green),
              const SizedBox(height: 15),
              Text("AppCarreos\nSocios", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(50)),
                child: Row(
                  children: [
                    _buildTab("Ingresar", true),
                    _buildTab("Registrarse", false),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              if (!_isLogin) ...[
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subir foto..."))),
                  child: const CircleAvatar(radius: 40, backgroundColor: Colors.white24, child: Icon(Icons.camera_alt, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                _buildInput("Nombre Completo", Icons.person),
                const SizedBox(height: 15),
                _buildInput("Celular", Icons.phone),
                const SizedBox(height: 15),
              ],

              _buildInput("Correo o Celular", Icons.email),
              const SizedBox(height: 15),
              _buildInput("Contraseña", Icons.lock, isPassword: true),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard())),
                  child: Text(_isLogin ? "INICIAR TURNO" : "CREAR CUENTA"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String text, bool isLoginTab) {
    final bool isSelected = _isLogin == isLoginTab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isLogin = isLoginTab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? AppColors.green : Colors.transparent, borderRadius: BorderRadius.circular(50)),
          child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), hintText: hint),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. DASHBOARD PRINCIPAL (CON SERVICIOS ASIGNADOS)
// ---------------------------------------------------------------------------
class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});
  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  bool _isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: const Text("Panel Conductor", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER DE ESTADO
            Container(
              padding: const EdgeInsets.all(20),
              color: AppColors.blue,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() => _isOnline = !_isOnline);
                      if (_isOnline) {
                        Future.delayed(const Duration(seconds: 3), () {
                          if (mounted) _showNewRequestDialog(context);
                        });
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      decoration: BoxDecoration(
                          color: _isOnline ? AppColors.green : Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: const Offset(0, 4))]
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isOnline ? Icons.wifi : Icons.wifi_off, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(_isOnline ? "CONECTADO" : "DESCONECTADO", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Estadísticas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("Hoy", "\$120k"),
                      _buildStat("Viajes", "3"),
                      _buildStat("Calif", "4.9"),
                    ],
                  )
                ],
              ),
            ),

            // SECCIÓN: SERVICIOS ASIGNADOS (NUEVO)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isOnline) ...[
                    const Text("Servicios Asignados", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.blue)),
                    const SizedBox(height: 10),
                    // Tarjeta de Servicio Agendado
                    _scheduledServiceCard(context, "Mudanza Oficina", "Mañana, 8:00 AM", "\$ 250.000", "Calle 100 -> Chía"),
                    // Tarjeta de Servicio en Curso (Si hubiera)
                    _scheduledServiceCard(context, "Entrega Muebles", "En Curso", "\$ 45.000", "Homecenter -> Norte", isActive: true),
                  ] else ...[
                    const SizedBox(height: 50),
                    const Center(child: Icon(Icons.coffee, size: 60, color: Colors.grey)),
                    const SizedBox(height: 10),
                    const Center(child: Text("Conéctate para ver servicios", style: TextStyle(color: Colors.grey))),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tarjeta de servicio agendado o en curso
  Widget _scheduledServiceCard(BuildContext context, String title, String time, String price, String route, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if(isActive) Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveTripScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isActive ? Border.all(color: AppColors.green, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: isActive ? AppColors.green : Colors.blue.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(isActive ? Icons.navigation : Icons.calendar_month, color: isActive ? Colors.white : AppColors.blue),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("$time • $route", style: TextStyle(color: isActive ? AppColors.green : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 5),
                if (isActive) const Text("IR A MAPA >", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.blue))
              ],
            )
          ],
        ),
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: AppColors.blue),
            accountName: Text("Carlos Rodriguez"),
            accountEmail: Text("ID: DRV-8839"),
            currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=60")),
          ),
          ListTile(leading: const Icon(FontAwesomeIcons.truck), title: const Text("Mis Vehículos"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyVehiclesScreen()))),
          ListTile(leading: const Icon(FontAwesomeIcons.wallet), title: const Text("Mis Pagos (Billetera)"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverPayoutsScreen()))),
          ListTile(leading: const Icon(Icons.history), title: const Text("Historial de Viajes"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverHistoryScreen()))),
          const Divider(),
          ListTile(leading: const Icon(Icons.logout, color: AppColors.red), title: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.red)), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverAuthScreen()))),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) => Column(children: [Text(label, style: const TextStyle(color: Colors.white70)), Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]);

  // Modal de solicitud (Sin cambios en lógica, solo para mantener la feature)
  void _showNewRequestDialog(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => Container(
        padding: const EdgeInsets.all(25), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("¡Nueva Solicitud!", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.green)),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.green), onPressed: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveTripScreen()));}, child: const Text("ACEPTAR SERVICIO")))
        ])
    ));
  }
}

// ---------------------------------------------------------------------------
// 4. HISTORIAL DE VIAJES (LISTA)
// ---------------------------------------------------------------------------
class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos Dummy
    final history = [
      {'date': 'Hoy, 10:30 AM', 'route': 'Homecenter -> Norte', 'total': '45.000', 'net': '38.000', 'status': 'Finalizado'},
      {'date': 'Ayer, 4:00 PM', 'route': 'Unicentro -> Soacha', 'total': '120.000', 'net': '102.000', 'status': 'Finalizado'},
      {'date': '20 Nov', 'route': 'Cedritos -> Chapinero', 'total': '35.000', 'net': '29.500', 'status': 'Finalizado'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Viajes")),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppColors.background, child: Icon(Icons.check, color: AppColors.green)),
              title: Text("\$ ${item['net']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green)),
              subtitle: Text("${item['date']} • ${item['route']}"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              onTap: () {
                // [EDU] Navegamos al detalle "Rico"
                Navigator.push(context, MaterialPageRoute(builder: (context) => DriverTripDetailScreen(data: item)));
              },
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. DETALLE DETALLADO DEL VIAJE (NUEVO - ESTILO CLIENTE)
// ---------------------------------------------------------------------------
class DriverTripDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  const DriverTripDetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalle del Servicio")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Ganancia
            Center(
              child: Column(
                children: [
                  const Icon(Icons.monetization_on, color: AppColors.green, size: 60),
                  const SizedBox(height: 10),
                  const Text("Tu Ganancia Neta", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("\$ ${data['net']}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.blue)),
                  Text(data['date'], style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Divider(height: 40),

            // Información del Cliente
            const Text("Cliente", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text("Alejandro Martinez"),
              subtitle: const Text("Cliente Frecuente • 5.0 ★"),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.message, color: Colors.grey), SizedBox(width: 10), Icon(Icons.phone, color: Colors.grey)]),
            ),
            const SizedBox(height: 20),

            // Ruta
            const Text("Ruta Realizada", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _locationRow(Icons.circle, Colors.green, "Recogida", "Homecenter Calle 80"),
            Container(margin: const EdgeInsets.only(left: 11), height: 20, width: 2, color: Colors.grey[300]),
            _locationRow(Icons.location_on, AppColors.orange, "Entrega", "Cra 15 # 100-23"),

            const SizedBox(height: 25),

            // Carga
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text("Carga Transportada:", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("• Mueble de TV (Madera)"),
                Text("• 2 Sillas de comedor"),
              ]),
            ),

            const SizedBox(height: 25),

            // Desglose Financiero (Importante para drivers)
            const Text("Balance Financiero", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _priceRow("Valor Cobrado al Cliente", "\$ ${data['total']}"),
            _priceRow("Propina", "\$ 0"),
            const Divider(),
            _priceRow("Comisión App (15%)", "- \$ 7.000", isNegative: true),
            _priceRow("Impuestos / Retenciones", "- \$ 500", isNegative: true),
            const Divider(),
            _priceRow("Total a tu Billetera", "\$ ${data['net']}", isTotal: true),

            const SizedBox(height: 30),
            Center(child: TextButton(onPressed: (){}, child: const Text("Solicitar revisión del pago", style: TextStyle(color: AppColors.blue)))),
          ],
        ),
      ),
    );
  }

  Widget _locationRow(IconData icon, Color c, String label, String val) => Row(children: [Icon(icon, color: c, size: 20), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(val, style: const TextStyle(fontWeight: FontWeight.bold))]))]);

  Widget _priceRow(String label, String val, {bool isNegative = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(val, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isNegative ? Colors.red : (isTotal ? AppColors.green : Colors.black))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. GESTIÓN DE VEHÍCULOS (FORMULARIO COLOMBIA)
// ---------------------------------------------------------------------------
class MyVehiclesScreen extends StatelessWidget {
  const MyVehiclesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Vehículos")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _vehicleCard("Chevrolet N300", "FNK-123", true),
          const SizedBox(height: 20),
          OutlinedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddVehicleScreen())),
              icon: const Icon(Icons.add),
              label: const Text("AGREGAR NUEVO VEHÍCULO")
          )
        ],
      ),
    );
  }
  Widget _vehicleCard(String name, String plate, bool active) => Card(child: ListTile(leading: const Icon(FontAwesomeIcons.truck), title: Text(name), subtitle: Text(plate), trailing: active ? const Text("ACTIVO", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)) : null));
}

// FORMULARIO PARA AGREGAR VEHÍCULO
class AddVehicleScreen extends StatelessWidget {
  const AddVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Vehículo")),
      body: SingleChildScrollView( // [EDU] Formulario largo necesita scroll
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Datos del Vehículo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue)),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: _input("Placa (Ej: ABC-123)")),
              const SizedBox(width: 15),
              Expanded(child: _input("Modelo (Año)")),
            ]),
            const SizedBox(height: 15),
            _input("Marca (Ej: Chevrolet, JAC)"),
            const SizedBox(height: 15),
            _input("Línea / Referencia (Ej: N300, NKR)"),
            const SizedBox(height: 15),
            _input("Color"),

            const SizedBox(height: 30),
            const Text("Documentación Legal (Fotos)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.blue)),
            const Text("Sube fotos claras de los documentos originales.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),

            _uploadButton("Tarjeta de Propiedad (Ambos lados)"),
            _uploadButton("SOAT Vigente"),
            _uploadButton("Revisión Tecnomecánica"),
            _uploadButton("Tarjeta de Operación (Si aplica)"),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enviando documentos a revisión...")));
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                child: const Text("ENVIAR A REVISIÓN"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String label) => TextField(decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));

  Widget _uploadButton(String textLabel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: (){},
        icon: const Icon(Icons.camera_alt, color: AppColors.blue),
        label: Text(textLabel, style: const TextStyle(color: AppColors.text)), // [CORRECCIÓN] Usando textLabel
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(15), alignment: Alignment.centerLeft),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. PAGOS (BILLETERA & CONSIGNACIONES)
// ---------------------------------------------------------------------------
class DriverPayoutsScreen extends StatelessWidget {
  const DriverPayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Pagos")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo actual
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.blue, Color(0xFF1a3c5a)]), borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: const [
                  Text("Saldo Disponible", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 5),
                  Text("\$ 350.000", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  SizedBox(height: 15),
                  Text("Próximo pago: Martes 28 Nov", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Cuentas Bancarias
            const Text("Cuenta de Depósito", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(backgroundColor: AppColors.background, child: Icon(Icons.account_balance, color: AppColors.blue)),
              title: const Text("Bancolombia Ahorros"),
              subtitle: const Text("**** 9090"),
              trailing: TextButton(onPressed: (){}, child: const Text("Cambiar")),
            ),
            const Divider(),

            // Historial de Transferencias
            const SizedBox(height: 15),
            const Text("Historial de Consignaciones", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            _payoutItem("21 Nov", "Pago Semanal", "\$ 420.000", true),
            _payoutItem("14 Nov", "Pago Semanal", "\$ 380.000", true),
            _payoutItem("07 Nov", "Pago Semanal", "\$ 510.000", true),
          ],
        ),
      ),
    );
  }

  Widget _payoutItem(String date, String type, String amount, bool paid) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: paid ? Colors.green.shade50 : Colors.orange.shade50, child: Icon(paid ? Icons.check : Icons.access_time, color: paid ? Colors.green : Colors.orange, size: 20)),
      title: Text(type, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(date),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

// ---------------------------------------------------------------------------
// 8. PANTALLA DE VIAJE ACTIVO (WORKFLOW)
// ---------------------------------------------------------------------------
class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});
  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  int _tripStep = 0;
  final List<String> _buttonLabels = ["LLEGUÉ A RECOGIDA", "INICIAR VIAJE", "LLEGUÉ A DESTINO", "FINALIZAR SERVICIO"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.blue, title: Text(_tripStep < 2 ? "Hacia Recogida" : "Hacia Entrega", style: const TextStyle(color: Colors.white)), leading: const Icon(Icons.navigation, color: Colors.white)),
      body: Column(
        children: [
          Expanded(child: Container(color: Colors.grey[300], child: const Center(child: Text("NAVEGACIÓN GPS", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black26))))),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
            child: Column(
              children: [
                ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(child: Icon(Icons.person)), title: const Text("Alejandro M."), subtitle: const Text("Cliente • 5.0 ★"), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.phone), onPressed: (){}), IconButton(icon: const Icon(Icons.message), onPressed: (){})])),
                const Divider(),
                SizedBox(width: double.infinity, height: 55, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: _tripStep == 3 ? AppColors.green : AppColors.orange), onPressed: () {setState(() {if (_tripStep < 3) _tripStep++; else Navigator.pop(context);});}, child: Text(_buttonLabels[_tripStep])))
              ],
            ),
          )
        ],
      ),
    );
  }
}