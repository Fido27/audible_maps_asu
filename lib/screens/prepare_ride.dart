import 'package:audible_maps_asu/widgets/search_listview.dart';
import 'package:flutter/material.dart';

import '../widgets/endpoints_card.dart';
import '../widgets/review_ride_fa_button.dart';

class PrepareRide extends StatefulWidget {
  const PrepareRide({Key? key}) : super(key: key);

  @override
  State<PrepareRide> createState() => _PrepareRideState();

  // Declare a static function to reference setters from children
  static _PrepareRideState? of(BuildContext context) =>
      context.findAncestorStateOfType<_PrepareRideState>();
}

class _PrepareRideState extends State<PrepareRide> {
  bool isLoading = false;
  bool isEmptyResponse = true;
  bool hasResponded = false;
  bool isResponseForDestination = false;

  String noRequest = 'Please enter an address, a place or a location to search';
  String noResponse = 'No results found for the search';

  List responses = [];
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();

  // Define setters to be used by children widgets
  set responsesState(List responses) {
    setState(() {
      this.responses = responses;
      hasResponded = true;
      isEmptyResponse = responses.isEmpty;
    });
    Future.delayed(
      const Duration(milliseconds: 500),
      () => setState(() {
        isLoading = false;
      }),
    );
  }

  set isLoadingState(bool isLoading) {
    setState(() {
      this.isLoading = isLoading;
    });
  }

  set isResponseForDestinationState(bool isResponseForDestination) {
    setState(() {
      this.isResponseForDestination = isResponseForDestination;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back)),
        title: const Text('Audible Maps ASU'),
        // actions: const [
        //   CircleAvatar(backgroundImage: AssetImage('assets/image/person.jpg')),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView( 
          physics: const ScrollPhysics(),
          child: Column(
            children: [
              endpointsCard(sourceController, destinationController),
              // Add a Linear Progress Indicator to show loading
              isLoading? const LinearProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),):Container(),
              // Show an appropriate message if no address has been entered, or no results are found
              isEmptyResponse? Padding(padding: const EdgeInsets.only(top: 20), child: Center(child: Text(hasResponded? noResponse: noRequest))): Container(),
              // Show a list view of results to select one from
              searchListView(responses, isResponseForDestination, destinationController, sourceController)
            ],
          ),
        ),
      ),
      floatingActionButton: reviewRideFaButton(context),
    );
  }
}
