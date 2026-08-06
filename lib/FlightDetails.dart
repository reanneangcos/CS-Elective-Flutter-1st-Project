import 'package:cs_elective_2/components/Info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FlightDetails extends StatelessWidget {
  const FlightDetails({super.key});

  @override
  Widget build(BuildContext context) {
    String dateNow = DateFormat('EEE, d MMM').format(DateTime.now());
    return Scaffold(
      backgroundColor: Colors.white,
      //  Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF419A94),
        leading: IconButton(
          onPressed: null,
          icon: Icon(Icons.chevron_left, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: null,
            child: Text('Skip', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              color: Color(0xFF419A94),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(120),
                bottomRight: Radius.circular(120),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // flight info
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          'Departure',
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'JFK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('21:30', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 5),
                        Text(dateNow, style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Icon(Icons.flight_takeoff, color: Colors.white, size: 48),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Arrival', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 5),
                        Text(
                          'LAX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text('05:45', style: TextStyle(color: Colors.white)),
                        SizedBox(height: 5),
                        Text(dateNow, style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                height: MediaQuery.of(context).size.height * 0.6,
                margin: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.flight_takeoff_outlined,
                        color: Color(0xFF419A94),
                        size: 70,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passenger',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF419A94),
                            ),
                          ),
                          Text(
                            'JOHN WICK'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF419A94),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Color(0xFF419A94).withValues(alpha: 150),
                      thickness: 0.5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InfoText(
                            title: 'Ticket Number',
                            description: 'TIX1234567890',
                          ),
                        ),
                        Expanded(
                          child: InfoText(
                            title: 'Seat Number',
                            description: '12A',
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: InfoText(
                            title: 'Class',
                            description: 'First Class',
                          ),
                        ),
                        Expanded(
                          child: InfoText(title: 'Gate', description: '31'),
                        ),
                        Expanded(
                          child: InfoText(
                            title: 'Baggage',
                            description: '2x15 kg',
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      color: Color(0xFF419A94).withValues(alpha: 150),
                      thickness: 0.5,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Booking Pass'.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF419A94),
                            ),
                          ),
                          SizedBox(height: 5),
                          Image.asset('assets/bcode.png', width: 200),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
