import 'dart:convert';

import 'package:audible_maps_asu/main.dart';
import 'package:flutter/material.dart';

Widget searchListView(
    List responses,
    bool isResponseForDestination,
    TextEditingController destinationController,
    TextEditingController sourceController) {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: responses.length,
    itemBuilder: (BuildContext context, int index) {
      return Column(
        children: [
          ListTile(
            onTap: () {
              String text = responses[index]["place"];
              if (isResponseForDestination) {
                destinationController.text = text;
                sharedPreferences.setString(
                    "destination", jsonEncode(responses[index]));
              } else {
                sourceController.text = text;
                sharedPreferences.setString(
                    "source", jsonEncode(responses[index]));
              }
              FocusManager.instance.primaryFocus?.unfocus();
            },
            leading: const SizedBox(
              height: double.infinity,
              child: CircleAvatar(child: Icon(Icons.map)),
            ),
            title: Text(responses[index]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(responses[index]['address'],
                overflow: TextOverflow.ellipsis),
          ),
          const Divider(),
        ],
      );
    },
  );
}
