import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      "question": "How do I log my transport activities?",
      "answer": "Go to the Log Transport screen, select your transport mode, and enter the distance traveled. The app will calculate and log your CO₂ emissions."
    },
    {
      "question": "How do I change my username?",
      "answer": "Go to the Account screen, enter your new username in the provided field, and click the 'Change Username' button."
    },
    {
      "question": "How do I contact support?",
      "answer": "Go to the Help screen and click on 'Contact Support' to send an email to our support team."
    },
    {
      "question": "What are the emission factors used for calculations?",
      "answer": "The app uses the following emission factors:\nElectricity: 0.2254 kg CO₂/kWh\nNatural Gas: 0.490 kg CO₂/kWh\nHeating Oil: 2.52 kg CO₂/liter\nCoal: 3.96 kg CO₂/kg\nLPG: 1.55 kg CO₂/liter\nWood: 0.43 kg CO₂/kg"
    },
    {
      "question": "How do I delete my account?",
      "answer": "Go to the Account screen, click on 'Delete Account,' and confirm your decision. This action cannot be undone."
    },
    {
      "question": "Can I log multiple transport activities in a day?",
      "answer": "Yes, you can log multiple transport activities throughout the day. Each entry will be recorded separately, and the total emissions for the day will be calculated."
    },
    {
      "question": "How is my step count tracked?",
      "answer": "The app syncs with your device’s health data to track your daily step count."
    },
    {
      "question": "Can I export my environmental impact data?",
      "answer": "Currently, the app does not support exporting data, but future updates may include this feature."
    },
    {
      "question": "Does the app support public transport emissions tracking?",
      "answer": "Yes, you can log bus, train, or other public transport usage by entering the distance traveled."
    },
    {
      "question": "How accurate are the CO₂ calculations?",
      "answer": "The app uses internationally recognized emission factors and calculations to provide accurate estimates."
    },
    {
      "question": "How can I improve my carbon footprint?",
      "answer": "The app provides insights into your carbon emissions and suggests ways to reduce them, such as using public transport, switching to renewable energy, or walking instead of driving."
    },
    {
      "question": "What is global warming?",
      "answer": "Global warming refers to the long-term increase in Earth's average temperature due to human activities, primarily the burning of fossil fuels, which releases greenhouse gases."
    },
    {
      "question": "What are the main causes of global warming?",
      "answer": "Burning fossil fuels (coal, oil, natural gas)\nDeforestation\nIndustrial processes\nAgriculture and livestock farming\nWaste management and landfills"
    },
    {
      "question": "What are the effects of global warming?",
      "answer": "Rising sea levels\nMore extreme weather events (heatwaves, hurricanes, floods)\nMelting glaciers and ice caps\nOcean acidification\nLoss of biodiversity"
    },
    {
      "question": "What is the greenhouse effect?",
      "answer": "The greenhouse effect is a natural process where certain gases trap heat in Earth's atmosphere, keeping the planet warm enough to sustain life. However, human activities have increased these gases, intensifying the effect and causing global warming."
    },
    {
      "question": "What are greenhouse gases?",
      "answer": "Greenhouse gases include:\nCarbon dioxide (CO₂)\nMethane (CH₄)\nNitrous oxide (N₂O)\nFluorinated gases"
    },
    {
      "question": "How does transportation contribute to global warming?",
      "answer": "Transportation accounts for about 25% of global CO₂ emissions, primarily from cars, trucks, airplanes, and ships that burn fossil fuels."
    },
    {
      "question": "What is carbon neutrality?",
      "answer": "Carbon neutrality means balancing emitted CO₂ with carbon removal or offsetting activities, such as tree planting or investing in renewable energy projects."
    },
    {
      "question": "How does deforestation contribute to climate change?",
      "answer": "Trees absorb CO₂, so deforestation reduces the Earth's ability to remove carbon from the atmosphere, increasing greenhouse gas levels."
    },
    {
      "question": "What is a carbon footprint?",
      "answer": "A carbon footprint measures the total amount of greenhouse gases (GHGs) produced directly or indirectly by an individual, organization, or activity."
    },
    {
      "question": "How can I reduce my carbon footprint?",
      "answer": "Use energy-efficient appliances\nDrive less and use public transport\nEat a plant-based diet or reduce meat consumption\nUse renewable energy sources\nReduce waste and recycle"
    },
    {
      "question": "What is the average carbon footprint per person?",
      "answer": "The global average is about 4.5 metric tons of CO₂ per year, but it varies widely by country."
    },
    {
      "question": "How do different energy sources compare in emissions?",
      "answer": "Coal: 3.96 kg CO₂/kg\nOil: 2.52 kg CO₂/liter\nNatural Gas: 0.490 kg CO₂/kWh\nSolar and Wind: Virtually zero emissions"
    },
    {
      "question": "Why is methane a concern for climate change?",
      "answer": "Methane is about 25 times more effective at trapping heat than CO₂ over a 100-year period."
    },
    {
      "question": "What is sustainable living?",
      "answer": "Sustainable living involves making choices that reduce environmental impact, such as using less energy, consuming responsibly, and minimizing waste."
    },
    {
      "question": "How can I make my home more energy efficient?",
      "answer": "Switch to LED bulbs\nUse smart thermostats\nInstall solar panels\nInsulate your home properly"
    },
    {
      "question": "How do plant-based diets help the environment?",
      "answer": "Reducing meat consumption lowers methane emissions from livestock and decreases deforestation for grazing land."
    },
    {
      "question": "Why is plastic waste a problem?",
      "answer": "Plastic takes hundreds of years to decompose, polluting oceans and harming wildlife."
    },
    {
      "question": "What is fast fashion, and why is it harmful?",
      "answer": "Fast fashion involves producing cheap clothing quickly, leading to environmental damage due to excessive water use, pollution, and waste."
    },
    {
      "question": "What are carbon offsets?",
      "answer": "Carbon offsets are investments in projects that reduce CO₂ emissions, such as reforestation or renewable energy."
    },
    {
      "question": "What are some examples of renewable energy sources?",
      "answer": "Solar power\nWind energy\nHydropower\nGeothermal energy"
    },
    {
      "question": "What is the Air Quality Index (AQI)?",
      "answer": "The AQI measures air pollution levels based on factors like particulate matter (PM2.5, PM10), ozone, and nitrogen dioxide."
    },
    {
      "question": "How does air pollution affect health?",
      "answer": "Long-term exposure can cause respiratory diseases, heart problems, and reduced lung function."
    },
    {
      "question": "What are the main sources of air pollution?",
      "answer": "Vehicle emissions\nIndustrial processes\nBurning fossil fuels\nAgricultural activities"
    },
    {
      "question": "How can I improve indoor air quality?",
      "answer": "Use air purifiers\nKeep windows open for ventilation\nAvoid using toxic cleaning products\nReduce indoor smoking"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(192, 214, 228, 1000),
        title: const Text('FAQs'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color.fromARGB(255, 237, 240, 238),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    faqs[index]['question']!,
                    style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    faqs[index]['answer']!,
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}