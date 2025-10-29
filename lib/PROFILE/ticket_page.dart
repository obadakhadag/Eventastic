import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ticket_widget/ticket_widget.dart';
class TicketPage extends StatelessWidget {
  const TicketPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withAlpha(50),
      body: Stack(
       // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/backimageticket.jpg',height: 300,),
          Padding(
            padding: const EdgeInsets.only(top: 200,right: 60,left: 60),
            child: TicketWidget(color: Colors.white24,
              width: 250,
                height: 450,
                isCornerRounded: true,
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                        right: 20,
                        child: ClipPath(
                          clipper: CustomClipDesign(),
                          child: Container(
                            height: 50,
                            width: 28,
                           alignment:Alignment.topCenter ,
                            color: Color.fromRGBO(159, 145, 204, 1),
                            child: Center(
                              child: Text('Oct \n 15',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12
                                ),
                              ),
                            ),
                                              ),
                        )),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [SizedBox(
                          height: 15,
                        ),
                                      CircleAvatar(
                                        backgroundColor: Color.fromRGBO(92, 75, 153, 1),
                                        radius: 60,
                                        child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 55,
                                          ),
                                      ),
                          SizedBox(
                            height: 15,
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ticketDetails('Time','8.30 pm'),
                                  ticketDetails('Price', '\$145')
                                ],
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ticketDetails('Section','13'),
                                  ticketDetails('type', 'party')
                                ],
                              ),SizedBox(
                                height: 25,
                              ),
                              Container(
                                height: 30,
                                width: 200,
                                color: Colors.black,
                                child:
                                Image.asset('assets/images/barcode-600nw-556142608.webp',
                                fit: BoxFit.none,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
            ),
          ),


        ],
      ),
    );
  }
Widget ticketDetails(String title,String details) => Column(
  children: [
    Text(
      title,
      style: TextStyle(
        color: Color.fromRGBO(61, 36, 108, 1),
        fontWeight: FontWeight.w700,
        fontSize: 20
      ),
    ),
    SizedBox(
      height: 10,
    ),
    Container(
      height: 20,
      width: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        details,
        style: TextStyle(
          fontSize: 11,
          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w800
        ),
      ),
    )
  ],
);
  
}
class CustomClipDesign extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
   Path path= Path();
   double h=size.height;
   double w=size.width;
   path.lineTo(0, h-15);
   path.lineTo(w/4, h);
   path.lineTo(w/2, h-15);
   path.lineTo(w/1.2, h);
   path.lineTo(w, h-15);
   path.lineTo(w, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}
