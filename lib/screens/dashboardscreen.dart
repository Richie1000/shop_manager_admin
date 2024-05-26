import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  DateTimeRange? _customDateRange;
    String _selectedOption = 'Today';
  Future<double>? _revenueFuture;
   @override
  void initState() {
    super.initState();
    _revenueFuture = getTodayTotal(); // Default to today's total
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTotalRevenueSection(),
              SizedBox(height: 20),
              _buildInventoryOverviewContent(),
              SizedBox(height: 20),
              _buildSalesPerformanceSection(),
              SizedBox(height: 20),
              _buildEmployeePerformanceSection(),
              SizedBox(height: 20),
              _buildOrdersManagementSection(),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildTotalRevenueSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Revenue', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildRevenueSortingOptions(),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _customDateRange = picked;
                        _revenueFuture = getCustomTotal(picked);
                      });
                    }
                  },
                ),
              ],
            ),
            SizedBox(height: 10),
            FutureBuilder<double>(
              future: _revenueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  double totalRevenue = snapshot.data ?? 0.0;
                  return Text(
                    'Total Revenue: \$${totalRevenue.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18.0),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueSortingOptions() {
    return DropdownButton<String>(
      value: _selectedOption,
      onChanged: (String? newValue) {
        setState(() {
          _selectedOption = newValue!;
          switch (_selectedOption) {
            case 'Today':
              _revenueFuture = getTodayTotal() ;
              break;
            case 'Last Week':
              _revenueFuture = getLastWeekTotal();
              break;
            case 'Last Month':
              _revenueFuture = getLastMonthTotal();
              break;
            case 'Last 3 Months':
              _revenueFuture = getLastThreeMonthsTotal();
              break;
            case 'Custom':
              if (_customDateRange != null) {
                _revenueFuture = getCustomTotal(_customDateRange!);
              }
              break;
          }
        });
      },
      items: <String>['Today', 'Last Week', 'Last Month', 'Last 3 Months', 'Custom']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }



  Widget _buildRevenueChart() {
    // Placeholder for the chart
    return Container(
      height: 200,
      color: Colors.grey[200],
      child: Center(child: Text('Revenue Chart Placeholder')),
    );
  }

 Widget _buildInventoryOverviewContent() {
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: FutureBuilder<Map<String, int>>(
        future: fetchEmployeeCounts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching employee counts'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No employees available'));
          } else {
            final employeeCounts = snapshot.data!;
            return ListView(
              children: [
                _buildRoleSection('Users', employeeCounts['User']!),
                _buildRoleSection('Editors', employeeCounts['Editor']!),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildRoleSection(String role, int count) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          role,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '$count',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}


  Widget _buildSalesPerformanceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildSalesPerformanceContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesPerformanceContent() {
    // Placeholder for sales performance content
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Center(child: AspectRatio(aspectRatio: 2.0, 
      child:LineChart(LineChartData(lineBarsData: [
        LineChartBarData(
          show: true,
          spots: const[
            FlSpot(0, 0),
            FlSpot(1, 0),
             FlSpot(2, 4),
              FlSpot(3, 1),
               FlSpot(4, 4),
                FlSpot(5, 5),
               FlSpot(5, 2),

          ],
          gradient: const LinearGradient(colors: [
            Colors.cyan,
            Colors.red,
            Colors.purpleAccent
          ],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter
          ),
          barWidth: 4,
          isCurved: true
        )

      ])
      ) ,)
      
      ,
      ),
    );
  }

  Widget _buildEmployeePerformanceSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildEmployeePerformanceContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeePerformanceContent() {
    // Placeholder for employee performance content
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Center(child: Text('Employee Performance Placeholder')),
    );
  }

  Widget _buildOrdersManagementSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Orders Management', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildOrdersManagementContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersManagementContent() {
    // Placeholder for orders management content
    return Container(
      height: 150,
      color: Colors.grey[200],
      child: Center(child: Text('Orders Management Placeholder')),
    );
  }

  Future<String> _getFormattedDate() async {
    // Placeholder function for getting formatted date
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

 


   Future<Map<String, int>> fetchEmployeeCounts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('employees').get();

    Map<String, int> employeeCounts = {
      'User': 0,
      'Editor': 0
    };

    querySnapshot.docs.forEach((doc) {
      String role = doc['role'];
      if (role == 'User' || role == 'Editor') {
        employeeCounts[role] = (employeeCounts[role] ?? 0) + 1;
      }
    });

    return employeeCounts;
  }

