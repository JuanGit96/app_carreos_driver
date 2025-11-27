// ===========================================================================
// APP CONDUCTOR (DRIVER) - VERSIÓN MAESTRA FINAL
// ===========================================================================
//
// OBJETIVO DIDÁCTICO:
// Esta app se diferencia de la del cliente en que prioriza la eficiencia.
// Botones grandes, textos claros, menos "adorno" y más "acción".
//
// Estructura:
// 1. Auth (Login/Registro) -> 2. Dashboard (Mapa/Estado) -> 3. Gestión (Vehículos/Dinero)

import 'package:flutter/material.dart'; // [EDU] Librería base UI
import 'package:google_fonts/google_fonts.dart'; // [EDU] Tipografías
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // [EDU] Iconos
import 'package:intl/intl.dart'; // [EDU] Formato moneda
import 'dart:async'; // [EDU] Para temporizadores

// ---------------------------------------------------------------------------
// 1. CONFIGURACIÓN VISUAL (BRANDING)
// ---------------------------------------------------------------------------
class AppColors {
  static const Color orange = Color(0xFFFF6B35);
  static const Color blue = Color(0xFF0F2537);   // Color principal del Driver (Seriedad)
  static const Color background = Color(0xFFF3F4F6); // Gris suave para descansar la vista
  static const Color green = Color(0xFF10B981);  // Dinero y Estado Online
  static const Color red = Color(0xFFEF4444);    // Offline / Cancelar
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
        // [EDU] Usamos 'Inter' porque es una fuente muy legible para pantallas en movimiento
        textTheme: GoogleFonts.interTextTheme(),
        primaryColor: AppColors.blue,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
        // [EDU] Definimos el estilo de los Inputs una sola vez aquí
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
        // [EDU] Botones azules sólidos por defecto
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
      home: const DriverAuthScreen(), // Iniciamos en el Login
    );
  }
}

// ---------------------------------------------------------------------------
// 2. AUTENTICACIÓN (LOGIN / REGISTRO)
// ---------------------------------------------------------------------------
class DriverAuthScreen extends StatefulWidget {
  const DriverAuthScreen({super.key});
  @override
  State<DriverAuthScreen> createState() => _DriverAuthScreenState();
}

class _DriverAuthScreenState extends State<DriverAuthScreen> {
  bool _isLogin = true; // [EDU] Controla si mostramos formulario de Login o Registro

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blue, // Fondo oscuro corporativo
      body: SafeArea(
        child: SingleChildScrollView( // [EDU] Permite scroll si el teclado tapa la pantalla
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              // Logo
              const Icon(FontAwesomeIcons.truckFront, size: 60, color: AppColors.green),
              const SizedBox(height: 15),
              Text("AppCarreos\nSocios", textAlign: TextAlign.center, style: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 40),

              // Selector de Pestaña
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

              // CAMPO FOTO (Solo en Registro)
              if (!_isLogin) ...[
                GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subir foto de perfil..."))),
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, size: 50, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      )
                    ],
                  ),
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

              // Botón Principal
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.green), // Verde para acción positiva
                  onPressed: () {
                    // [EDU] pushReplacement destruye el login para no volver atrás con el botón físico
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverDashboard()));
                  },
                  child: Text(_isLogin ? "INICIAR TURNO" : "CREAR CUENTA"),
                ),
              ),

              const SizedBox(height: 30),
              const Text("O conecta con", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),

              // Redes Sociales
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(FontAwesomeIcons.google, Colors.white, Colors.red),
                  const SizedBox(width: 20),
                  _socialButton(FontAwesomeIcons.apple, Colors.white, Colors.black),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // [EDU] Widgets auxiliares para limpiar el código principal
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
      decoration: InputDecoration(prefixIcon: Icon(icon, color: Colors.grey), hintText: hint, hintStyle: TextStyle(color: Colors.grey.shade400)),
    );
  }

  Widget _socialButton(IconData icon, Color bg, Color iconColor) {
    return CircleAvatar(radius: 25, backgroundColor: bg, child: Icon(icon, color: iconColor, size: 24));
  }
}

// ---------------------------------------------------------------------------
// 3. DASHBOARD PRINCIPAL
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
      // [EDU] Drawer: Menú lateral (Hamburguesa). Es estándar en apps de conductores para guardar opciones secundarias.
      drawer: Drawer(
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
            ListTile(leading: const Icon(FontAwesomeIcons.wallet), title: const Text("Billetera & Cuentas"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PayoutMethodsScreen()))),
            ListTile(leading: const Icon(Icons.history), title: const Text("Historial de Viajes"), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DriverHistoryScreen()))),
            const Divider(),
            ListTile(leading: const Icon(Icons.logout, color: AppColors.red), title: const Text("Cerrar Sesión", style: TextStyle(color: AppColors.red)), onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DriverAuthScreen()))),
          ],
        ),
      ),
      body: Column(
        children: [
          // HEADER DE ESTADO (Grande y claro)
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.blue,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() => _isOnline = !_isOnline);
                    // Simulación: Si se conecta, entra un pedido en 3 segundos
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
                // Estadísticas Rápidas
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

          // CUERPO (Mapa o Estado)
          Expanded(
            child: _isOnline
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.orange),
                  const SizedBox(height: 20),
                  Text("Buscando servicios cercanos...", style: GoogleFonts.inter(color: Colors.grey)),
                ],
              ),
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.coffee, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Estás desconectado"),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // MODAL DE NUEVA SOLICITUD (El momento de la verdad para un driver)
  void _showNewRequestDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Nuevo Servicio", style: TextStyle(fontSize: 18, color: Colors.grey)), Text("\$45.000", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.green))]),
            const Divider(height: 30),
            _routeRow(Icons.circle, Colors.green, "Recogida (2.5km)", "Homecenter Calle 80"),
            Container(margin: const EdgeInsets.only(left: 11), height: 20, width: 2, color: Colors.grey[300]),
            _routeRow(Icons.location_on, AppColors.orange, "Entrega", "Cra 15 # 100-23"),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
              child: Row(children: const [Icon(FontAwesomeIcons.box, size: 16), SizedBox(width: 10), Text("Carga: Mueble TV + 2 Sillas", style: TextStyle(fontWeight: FontWeight.bold))]),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                onPressed: () {
                  Navigator.pop(context); // Cerrar modal
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ActiveTripScreen()));
                },
                child: const Text("ACEPTAR SERVICIO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _routeRow(IconData icon, Color color, String title, String sub) => Row(children: [Icon(icon, color: color), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)), Text(sub, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])]);
}

