// Produce Data Model - Complete catalog of Indian agricultural products
//
// Based on Indian market research:
// - Vegetables: sold by kg, quintal
// - Fruits: sold by kg, dozen (bananas), per piece (coconut, watermelon)
// - Leafy greens: sold by bunch, kg
// - Grains: sold by kg, quintal, bag (50kg)
// - Flowers: sold by bunch, kg

/// Produce category types
enum ProduceCategory {
  vegetables,
  fruits,
  leafyGreens,
  grains,
  flowers,
  other,
}

/// Measurement unit with conversion factor to kg
class ProduceUnit {
  final String id;
  final String name;
  final String nameKn; // Kannada
  final String symbol;
  final double toKgFactor; // Convert to kg (1 for kg, 100 for quintal, etc.)
  final bool isWeightBased;

  const ProduceUnit({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.symbol,
    required this.toKgFactor,
    this.isWeightBased = true,
  });
}

/// Standard units used in Indian agricultural markets
class ProduceUnits {
  static const kg = ProduceUnit(
    id: 'kg',
    name: 'Kilogram',
    nameKn: 'ಕೆ.ಜಿ',
    symbol: 'kg',
    toKgFactor: 1.0,
  );

  static const quintal = ProduceUnit(
    id: 'quintal',
    name: 'Quintal',
    nameKn: 'ಕ್ವಿಂಟಲ್',
    symbol: 'q',
    toKgFactor: 100.0,
  );

  static const dozen = ProduceUnit(
    id: 'dozen',
    name: 'Dozen',
    nameKn: 'ಡಜನ್',
    symbol: 'dz',
    toKgFactor: 0.0, // Not weight-based
    isWeightBased: false,
  );

  static const bunch = ProduceUnit(
    id: 'bunch',
    name: 'Bunch',
    nameKn: 'ಕಟ್ಟು',
    symbol: 'bunch',
    toKgFactor: 0.0, // Not weight-based
    isWeightBased: false,
  );

  static const piece = ProduceUnit(
    id: 'piece',
    name: 'Piece',
    nameKn: 'ತುಂಡು',
    symbol: 'pc',
    toKgFactor: 0.0, // Not weight-based
    isWeightBased: false,
  );

  static const crate = ProduceUnit(
    id: 'crate',
    name: 'Crate',
    nameKn: 'ಕ್ರೇಟ್',
    symbol: 'crate',
    toKgFactor: 20.0, // Approximate
  );

  static const bag = ProduceUnit(
    id: 'bag',
    name: 'Bag (50kg)',
    nameKn: 'ಚೀಲ',
    symbol: 'bag',
    toKgFactor: 50.0,
  );
}

/// Individual produce item
class ProduceItem {
  final String id;
  final String name;
  final String nameKn; // Kannada
  final String nameHi; // Hindi
  final String emoji;
  final ProduceCategory category;
  final List<ProduceUnit> availableUnits;
  final ProduceUnit defaultUnit;
  final List<int> quickQuantities; // Quick selection buttons
  final double? avgPricePerKg; // Market reference price

  const ProduceItem({
    required this.id,
    required this.name,
    required this.nameKn,
    required this.nameHi,
    required this.emoji,
    required this.category,
    required this.availableUnits,
    required this.defaultUnit,
    required this.quickQuantities,
    this.avgPricePerKg,
  });
}

