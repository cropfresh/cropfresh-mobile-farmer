/// Karnataka Location Data
/// Complete list of all 31 districts and their talukas
/// For Story 2.1 - AC5: Profile Setup Screen

class KarnatakaLocations {
  /// All 31 districts of Karnataka
  static const List<String> districts = [
    'Bagalkot',
    'Ballari (Bellary)',
    'Belagavi (Belgaum)',
    'Bengaluru Rural',
    'Bengaluru Urban',
    'Bidar',
    'Chamarajanagar',
    'Chikkaballapur',
    'Chikkamagaluru',
    'Chitradurga',
    'Dakshina Kannada',
    'Davanagere',
    'Dharwad',
    'Gadag',
    'Hassan',
    'Haveri',
    'Kalaburagi (Gulbarga)',
    'Kodagu (Coorg)',
    'Kolar',
    'Koppal',
    'Mandya',
    'Mysuru (Mysore)',
    'Raichur',
    'Ramanagara',
    'Shivamogga (Shimoga)',
    'Tumakuru (Tumkur)',
    'Udupi',
    'Uttara Kannada',
    'Vijayapura (Bijapur)',
    'Yadgir',
  ];

  /// Talukas organized by district
  static const Map<String, List<String>> talukas = {
    'Bagalkot': ['Badami', 'Bagalkot', 'Bilagi', 'Hungund', 'Jamkhandi', 'Mudhol'],
    'Ballari (Bellary)': ['Ballari', 'Hadagali', 'Hagaribommanahalli', 'Hospet', 'Kudligi', 'Sandur', 'Siruguppa'],
    'Belagavi (Belgaum)': ['Athani', 'Bailhongal', 'Belagavi', 'Chikkodi', 'Gokak', 'Hukkeri', 'Khanapur', 'Raibag', 'Ramdurg', 'Saundatti'],
    'Bengaluru Rural': ['Devanahalli', 'Doddaballapur', 'Hosakote', 'Nelamangala'],
    'Bengaluru Urban': ['Anekal', 'Bengaluru East', 'Bengaluru North', 'Bengaluru South', 'Yelahanka'],
    'Bidar': ['Aurad', 'Basavakalyan', 'Bhalki', 'Bidar', 'Humnabad'],
    'Chamarajanagar': ['Chamarajanagar', 'Gundlupet', 'Kollegal', 'Yelandur'],
    'Chikkaballapur': ['Bagepalli', 'Chikkaballapur', 'Chintamani', 'Gowribidanur', 'Gudibande', 'Sidlaghatta'],
    'Chikkamagaluru': ['Chikkamagaluru', 'Kadur', 'Koppa', 'Mudigere', 'N.R.Pura', 'Sringeri', 'Tarikere'],
    'Chitradurga': ['Challakere', 'Chitradurga', 'Hiriyur', 'Holalkere', 'Hosadurga', 'Molakalmuru'],
    'Dakshina Kannada': ['Bantwal', 'Belthangady', 'Mangaluru', 'Moodabidri', 'Puttur', 'Sullia'],
    'Davanagere': ['Channagiri', 'Davanagere', 'Harihara', 'Honnali', 'Jagaluru', 'Nyamathi'],
    'Dharwad': ['Dharwad', 'Hubballi', 'Kalghatgi', 'Kundgol', 'Navalgund'],
    'Gadag': ['Gadag', 'Lakshmeshwar', 'Mundargi', 'Nargund', 'Ron', 'Shirahatti'],
    'Hassan': ['Alur', 'Arkalgud', 'Arsikere', 'Belur', 'Channarayapatna', 'Hassan', 'Holenarasipura', 'Sakleshpur'],
    'Haveri': ['Byadgi', 'Hanagal', 'Haveri', 'Hirekerur', 'Ranebennur', 'Savanur', 'Shiggaon'],
    'Kalaburagi (Gulbarga)': ['Afzalpur', 'Aland', 'Chincholi', 'Chittapur', 'Jevargi', 'Kalaburagi', 'Sedam'],
    'Kodagu (Coorg)': ['Madikeri', 'Somwarpet', 'Virajpet'],
    'Kolar': ['Bangarpet', 'Kolar', 'Kolar Gold Fields', 'Malur', 'Mulbagal', 'Srinivaspur'],
    'Koppal': ['Gangavathi', 'Koppal', 'Kushtagi', 'Yelburga'],
    'Mandya': ['K.R.Pet', 'Maddur', 'Malavalli', 'Mandya', 'Nagamangala', 'Pandavapura', 'Srirangapatna'],
    'Mysuru (Mysore)': ['H.D.Kote', 'Heggadadevankote', 'Hunsur', 'K.R.Nagar', 'Mysuru', 'Nanjangud', 'Periyapatna', 'T.Narasipura'],
    'Raichur': ['Devadurga', 'Lingasugur', 'Manvi', 'Raichur', 'Sindhanur'],
    'Ramanagara': ['Channapatna', 'Kanakapura', 'Magadi', 'Ramanagara'],
    'Shivamogga (Shimoga)': ['Bhadravathi', 'Hosanagara', 'Sagar', 'Shikaripur', 'Shivamogga', 'Sorab', 'Thirthahalli'],
    'Tumakuru (Tumkur)': ['Chikkanayakanahalli', 'Gubbi', 'Koratagere', 'Kunigal', 'Madhugiri', 'Pavagada', 'Sira', 'Tiptur', 'Tumakuru', 'Turuvekere'],
    'Udupi': ['Brahmavar', 'Karkala', 'Kundapura', 'Udupi'],
    'Uttara Kannada': ['Ankola', 'Bhatkal', 'Dandeli', 'Haliyal', 'Honavar', 'Joida', 'Karwar', 'Kumta', 'Mundgod', 'Siddapur', 'Sirsi', 'Yellapur'],
    'Vijayapura (Bijapur)': ['Bagevadi', 'Basavana Bagevadi', 'Bijapur', 'Indi', 'Muddebihal', 'Sindagi', 'Vijayapura'],
    'Yadgir': ['Shahapur', 'Shorapur', 'Yadgir'],
  };

