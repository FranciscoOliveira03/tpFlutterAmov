
import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget{
  const SecondScreen({super.key});

  static const String routeName = '/second_screen';

  static const String _ipc_logo =
      'https://wayf.ipc.pt/IPCds/images/logo_ipc2.png';

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(
        title: const Text('Second screen'),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.white,
        ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'resbtn', child: Text('Segundo ecrã! ${ModalRoute.of(context)?.settings.arguments}'),
            ),
            const SizedBox(height: 16,),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Return')
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset('images/koala.jpg')
              )
            ),
            SizedBox(
                height:50,
                child: Image.network(_ipc_logo)
            ),
          ],
        )
      )
    );
  }
}