/// Complete produce catalog
class ProduceCatalog {
  static final List<ProduceItem> vegetables = [
    // Root vegetables
    ProduceItem(
      id: 'tomato',
      name: 'Tomato',
      nameKn: 'ಟೊಮೆಟೊ',
      nameHi: 'टमाटर',
      emoji: '🍅',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 35.0,
    ),
    ProduceItem(
      id: 'potato',
      name: 'Potato',
      nameKn: 'ಆಲೂಗಡ್ಡೆ',
      nameHi: 'आलू',
      emoji: '🥔',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.bag],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [25, 50, 100, 200],
      avgPricePerKg: 22.0,
    ),
    ProduceItem(
      id: 'onion',
      name: 'Onion',
      nameKn: 'ಈರುಳ್ಳಿ',
      nameHi: 'प्याज',
      emoji: '🧅',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.bag],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [25, 50, 100, 200],
      avgPricePerKg: 28.0,
    ),
    ProduceItem(
      id: 'carrot',
      name: 'Carrot',
      nameKn: 'ಕ್ಯಾರೆಟ್',
      nameHi: 'गाजर',
      emoji: '🥕',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 32.0,
    ),
    ProduceItem(
      id: 'cabbage',
      name: 'Cabbage',
      nameKn: 'ಎಲೆಕೋಸು',
      nameHi: 'पत्तागोभी',
      emoji: '🥬',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [25, 50, 100],
      avgPricePerKg: 18.0,
    ),
    ProduceItem(
      id: 'cauliflower',
      name: 'Cauliflower',
      nameKn: 'ಹೂಕೋಸು',
      nameHi: 'फूलगोभी',
      emoji: '🥦',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 25.0,
    ),
    ProduceItem(
      id: 'brinjal',
      name: 'Brinjal',
      nameKn: 'ಬದನೆಕಾಯಿ',
      nameHi: 'बैंगन',
      emoji: '🍆',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 30.0,
    ),
    ProduceItem(
      id: 'capsicum',
      name: 'Capsicum',
      nameKn: 'ದೊಡ್ಡ ಮೆಣಸಿನಕಾಯಿ',
      nameHi: 'शिमला मिर्च',
      emoji: '🫑',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 45.0,
    ),
    ProduceItem(
      id: 'chilli',
      name: 'Green Chilli',
      nameKn: 'ಹಸಿ ಮೆಣಸಿನಕಾಯಿ',
      nameHi: 'हरी मिर्च',
      emoji: '🌶️',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 55.0,
    ),
    ProduceItem(
      id: 'beans',
      name: 'French Beans',
      nameKn: 'ಬೀನ್ಸ್',
      nameHi: 'फ्रेंच बीन्स',
      emoji: '🫛',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 45.0,
    ),
    ProduceItem(
      id: 'okra',
      name: 'Okra (Lady Finger)',
      nameKn: 'ಬೆಂಡೆಕಾಯಿ',
      nameHi: 'भिंडी',
      emoji: '🥒',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 40.0,
    ),
    ProduceItem(
      id: 'cucumber',
      name: 'Cucumber',
      nameKn: 'ಸೌತೆಕಾಯಿ',
      nameHi: 'खीरा',
      emoji: '🥒',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 25.0,
    ),
    ProduceItem(
      id: 'bottlegourd',
      name: 'Bottle Gourd',
      nameKn: 'ಸೋರೆಕಾಯಿ',
      nameHi: 'लौकी',
      emoji: '🥬',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece],
      defaultUnit: ProduceUnits.piece,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 20.0,
    ),
    ProduceItem(
      id: 'bittergourd',
      name: 'Bitter Gourd',
      nameKn: 'ಹಾಗಲಕಾಯಿ',
      nameHi: 'करेला',
      emoji: '🥒',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25],
      avgPricePerKg: 35.0,
    ),
    ProduceItem(
      id: 'pumpkin',
      name: 'Pumpkin',
      nameKn: 'ಕುಂಬಳಕಾಯಿ',
      nameHi: 'कद्दू',
      emoji: '🎃',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 18.0,
    ),
    ProduceItem(
      id: 'radish',
      name: 'Radish',
      nameKn: 'ಮೂಲಂಗಿ',
      nameHi: 'मूली',
      emoji: '🥕',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.bunch],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 20.0,
    ),
    ProduceItem(
      id: 'beetroot',
      name: 'Beetroot',
      nameKn: 'ಬೀಟ್ರೂಟ್',
      nameHi: 'चुकंदर',
      emoji: '🥕',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 28.0,
    ),
    ProduceItem(
      id: 'ginger',
      name: 'Ginger',
      nameKn: 'ಶುಂಠಿ',
      nameHi: 'अदरक',
      emoji: '🫚',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 80.0,
    ),
    ProduceItem(
      id: 'garlic',
      name: 'Garlic',
      nameKn: 'ಬೆಳ್ಳುಳ್ಳಿ',
      nameHi: 'लहसुन',
      emoji: '🧄',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 120.0,
    ),
    ProduceItem(
      id: 'drumstick',
      name: 'Drumstick',
      nameKn: 'ನುಗ್ಗೆಕಾಯಿ',
      nameHi: 'सहजन',
      emoji: '🌿',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.bunch],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25],
      avgPricePerKg: 40.0,
    ),
    ProduceItem(
      id: 'greenpeas',
      name: 'Green Peas',
      nameKn: 'ಹಸಿರು ಬಟಾಣಿ',
      nameHi: 'हरी मटर',
      emoji: '🫛',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 60.0,
    ),
    ProduceItem(
      id: 'corn',
      name: 'Sweet Corn',
      nameKn: 'ಸಿಹಿ ಜೋಳ',
      nameHi: 'मक्का',
      emoji: '🌽',
      category: ProduceCategory.vegetables,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece, ProduceUnits.dozen],
      defaultUnit: ProduceUnits.piece,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 25.0,
    ),
  ];

  static final List<ProduceItem> leafyGreens = [
    ProduceItem(
      id: 'spinach',
      name: 'Spinach',
      nameKn: 'ಪಾಲಕ್',
      nameHi: 'पालक',
      emoji: '🥬',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 30.0,
    ),
    ProduceItem(
      id: 'coriander',
      name: 'Coriander Leaves',
      nameKn: 'ಕೊತ್ತಂಬರಿ',
      nameHi: 'धनिया',
      emoji: '🌿',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [25, 50, 100, 200],
      avgPricePerKg: 40.0,
    ),
    ProduceItem(
      id: 'mint',
      name: 'Mint Leaves',
      nameKn: 'ಪುದೀನ',
      nameHi: 'पुदीना',
      emoji: '🌱',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [25, 50, 100],
      avgPricePerKg: 50.0,
    ),
    ProduceItem(
      id: 'fenugreek',
      name: 'Fenugreek Leaves',
      nameKn: 'ಮೆಂತ್ಯ ಸೊಪ್ಪು',
      nameHi: 'मेथी',
      emoji: '🌿',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [25, 50, 100],
      avgPricePerKg: 35.0,
    ),
    ProduceItem(
      id: 'curryLeaves',
      name: 'Curry Leaves',
      nameKn: 'ಕರಿಬೇವು',
      nameHi: 'करी पत्ता',
      emoji: '🍃',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [50, 100, 200],
      avgPricePerKg: 60.0,
    ),
    ProduceItem(
      id: 'amaranth',
      name: 'Amaranth Leaves',
      nameKn: 'ದಂಟು ಸೊಪ್ಪು',
      nameHi: 'चौलाई',
      emoji: '🥬',
      category: ProduceCategory.leafyGreens,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [25, 50, 100],
      avgPricePerKg: 25.0,
    ),
  ];

  static final List<ProduceItem> fruits = [
    ProduceItem(
      id: 'banana',
      name: 'Banana',
      nameKn: 'ಬಾಳೆಹಣ್ಣು',
      nameHi: 'केला',
      emoji: '🍌',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.dozen, ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.dozen,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 40.0,
    ),
    ProduceItem(
      id: 'mango',
      name: 'Mango',
      nameKn: 'ಮಾವಿನ ಹಣ್ಣು',
      nameHi: 'आम',
      emoji: '🥭',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.dozen, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 80.0,
    ),
    ProduceItem(
      id: 'papaya',
      name: 'Papaya',
      nameKn: 'ಪಪ್ಪಾಯಿ',
      nameHi: 'पपीता',
      emoji: '🍈',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.piece],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 30.0,
    ),
    ProduceItem(
      id: 'watermelon',
      name: 'Watermelon',
      nameKn: 'ಕಲ್ಲಂಗಡಿ',
      nameHi: 'तरबूज',
      emoji: '🍉',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.piece, ProduceUnits.kg],
      defaultUnit: ProduceUnits.piece,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 15.0,
    ),
    ProduceItem(
      id: 'pomegranate',
      name: 'Pomegranate',
      nameKn: 'ದಾಳಿಂಬೆ',
      nameHi: 'अनार',
      emoji: '🍎',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 120.0,
    ),
    ProduceItem(
      id: 'guava',
      name: 'Guava',
      nameKn: 'ಪೇರಲ ಹಣ್ಣು',
      nameHi: 'अमरूद',
      emoji: '🍐',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 45.0,
    ),
    ProduceItem(
      id: 'grapes',
      name: 'Grapes',
      nameKn: 'ದ್ರಾಕ್ಷಿ',
      nameHi: 'अंगूर',
      emoji: '🍇',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 80.0,
    ),
    ProduceItem(
      id: 'orange',
      name: 'Orange',
      nameKn: 'ಕಿತ್ತಳೆ',
      nameHi: 'संतरा',
      emoji: '🍊',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.dozen, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 50.0,
    ),
    ProduceItem(
      id: 'lemon',
      name: 'Lemon',
      nameKn: 'ನಿಂಬೆಹಣ್ಣು',
      nameHi: 'नींबू',
      emoji: '🍋',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.dozen],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 60.0,
    ),
    ProduceItem(
      id: 'coconut',
      name: 'Coconut',
      nameKn: 'ತೆಂಗಿನಕಾಯಿ',
      nameHi: 'नारियल',
      emoji: '🥥',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.piece, ProduceUnits.dozen],
      defaultUnit: ProduceUnits.piece,
      quickQuantities: [25, 50, 100, 200],
      avgPricePerKg: 25.0,
    ),
    ProduceItem(
      id: 'sapota',
      name: 'Sapota (Chikoo)',
      nameKn: 'ಸಪೋಟ',
      nameHi: 'चीकू',
      emoji: '🥔',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 50.0,
    ),
    ProduceItem(
      id: 'apple',
      name: 'Apple',
      nameKn: 'ಸೇಬು',
      nameHi: 'सेब',
      emoji: '🍎',
      category: ProduceCategory.fruits,
      availableUnits: [ProduceUnits.kg, ProduceUnits.crate],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50],
      avgPricePerKg: 150.0,
    ),
  ];

  static final List<ProduceItem> flowers = [
    ProduceItem(
      id: 'marigold',
      name: 'Marigold',
      nameKn: 'ಚೆಂಡು ಹೂವು',
      nameHi: 'गेंदा',
      emoji: '🌼',
      category: ProduceCategory.flowers,
      availableUnits: [ProduceUnits.kg, ProduceUnits.bunch],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 80.0,
    ),
    ProduceItem(
      id: 'jasmine',
      name: 'Jasmine',
      nameKn: 'ಮಲ್ಲಿಗೆ',
      nameHi: 'चमेली',
      emoji: '🌸',
      category: ProduceCategory.flowers,
      availableUnits: [ProduceUnits.kg],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [1, 2, 5, 10],
      avgPricePerKg: 300.0,
    ),
    ProduceItem(
      id: 'rose',
      name: 'Rose',
      nameKn: 'ಗುಲಾಬಿ',
      nameHi: 'गुलाब',
      emoji: '🌹',
      category: ProduceCategory.flowers,
      availableUnits: [ProduceUnits.bunch, ProduceUnits.kg, ProduceUnits.dozen],
      defaultUnit: ProduceUnits.bunch,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 150.0,
    ),
    ProduceItem(
      id: 'chrysanthemum',
      name: 'Chrysanthemum',
      nameKn: 'ಸೇವಂತಿಗೆ',
      nameHi: 'गुलदाउदी',
      emoji: '🌻',
      category: ProduceCategory.flowers,
      availableUnits: [ProduceUnits.kg, ProduceUnits.bunch],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [5, 10, 25, 50],
      avgPricePerKg: 60.0,
    ),
  ];

  static final List<ProduceItem> grains = [
    ProduceItem(
      id: 'rice',
      name: 'Paddy Rice',
      nameKn: 'ಭತ್ತ',
      nameHi: 'धान',
      emoji: '🌾',
      category: ProduceCategory.grains,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.bag],
      defaultUnit: ProduceUnits.quintal,
      quickQuantities: [1, 5, 10, 20],
      avgPricePerKg: 35.0,
    ),
    ProduceItem(
      id: 'wheat',
      name: 'Wheat',
      nameKn: 'ಗೋಧಿ',
      nameHi: 'गेहूं',
      emoji: '🌾',
      category: ProduceCategory.grains,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.bag],
      defaultUnit: ProduceUnits.quintal,
      quickQuantities: [1, 5, 10, 20],
      avgPricePerKg: 28.0,
    ),
    ProduceItem(
      id: 'jowar',
      name: 'Jowar (Sorghum)',
      nameKn: 'ಜೋಳ',
      nameHi: 'ज्वार',
      emoji: '🌾',
      category: ProduceCategory.grains,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.quintal,
      quickQuantities: [1, 5, 10, 20],
      avgPricePerKg: 32.0,
    ),
    ProduceItem(
      id: 'ragi',
      name: 'Ragi (Finger Millet)',
      nameKn: 'ರಾಗಿ',
      nameHi: 'रागी',
      emoji: '🌾',
      category: ProduceCategory.grains,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal],
      defaultUnit: ProduceUnits.quintal,
      quickQuantities: [1, 5, 10, 20],
      avgPricePerKg: 40.0,
    ),
    ProduceItem(
      id: 'groundnut',
      name: 'Groundnut',
      nameKn: 'ಕಡಲೆಕಾಯಿ',
      nameHi: 'मूंगफली',
      emoji: '🥜',
      category: ProduceCategory.grains,
      availableUnits: [ProduceUnits.kg, ProduceUnits.quintal, ProduceUnits.bag],
      defaultUnit: ProduceUnits.kg,
      quickQuantities: [10, 25, 50, 100],
      avgPricePerKg: 70.0,
    ),
  ];

  /// Get all produce items
  static List<ProduceItem> get all => [
    ...vegetables,
    ...leafyGreens,
    ...fruits,
    ...flowers,
    ...grains,
  ];

  /// Get produce by category
  static List<ProduceItem> getByCategory(ProduceCategory category) {
    switch (category) {
      case ProduceCategory.vegetables:
        return vegetables;
      case ProduceCategory.leafyGreens:
        return leafyGreens;
      case ProduceCategory.fruits:
        return fruits;
      case ProduceCategory.flowers:
        return flowers;
      case ProduceCategory.grains:
        return grains;
      case ProduceCategory.other:
        return [];
    }
  }

  /// Get category label
  static String getCategoryLabel(ProduceCategory category) {
    switch (category) {
      case ProduceCategory.vegetables:
        return 'Vegetables';
      case ProduceCategory.leafyGreens:
        return 'Leafy Greens';
      case ProduceCategory.fruits:
        return 'Fruits';
      case ProduceCategory.flowers:
        return 'Flowers';
      case ProduceCategory.grains:
        return 'Grains & Pulses';
      case ProduceCategory.other:
        return 'Other';
    }
  }

  /// Get category emoji
  static String getCategoryEmoji(ProduceCategory category) {
    switch (category) {
      case ProduceCategory.vegetables:
        return '🥬';
      case ProduceCategory.leafyGreens:
        return '🌿';
      case ProduceCategory.fruits:
        return '🍎';
      case ProduceCategory.flowers:
        return '🌸';
      case ProduceCategory.grains:
        return '🌾';
      case ProduceCategory.other:
        return '📦';
    }
  }
}
