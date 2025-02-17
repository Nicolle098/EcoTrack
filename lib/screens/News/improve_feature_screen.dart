import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ImproveFeatureScreen extends StatefulWidget {
  final double carbonFootprint;

  const ImproveFeatureScreen({super.key, required this.carbonFootprint});

  @override
  _ImproveFeatureScreenState createState() => _ImproveFeatureScreenState();
}

class _ImproveFeatureScreenState extends State<ImproveFeatureScreen> {
  double _totalEmissions = 0.0;
  List<Map<String, dynamic>> _articles = [];
  String _dailyChallenge = '';

  @override
  void initState() {
    super.initState();
    _fetchArticles();
    _setDailyChallenge();
  }

  Future<void> _fetchArticles() async {
    // Static articles with URLs
    setState(() {
      _articles = [
        {
          "title": "The Impact of Global Warming",
          "content": "Global warming is causing significant changes to our planet's climate...",
          "url": "https://www.noaa.gov/education/resource-collections/climate/climate-change-impacts"
        },
        {
          "title": "How to Reduce Your Carbon Footprint",
          "content": "Reducing your carbon footprint can be achieved by making small changes in your daily life...",
          "url": "https://youth.europa.eu/get-involved/sustainable-development/how-reduce-my-carbon-footprint_en"
        },
        {
          "title": "The Benefits of Renewable Energy",
          "content": "Renewable energy sources such as solar and wind power are becoming increasingly popular...",
          "url": "https://www.un.org/en/climatechange/raising-ambition/renewable-energy"
        },
        {
          "title": "The Importance of Recycling",
          "content": "Recycling helps to reduce waste and conserve natural resources...",
          "url": "https://evreka.co/blog/importance-of-recycling-in-sustainable-development-goals/"
        },
        {
          "title": "How Climate Change Affects Weather Patterns",
          "content": "Climate change is leading to more extreme weather patterns and events...",
          "url": "https://science.nasa.gov/climate-change/extreme-weather/"
        },
        {
          "title": "The Benefits of Urban Green Spaces",
          "content": "Urban green spaces provide numerous benefits for both people and the environment...",
          "url": "https://www.nhm.ac.uk/discover/why-we-need-green-spaces-in-cities.html"
        },
        {
          "title": "The Importance of Biodiversity Conservation",
          "content": "Biodiversity conservation is essential for maintaining healthy ecosystems...",
          "url": "https://plantgrowsave.org/the-importance-of-biodiversity-conservation/"
        },
        {
          "title": "How to Start a Community Garden",
          "content": "Community gardens can provide fresh produce and strengthen community bonds...",
          "url": "https://www.rhs.org.uk/get-involved/community-gardening/resources/community-garden"
        }
      ];
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  int _calculateTreesToPlant(double footprint) {
    return (footprint / 20).ceil();
  }

  void _setDailyChallenge() {
    List<String> challenges = [
      "Try to go plastic-free for the whole day! Bring a reusable bag & bottle. ♻️",
      "Walk or bike to work instead of driving. 🚶‍♂️🚴‍♀️",
      "Reduce your meat consumption for the day. 🌱",
      "Unplug electronics when not in use to save energy. 🔌",
      "Take shorter showers to conserve water. 🚿",
      "Use a reusable coffee cup instead of a disposable one. ☕",
      "Recycle paper, plastic, and glass products. ♻️",
      "Plant a tree or some plants in your garden. 🌳",
      "Avoid using single-use plastics like straws and cutlery. 🍴",
      "Support local farmers by buying locally grown produce. 🥕"
    ];

    setState(() {
      _dailyChallenge = challenges[Random().nextInt(challenges.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Improve Your Impact"),
        backgroundColor: Color.fromARGB(255, 237, 240, 238), // Set the AppBar color here
      ),
      backgroundColor: Color.fromARGB(255, 195, 207, 197), // Set the background color of the screen here
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFootprintCard(),
            _buildCard(
              title: "🌎 Offset & Eco-Friendly Actions",
              content: "• Support tree-planting programs\n• Donate to carbon offset projects\n• Use renewable energy sources ⚡",
            ),
            _buildCard(
              title: "💡 Daily Eco-Friendly Challenge",
              content: _dailyChallenge,
            ),
            _buildCard(
              title: "📊 Monthly Carbon Stats",
              content: "Your carbon footprint has ${_totalEmissions < 50 ? "decreased" : "increased"} compared to last month.",
            ),
            const SizedBox(height: 20),
            _buildArticleSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFootprintCard() {
    return Card(
      color: Color.fromARGB(255, 237, 240, 238), // Set the background color here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("🌱 Based on your footprint, you should plant ${_calculateTreesToPlant(widget.carbonFootprint)} trees."),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required String content, VoidCallback? onTap}) {
    return Card(
      color: Color.fromARGB(255, 237, 240, 238), // Set the background color here
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(content),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📖 Articles on Global Warming",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._articles.map((article) => _buildCard(
              title: article["title"] ?? "Article",
              content: article["content"] ?? "No content available.",
              onTap: () => _launchURL(article["url"] ?? ""),
            )),
      ],
    );
  }
}