  /// Sample villages per taluka (expandable)
  /// In production, this would be a much larger dataset
  static const Map<String, List<String>> villages = {
    // Mandya District
    'Mandya': ['Akkihebbalu', 'Basaralu', 'Byadarahalli', 'Chinakurali', 'Gejjalagere', 'Honnalagere', 'Keregodi', 'Kikkeri', 'Kyathanahalli', 'Malali'],
    'Maddur': ['Aralakuppe', 'Chikkamaddur', 'Halagur', 'Kesthur', 'Koppa', 'Malavalli', 'Shivalli', 'Thagadur', 'Valagere'],
    'Malavalli': ['Bannur', 'Halagur', 'Hanakere', 'Kirugavalu', 'Kollegala', 'Mallipatna', 'Sathanur', 'Voddarahalli'],
    'K.R.Pet': ['Arakere', 'Bookanakere', 'Hosahalli', 'Kikkeri', 'Konanur', 'Madapura', 'Melukote', 'Mirle'],
    'Nagamangala': ['Bindiganavile', 'Jumanal', 'Kenchanakuppe', 'Kuppepadavu', 'Nagamangala', 'Sathanur'],
    'Pandavapura': ['Chinchanakuppe', 'Guttalu', 'Kannambadi', 'Kiragasur', 'Pandavapura', 'Tonnur'],
    'Srirangapatna': ['Arakere', 'Bommuru', 'Ganjam', 'Paschimavahini', 'Srirangapatna'],
    
    // Mysuru District
    'Mysuru': ['Bogadi', 'Gundurao Nagar', 'Hebbal', 'Jayapura', 'Kadakola', 'Kesare', 'Lalithadripura', 'Metagalli', 'Srirampura', 'Vijayanagar'],
    'Nanjangud': ['Badanavalu', 'Devanur', 'Hedathale', 'Hullahalli', 'Kaadangur', 'Kalale', 'Nanjangud', 'Tagadur'],
    'Hunsur': ['Bilikere', 'Chilkunda', 'Hanagodu', 'Hunsur', 'Kabballi', 'Kallahalli', 'Piriyapatna'],
    'T.Narasipura': ['Bannur', 'Muguru', 'Sosale', 'T.Narasipura', 'Talakadu'],
    'H.D.Kote': ['Antharasanthe', 'H.D.Kote', 'Sargur'],
    
    // Bengaluru Rural District
    'Devanahalli': ['Budigere', 'Devanahalli', 'Kannamangala', 'Sadahalli', 'Shettigere', 'Vijayapura'],
    'Doddaballapur': ['Aralumalige', 'Doddaballapur', 'Kanasavadi', 'Oordigere', 'Thigalarapalya'],
    'Hosakote': ['Anugondanahalli', 'Hosakote', 'Kasaba', 'Sulibele', 'Jadigenahalli'],
    'Nelamangala': ['Dabaspet', 'Nelamangala', 'Thyamagondlu', 'Tavarekere'],
    
    // Tumkur District
    'Tumakuru': ['Bellavi', 'Gubbi', 'Hebbur', 'Hirehalli', 'Kyatsandra', 'Siddaganga', 'Tumakuru', 'Urdigere'],
    'Sira': ['Bukkapatna', 'Honnenahalli', 'Sira', 'Thammenahalli'],
    'Tiptur': ['Benkipura', 'Honnavalli', 'Nonavinakere', 'Tiptur'],
    'Madhugiri': ['Badavanahalli', 'Idagur', 'Kodigenahalli', 'Madhugiri'],
    'Kunigal': ['Amruthur', 'Huliyurdurga', 'Kunigal', 'Yediyur'],
    'Gubbi': ['Chelur', 'Gubbi', 'Nittur'],
    
    // Hassan District
    'Hassan': ['Arakalagud', 'Channarayapatna', 'Gorur', 'Hassan', 'Halebidu', 'Shravanabelagola'],
    'Arsikere': ['Arsikere', 'Banavara', 'Javagal'],
    'Belur': ['Belur', 'Halebid', 'Yagati'],
    'Channarayapatna': ['Channarayapatna', 'Doddamagge', 'Shravanabelagola'],
    'Holenarasipura': ['Halli Mysore', 'Holenarasipura'],
    'Sakleshpur': ['Hettur', 'Sakleshpur'],
    
    // Add more villages as needed...
  };

  /// Get all talukas for a district
  static List<String> getTalukas(String district) {
    return talukas[district] ?? [];
  }

  /// Get all villages for a taluka
  static List<String> getVillages(String taluka) {
    return villages[taluka] ?? [];
  }

  /// Search villages by name (for autocomplete)
  static List<String> searchVillages(String query, {String? taluka}) {
    if (query.isEmpty) return [];
    
    final lowerQuery = query.toLowerCase();
    final results = <String>[];
    
    if (taluka != null && villages.containsKey(taluka)) {
      // Search within specific taluka
      results.addAll(
        villages[taluka]!.where((v) => v.toLowerCase().contains(lowerQuery))
      );
    } else {
      // Search all villages
      for (final villageList in villages.values) {
        results.addAll(
          villageList.where((v) => v.toLowerCase().contains(lowerQuery))
        );
      }
    }
    
    // Remove duplicates and sort
    return results.toSet().toList()..sort();
  }

  /// Get all villages (flat list)
  static List<String> getAllVillages() {
    final allVillages = <String>[];
    for (final villageList in villages.values) {
      allVillages.addAll(villageList);
    }
    return allVillages.toSet().toList()..sort();
  }
}
