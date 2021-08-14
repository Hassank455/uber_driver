import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uber_driver_app/Assistants/assistantMethode.dart';

class CollectFareDialog extends StatelessWidget {

   String? paymentMethod;
   int? fareAmount;

  CollectFareDialog({this.paymentMethod,this.fareAmount});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(5.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 22.0),
            Text('Trip fare'),
            SizedBox(height: 22.0),
            Divider(),
            SizedBox(height: 16.0),
            Text(
              '\$$fareAmount',
              style: TextStyle(fontSize: 55.0, fontFamily: "Brand Bold"),
            ),
            SizedBox(height: 16.0),
            SizedBox(height: 16.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'This is thr total trip amount, it is has been charged to the rider',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 30.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: RaisedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Navigator.pop(context);

                  AssistantMethod.enableHomeTabLiveLocationUpdates();
                },
                color: Colors.deepPurpleAccent,
                child: Padding(
                  padding: EdgeInsets.all(17.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Collect Cash",
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      Icon(Icons.attach_money, color: Colors.white, size: 26.0),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 30.0),

          ],
        ),
      ),
    );
  }
}