// ---------------------------------------------------------------------------
// 4. GESTIÓN DE VEHÍCULOS (FLOTA)
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
          // Vehículo Activo
          _vehicleCard("Chevrolet N300", "FNK-123", "Van Pequeña", true),
          const SizedBox(height: 15),
          // Otros vehículos
          _vehicleCard("JAC 1035", "SXV-908", "Camión Estacas", false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Formulario para agregar vehículo..."))),
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _vehicleCard(String model, String plate, String type, bool isActive) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: isActive ? Border.all(color: AppColors.green, width: 2) : null,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.truck, color: isActive ? AppColors.green : Colors.grey, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("$plate • $type", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          if (isActive)
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: const Text("EN USO", style: TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 10)))
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 5. MÉTODOS DE PAGO (DONDE RECIBE EL DINERO)
// ---------------------------------------------------------------------------
class PayoutMethodsScreen extends StatelessWidget {
  const PayoutMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Billetera")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Cuentas Vinculadas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _accountCard("Nequi", "300 123 4567", true),
          _accountCard("Bancolombia Ahorros", "**** 9090", false),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: (){}, icon: const Icon(Icons.add), label: const Text("Agregar Cuenta Bancaria"))
        ],
      ),
    );
  }

  Widget _accountCard(String bank, String number, bool isPrimary) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: Colors.grey.shade200)),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: AppColors.background, child: Icon(Icons.account_balance, color: AppColors.blue)),
        title: Text(bank, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(number),
        trailing: isPrimary ? const Icon(Icons.check_circle, color: AppColors.green) : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. HISTORIAL DE VIAJES (GANANCIAS)
// ---------------------------------------------------------------------------
class DriverHistoryScreen extends StatelessWidget {
  const DriverHistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Viajes")),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          // Detalle Financiero es clave para el driver
          _tripHistoryCard("Hoy, 10:30 AM", "Homecenter -> Norte", "45.000", "38.000"),
          _tripHistoryCard("Ayer, 4:00 PM", "Unicentro -> Soacha", "120.000", "102.000"),
          _tripHistoryCard("20 Nov, 9:15 AM", "Cedritos -> Chapinero", "35.000", "29.500"),
        ],
      ),
    );
  }

  Widget _tripHistoryCard(String date, String route, String total, String net) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: ExpansionTile(
        leading: const Icon(FontAwesomeIcons.boxOpen, color: AppColors.blue),
        title: Text("\$ $net", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green, fontSize: 18)),
        subtitle: Text(date),
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Ruta"), Text(route)]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Valor Total"), Text("\$ $total")]),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Comisión App"), const Text("- 15%", style: TextStyle(color: AppColors.red))]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Tu Ganancia", style: TextStyle(fontWeight: FontWeight.bold)), Text("\$ $net", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green))]),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. PANTALLA DE VIAJE ACTIVO (WORKFLOW)
// ---------------------------------------------------------------------------
class ActiveTripScreen extends StatefulWidget {
  const ActiveTripScreen({super.key});
  @override
  State<ActiveTripScreen> createState() => _ActiveTripScreenState();
}

class _ActiveTripScreenState extends State<ActiveTripScreen> {
  int _tripStep = 0; // 0:Yendo, 1:Cargando, 2:Viajando, 3:Descargando
  final List<String> _buttonLabels = ["LLEGUÉ A RECOGIDA", "INICIAR VIAJE", "LLEGUÉ A DESTINO", "FINALIZAR SERVICIO"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        title: Text(_tripStep < 2 ? "Hacia Recogida" : "Hacia Entrega", style: const TextStyle(color: Colors.white)),
        leading: const Icon(Icons.navigation, color: Colors.white),
      ),
      body: Column(
        children: [
          // Navegación GPS Simulada
          Expanded(
            child: Container(
              color: Colors.grey[300],
              child: Stack(
                children: [
                  const Center(child: Text("MAPA DE NAVEGACIÓN", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black26))),
                  Positioned(
                    top: 20, left: 20, right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: AppColors.blue, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: const [
                          Icon(Icons.turn_right, color: Colors.white, size: 40),
                          SizedBox(width: 15),
                          Expanded(child: Text("Gira a la derecha en 200m", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          // Panel de Control
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: const Text("Alejandro M.", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Cliente • 5.0 ★"),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.phone), onPressed: (){}), IconButton(icon: const Icon(Icons.message), onPressed: (){})]),
                ),
                const Divider(),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: _tripStep == 3 ? AppColors.green : AppColors.orange),
                    onPressed: () {
                      setState(() {
                        if (_tripStep < 3) _tripStep++; else Navigator.pop(context); // Fin del viaje
                      });
                    },
                    child: Text(_buttonLabels[_tripStep], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}