Future<double> calculateTodayRevenue() async {
  double totalRevenue = 0.0;

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('statistics')
      .where('date', isEqualTo: DateFormat('dd/MM/yyyy').format(DateTime.now()))
      .get();

  for (var doc in snapshot.docs) {
    totalRevenue += doc['total'];
  }

  return totalRevenue;
}

Future<double> calculateTotalRevenue(DateTime startDate, DateTime endDate) async {
  double totalRevenue = 0.0;

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('statistics')
      .where('date', isGreaterThanOrEqualTo: DateFormat('dd/MM/yyyy').format(startDate))
      .where('date', isLessThanOrEqualTo: DateFormat('dd/MM/yyyy').format(endDate))
      .get();

  for (var doc in snapshot.docs) {
    totalRevenue += doc['total'];
  }

  return totalRevenue;
}

Future<double> getTodayTotal() async {
  
  return await calculateTodayRevenue() ;
}

Future<double> getLastWeekTotal() async {
  DateTime now = DateTime.now();
  DateTime lastWeek = now.subtract(Duration(days: 7));
  return await calculateTotalRevenue(lastWeek, now);
}

Future<double> getLastMonthTotal() async {
  DateTime now = DateTime.now();
  DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);
  return await calculateTotalRevenue(lastMonth, now);
}

Future<double> getLastThreeMonthsTotal() async {
  DateTime now = DateTime.now();
  DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
  return await calculateTotalRevenue(threeMonthsAgo, now);
}

Future<double> getCustomTotal(DateTimeRange dateRange) async {
  return await calculateTotalRevenue(dateRange.start, dateRange.end);
}



// Widget _buildSalesPerformanceContent() {
//   return Container(
//     height: 300,
//     color: Colors.grey[200],
//     child: Center(
//       child: AspectRatio(
//         aspectRatio: 2.0,
//         child: FutureBuilder<Map<int, double>>(
//           future: getMonthlyRevenue(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator();
//             } else if (snapshot.hasError) {
//               return Text('Error fetching monthly revenue');
//             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return Text('No data available');
//             } else {
//               final monthlyRevenue = snapshot.data!;
//               final spots = monthlyRevenue.entries
//                   .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
//                   .toList();

//               return LineChart(
//                 LineChartData(
//                   lineBarsData: [
//                     LineChartBarData(
//                       show: true,
//                       spots: spots,
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.cyan,
//                           Colors.red,
//                           Colors.purpleAccent,
//                         ],
//                         begin: Alignment.bottomCenter,
//                         end: Alignment.topCenter,
//                       ),
//                       barWidth: 4,
//                       isCurved: true,
//                     ),
//                   ],
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(showTitles: true),
//                     ),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           switch (value.toInt()) {
//                             case 1:
//                               return Text('Jan');
//                             case 2:
//                               return Text('Feb');
//                             case 3:
//                               return Text('Mar');
//                             case 4:
//                               return Text('Apr');
//                             case 5:
//                               return Text('May');
//                             case 6:
//                               return Text('Jun');
//                             case 7:
//                               return Text('Jul');
//                             case 8:
//                               return Text('Aug');
//                             case 9:
//                               return Text('Sep');
//                             case 10:
//                               return Text('Oct');
//                             case 11:
//                               return Text('Nov');
//                             case 12:
//                               return Text('Dec');
//                             default:
//                               return Text('');
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(
//                     show: true,
//                     border: Border.all(color: Colors.black),
//                   ),
//                 ),
//               );
//             }
//           },
//         ),
//       ),
//     ),
//   );
// }


// Future<Map<int, double>> getMonthlyRevenue() async {
//   Map<int, double> monthlyRevenue = {};
//   DateTime now = DateTime.now();

//   for (int i = 0; i < 12; i++) {
//     DateTime monthStart = DateTime(now.year, now.month - i, 1);
//     DateTime monthEnd = DateTime(now.year, now.month - i + 1, 0);

//     double monthTotal = await calculateTotalRevenue(monthStart, monthEnd);
//     monthlyRevenue[now.month - i] = monthTotal;
//   }

//   return monthlyRevenue;
// }